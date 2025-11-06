# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an iOS music editor application (PicCollage homework assignment) built with UIKit. The project demonstrates:
- Coordinator pattern for navigation
- MVVM architecture with reactive data binding
- Programmatic UI (no storyboard-based navigation)
- Feature-based modular project structure
- Interactive waveform visualization with animations
- Timer-based playback simulation

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

## Project Structure

The project is organized by feature modules:

```
PicCollage_HW/
├── App/                          # Application lifecycle & navigation
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── Coordinator.swift
├── Features/                     # Feature modules
│   ├── MusicEditor/              # Main music editing feature
│   │   ├── Model/                # Data models (TrimmerRangeModel, MusicStateModel, etc.)
│   │   ├── View/                 # UI components (ViewControllers, Views)
│   │   │   └── Waveform/         # Waveform-specific views
│   │   └── ViewModel/            # Business logic (MusicEditorViewModel, WaveformViewModel)
│   └── Settings/                 # Settings feature
│       ├── View/
│       
│       
├── Services/                     # Shared services (PlaybackManager, WaveformComposer)
└── Utilities/                    # Helper utilities (ObservableObject, SettingsValidator)
```

## Architecture

### Coordinator Pattern
Navigation is handled through the Coordinator protocol:

- **Protocol**: Defines navigation contract with `childCoordinators`, `navigationController`, `startCoordinator()`, and `push()`
- **MainCoordinator** (in `Coordinator.swift:19-55`): Handles app startup, navigation to settings, alert display, and back navigation
- **Entry Point**: `SceneDelegate` creates `MainCoordinator` and sets it as the window's root view controller
- **Initialization** (`Coordinator.swift:20-37`): Creates models, ViewModels, and ViewControllers with proper dependency injection

### MVVM Architecture

#### Model Layer
- **TrimmerRangeModel** (`TimeRangeModel.swift`): Time range logic with `start`, `end`, `duration` properties and `shift(by:totalDuration:)` for boundary-aware range adjustment
- **MusicStateModel** (`MusicStateModel.swift`): Single source of truth containing `totalDuration`, `currentTime`, `keyTimes`, and `selectedRange`
- **MusicEditorSettings** (`MusicEditorSettings.swift`): Settings data transfer object with percentage ↔ absolute time conversions
- **WaveformBarState** (`WaveformBarState.swift`): Encapsulates individual waveform bar state (`amplitude`, `scale`, `brightness`)

#### View Layer
- **MusicEditorViewController**: Main controller managing `MusicTrimmerView` and coordinating multiple delegates
- **MusicTrimmerView**: Composite view aggregating waveform, key time selector, labels, and controls
- **WaveformView** (`View/Waveform/WaveformView.swift`): Complex scrollable waveform display with:
  - Scrollable canvas with individual bar views
  - Selected range overlay with **gradient border** (orange → purple, `WaveformView.swift:168-199`)
  - Progress indicator
  - Content insets for centered selection (25% on each side)
- **WaveformBar** (`View/Waveform/WaveformBar.swift`): Individual animated bar component
- **KeyTimeView**: Timeline visualization with dynamic key time buttons
- **SettingViewController**: Form-based settings editor with validation

#### ViewModel Layer
- **MusicEditorViewModel**: Core business logic managing:
  - State updates via `MusicStateModel`
  - Time shifting calculations (`shiftTime(to:)`)
  - Scroll offset computations
  - Playback control via `PlaybackManager`
  - Settings management with validation
  - Reactive bindings via `ObservableObject` properties
- **WaveformViewModel**: Animation state management with:
  - Dynamic bar state array
  - Bar count adjustment (`adjustBarCount(to:)`)
  - Animation logic (`update(for:selectedFrame:barWidth:gap:)` at `WaveformViewModel.swift:34-61`) calculating:
    - Brightness: `0.3 + 0.7 * overlapRatio` (bars in selection are brighter)
    - Scale: `1 + 0.4 * normalized distance from center` (bars near center are larger, max 1.4x)

### Services

