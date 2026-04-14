import os
import json
import time
import jwt
import requests

BASE = "https://api.appstoreconnect.apple.com/v1"
APP_ID = "6762165456"
POLL_INTERVAL = 10
MAX_ATTEMPTS = 30


def load_api_key():
    path = os.path.expanduser("~/private_keys/api_key.json")
    with open(path) as f:
        return json.load(f)


def make_token(key_data):
    now = int(time.time())
    payload = {"iss": key_data["issuer_id"], "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"}
    return jwt.encode(payload, key_data["key"], algorithm="ES256", headers={"kid": key_data["key_id"]})


def rel(type_name, resource_id):
    """Build a relationship data reference."""
    return {"data": {"type": type_name, "id": resource_id}}


def resource(type_name, relationships=None, attributes=None, resource_id=None):
    """Build a JSON:API resource envelope."""
    body = {"type": type_name}
    if resource_id:
        body["id"] = resource_id
    if attributes:
        body["attributes"] = attributes
    if relationships:
        body["relationships"] = relationships
    return {"data": body}


class AppStoreClient:
    def __init__(self):
        key_data = load_api_key()
        token = make_token(key_data)
        self.headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

    def _call(self, method, path, payload=None, label=None, check_errors=True):
        resp = getattr(requests, method)(f"{BASE}/{path}", headers=self.headers, json=payload)
        data = resp.json() if resp.content else {}
        if label:
            print(f"{label} (status {resp.status_code})")
        if check_errors and "errors" in data:
            raise SystemExit(f"API error: {json.dumps(data['errors'], indent=2)}")
        return data

    def wait_for_build(self):
        print("Waiting for build to finish processing...")
        for attempt in range(MAX_ATTEMPTS):
            data = self._call("get", f"builds?filter[app]={APP_ID}&sort=-uploadedDate&limit=1",
                              check_errors=False)
            if not data.get("data"):
                print(f"  Build not yet visible (attempt {attempt + 1})...")
                time.sleep(POLL_INTERVAL)
                continue
            build = data["data"][0]
            bid, state = build["id"], build["attributes"].get("processingState", "UNKNOWN")
            print(f"  Build {build['attributes']['version']} (#{bid}): {state}")
            if state == "VALID":
                return bid
            if state == "FAILED":
                raise SystemExit("Build processing failed!")
            time.sleep(POLL_INTERVAL)
        raise SystemExit("Timed out waiting for build")

    def submit_for_review(self, build_id):
        self._call("patch", f"builds/{build_id}",
                 resource("builds", resource_id=build_id, attributes={"usesNonExemptEncryption": False}),
                 label="Export compliance set")

        ver = self._call("get", f"apps/{APP_ID}/appStoreVersions")["data"][0]
        version_id = ver["id"]
        print(f"Version: {ver['attributes']['versionString']} (id: {version_id})")

        self._call("patch", f"appStoreVersions/{version_id}/relationships/build",
                 rel("builds", build_id), label="Build assigned")

        sub = self._call("post", "reviewSubmissions",
                       resource("reviewSubmissions", attributes={"platform": "IOS"},
                                relationships={"app": rel("apps", APP_ID)}),
                       label="Review submission created")
        sub_id = sub["data"]["id"]

        self._call("post", "reviewSubmissionItems",
                 resource("reviewSubmissionItems",
                          relationships={"reviewSubmission": rel("reviewSubmissions", sub_id),
                                         "appStoreVersion": rel("appStoreVersions", version_id)}),
                 label="Submission item added")

        self._call("patch", f"reviewSubmissions/{sub_id}",
                 resource("reviewSubmissions", resource_id=sub_id, attributes={"submitted": True}),
                 label="Submitted for review!")


if __name__ == "__main__":
    client = AppStoreClient()
    client.submit_for_review(client.wait_for_build())
