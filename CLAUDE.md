# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an iOS music editor application (PicCollage homework assignment) built with UIKit. The project demonstrates:
- Coordinator pattern for navigation
- MVVM architecture for view logic
- Programmatic UI (no storyboard-based navigation)

## Building and Running

```bash
# Build the project
xcodebuild -project PicCollage_HW.xcodeproj -scheme PicCollage_HW -configuration Debug build

# Run tests (when available)
xcodebuild test -project PicCollage_HW.xcodeproj -scheme PicCollage_HW -destination 'platform=iOS Simulator,name=iPhone 15'

# Open in Xcode
open PicCollage_HW.xcodeproj
```

**Target**: iOS 18.1+
**Bundle ID**: demo.PicCollage-HW
**No external dependencies** (no CocoaPods, SPM, or Carthage)

## Architecture

### Coordinator Pattern
Navigation is handled through the Coordinator protocol, initialized in `SceneDelegate.swift:20-22`:

- `Coordinator` protocol: Defines navigation contract with `childCoordinators`, `navigationController`, `startCoordinator()`, and `push()`
- `MainCoordinator`: Concrete implementation that initializes the app with `MusicEditorViewController`
- Entry point: `SceneDelegate` creates `MainCoordinator` and sets it as the window's root view controller

### MVVM Structure
The main feature follows MVVM:

- **Model**: `TrimmerRangeModel` (in `TimeRangeModel.swift`) - handles time range logic with `start`, `end`, `duration` properties and a `shift()` method for boundary-aware range adjustment
- **View**: `MusicEditorViewController` - receives `MusicEditorViewModel` via dependency injection in initializer
- **ViewModel**: `MusicEditorViewModel` - currently minimal, expected to contain music editing business logic

### Key Files
- `SceneDelegate.swift`: App entry point, initializes coordinator-based navigation
- `Coordinator.swift`: Navigation abstraction layer
- `MusicEditorViewController.swift` + `MusicEditorViewModel.swift`: Main feature using MVVM
- `TimeRangeModel.swift`: Domain model for music trimming with range manipulation logic
- `ViewController.swift`: Legacy/unused file (default Xcode template)

## Development Notes

- The app uses programmatic initialization for view controllers (note the required `init(coder:)` with `fatalError` in `MusicEditorViewController.swift:18-20`)
- UI is built programmatically, not through storyboards (Main.storyboard exists but navigation bypasses it)
- `TrimmerRangeModel.shift()` includes boundary logic to prevent invalid ranges when shifting time ranges
