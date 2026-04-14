# Brief: Meeting AI

An AI-powered meeting preparation and debrief tool for iOS. Built entirely on Apple Intelligence with on-device processing -- your meeting data never leaves your device.

## Features

- **Meeting Prep**: Generate talking points, questions, structure, and time allocation from your meeting agenda
- **Meeting Debrief**: Extract decisions, action items with owners/deadlines, open questions, and draft follow-up emails from raw notes
- **1:1 Prep**: Create conversation starters, topics, and follow-up points for one-on-one meetings
- **Presentation Prep**: Get key messages, anticipated questions, opening hooks, and slide structure suggestions

## Requirements

- iOS 26.0+
- Apple Intelligence-capable device (iPhone 16+, iPad with M-series chip)

## Architecture

- **SwiftUI** with SwiftData for persistence
- **FoundationModels** framework with `@Generable` structs for structured AI output
- **On-device processing** via Apple Intelligence -- zero network calls, complete privacy
- PDF export for sharing meeting briefs

## Privacy

Brief processes all data on-device using Apple Intelligence. No data is collected, stored remotely, or shared with third parties. See our [Privacy Policy](https://nilehanov.github.io/brief-ai/privacy.html).

## Build

```bash
brew install xcodegen
xcodegen generate
open Brief.xcodeproj
```

## License

Copyright 2026 Nile Hanov. All rights reserved.