- **PlaybackManager** (`Services/PlaybackManager.swift`): Timer-based playback simulation
  - Default update interval: 0.01s
  - Uses `.common` RunLoop mode for smooth scrolling during playback
  - Delegate pattern for time updates

- **WaveformComposer** (`Services/WaveformComposer.swift`): Factory for waveform canvas creation
  - Constants: 3pt bar width, 3pt gap, 30-60% height range
  - `makeWaveformCanvas(barStates:height:)` creates container with bar subviews
  - Utility methods for bar count and width calculations

### Utilities

- **ObservableObject** (`Utilities/ObservableObject.swift`): Simple reactive binding implementation with `bind(notifyImmediately:_:)` method
- **SettingsValidator** (`Utilities/SettingsValidator.swift`): Input validation with typed error enum (duration > 0, percentages 0-100)

## Key Features

### Waveform Animation System
When user scrolls the waveform:
1. `WaveformViewDelegate.scrollViewDidScroll(_:)` fires
2. `MusicEditorViewController.updateWaveformBarStates()` calculates frames
3. `WaveformViewModel.update()` computes new bar states (scale + brightness)
4. `onBarsUpdated` triggers UI updates
5. Each bar animates with 0.1s UIView animation for scale; brightness updates instantly

**Visual Effects**:
- Bars inside selection: brighter (0.3-1.0 range)
- Bars near selection center: larger scale (1.0-1.4x)
- Smooth real-time updates during scrolling

### Gradient Border
- Applied to selected range overlay in `WaveformView`
- Orange-to-purple horizontal gradient using `CAGradientLayer`
- Even-odd fill rule creates border-only effect
- Automatically redrawn in `layoutSubviews()`

### Reactive Data Flow
ViewModels expose `ObservableObject` properties:
- `onStateUpdated`: Triggers full UI refresh
- `onWaveformNeedsUpdate`: Rebuilds waveform canvas (on settings change)
- `isPlaying`: Updates play/pause button text
- `onBarsUpdated`: Updates waveform bar animations

Views bind to these properties in `binding()` methods, establishing unidirectional data flow.

## Development Notes

### Design Patterns
- **Coordinator Pattern**: Centralized navigation, weak VC references to coordinator
- **MVVM with Reactive Bindings**: Observable properties for unidirectional data flow
- **Delegate Pattern**: Multiple delegate protocols for separation of concerns
- **Dependency Injection**: ViewControllers receive ViewModels via initializer
- **Single Source of Truth**: `MusicStateModel` as authoritative state
- **Factory Pattern**: `WaveformComposer` for view creation

### Code Conventions
- Programmatic UI only (required `init?(coder:)` throws `fatalError`)
- Main.storyboard exists but navigation bypasses it
- All ViewControllers use dependency injection
- Computed properties for derived UI values
- Private access control for internal implementation details

### Important Implementation Details
- `TrimmerRangeModel.shift()` includes boundary logic to prevent invalid ranges
- `PlaybackManager` uses `.common` RunLoop mode to continue during scrolling
- `WaveformView` uses content insets (25% each side) for centered selection
- Selected range is always 50% of visible width
- `WaveformComposer` calculates canvas width based on duration ratio
- Settings validation throws typed errors with localized descriptions
- Bar animations use state-driven approach via `WaveformBarState`

## Data Flow Examples

**User scrolls waveform**:
```
Scroll → WaveformViewDelegate → updateWaveformBarStates()
→ WaveformViewModel.update() → onBarsUpdated → View updates bars
→ updateTimeFromScrollOffset() → shiftTime(to:) → onStateUpdated → UI refresh
```

**User taps key time button**:
```
Tap → KeyTimeViewDelegate → shiftTime(to:) → updates MusicStateModel
→ onStateUpdated → MusicTrimmerView.updateUI() → all UI components refresh
→ updateWaveformBarStates() → animation recalculation
```

**User changes settings**:
```
Save → collectInputData() → MusicEditorSettings → applySettings(_:)
→ SettingsValidator validates → updates MusicStateModel
→ onWaveformNeedsUpdate → rebuild canvas → onStateUpdated → full UI refresh
```
