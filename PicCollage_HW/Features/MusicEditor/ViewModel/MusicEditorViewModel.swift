//
//  MusicEditorViewModel.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/10/29.
//

import Foundation
import Combine

class MusicEditorViewModel: ObservableObject {
    // Single source of truth
    @Published private(set) var state: MusicStateModel

    // Playback management
    private let playbackManager: PlaybackManager

    // Published properties for SwiftUI/UIKit view binding
    @Published private(set) var stateVersion: Int = 0 // Triggers UI updates
    @Published private(set) var waveformNeedsUpdate: Bool = false
    @Published private(set) var isPlaying: Bool = false

    // Legacy reactive properties for UIKit compatibility
    private(set) var onStateUpdated: ReactiveProperty<Void> = ReactiveProperty(value: ())
    private(set) var onWaveformNeedsUpdate: ReactiveProperty<Void> = ReactiveProperty(value: ())
    private(set) var isPlayingReactive: ReactiveProperty<Bool> = ReactiveProperty(value: false)
    
    var keyTimeRatio: [CGFloat] {
        state.keyTimes.map { $0 / state.totalDuration }
    }

    var sectionTimeline: String {
        let range = state.selectedRange
        return "Selected: \(formatTime(range.start)) - \(formatTime(range.end))"
    }

    var currentTimeline: String {
        "Current: \(formatTime(state.currentTime))"
    }

    var sectionPercentage: String {
        let startPercentage = formatPercentage(state.selectedRange.start, total: state.totalDuration)
        let endPercentage = formatPercentage(state.selectedRange.end, total: state.totalDuration)
        return "Section: \(startPercentage) - \(endPercentage)"
    }

    var currentPercentage: String {
        "Current: \(formatPercentage(state.currentTime, total: state.totalDuration))"
    }
    
    var progressRatio: CGFloat {
        let duration = state.selectedRange.duration
        let currentTime = state.currentTime
        return (currentTime - state.selectedRange.start) / duration
    }

    var durationRatio: CGFloat {
        let duration = state.selectedRange.duration
        let totalDuration = state.totalDuration
        return (duration / totalDuration)
    }

    init(state: MusicStateModel, playbackManager: PlaybackManager = PlaybackManager()) {
        self.state = state
        self.playbackManager = playbackManager
        self.playbackManager.delegate = self
        notifyStateUpdated()
    }

    func shiftTime(to time: CGFloat) {
        let shift = time - state.selectedRange.start
        state.updateTrimmerRange(by: shift)
        notifyStateUpdated()
    }

    func updateTimeFromScrollOffset(contentOffsetX: CGFloat,
                                    contentInsetLeft: CGFloat,
                                    contentInsetRight: CGFloat,
                                    contentSizeWidth: CGFloat,
                                    scrollViewWidth: CGFloat) {
        
        // Get scrollable width and changeable duration
        guard let params = calculateScrollParameters(contentSizeWidth: contentSizeWidth,
                                                     scrollViewWidth: scrollViewWidth,
                                                     contentInsetLeft: contentInsetLeft,
                                                     contentInsetRight: contentInsetRight) else { return }
        
        // Plus contentInsetLeft to make Offset X start from 0
        let adjustedOffset = contentOffsetX + contentInsetLeft
        
        let currentStart = (params.changeableDuration / params.scrollableWidth) * adjustedOffset

        shiftTime(to: currentStart)
    }

    func calculateScrollOffset(scrollViewBounds: CGRect,
                               contentSize: CGSize,
                               contentInsetLeft: CGFloat,
                               contentInsetRight: CGFloat) -> CGFloat? {
        
        // Get scrollable width and changeable duration
        guard let params = calculateScrollParameters(contentSizeWidth: contentSize.width,
                                                     scrollViewWidth: scrollViewBounds.width,
                                                     contentInsetLeft: contentInsetLeft,
                                                     contentInsetRight: contentInsetRight) else { return nil }

        let startTime = state.selectedRange.start
        
        // minus contentInsetLeft to get real Offset X of scrollView
        let targetOffsetX = (params.scrollableWidth / params.changeableDuration) * startTime - contentInsetLeft

        return targetOffsetX
    }
    
    func togglePlayPause() {
        playbackManager.togglePlayPause()
        isPlaying = playbackManager.isPlaying
        isPlayingReactive.value = playbackManager.isPlaying
    }

    func resetToStart() {
        state.resetCurrentTime()
        notifyStateUpdated()
    }

    // MARK: - Settings Management

    // Get current settings as MusicEditorSettings model
    func getCurrentSettings() -> MusicEditorSettings {
        return MusicEditorSettings(totalDuration: state.totalDuration,
                                   keyTimes: state.keyTimes,
                                   selectedRangeDuration: state.selectedRange.duration)
    }

    // Apply validated settings to the state
    // Parameter settings: The settings object containing user input
    // Throws: ValidationError if settings are invalid
    func applySettings(_ settings: MusicEditorSettings) throws {
        // Validate settings first
        try settings.validate()

        // Track if waveform needs update
        var needsWaveformUpdate = false

        // Apply to state
        if state.totalDuration != settings.totalDuration {
            needsWaveformUpdate = true
        }
        state.updateTotalDuration(value: settings.totalDuration)
        state.updateKeyTimes(settings.keyTimes)

        if let duration = settings.timelineDuration {
            if state.selectedRange.duration != duration {
                needsWaveformUpdate = true
            }
            state.updateSelectedRangeDuration(duration)
        }

        // Trigger waveform update if needed
        if needsWaveformUpdate {
            notifyWaveformUpdated()
        }

        notifyStateUpdated()
    }

    // MARK: - Private Methods
    private func calculateScrollParameters(contentSizeWidth: CGFloat,
                                           scrollViewWidth: CGFloat,
                                           contentInsetLeft: CGFloat,
                                           contentInsetRight: CGFloat) -> ScrollParameters? {
        
        // Calculate the scrollable range (total width minus visible width)
        let scrollableWidth = contentSizeWidth + contentInsetLeft + contentInsetRight - scrollViewWidth

        // Calculate the adjustable duration (total minus selected range)
        let changeableDuration = state.totalDuration - state.selectedRange.duration

        guard changeableDuration > 0, scrollableWidth > 0 else { return nil }

        return ScrollParameters(scrollableWidth: scrollableWidth, changeableDuration: changeableDuration)
    }

    private func notifyStateUpdated() {
        stateVersion += 1
        onStateUpdated.value = ()  // For UIKit compatibility
    }

    private func notifyWaveformUpdated() {
        waveformNeedsUpdate.toggle()
        onWaveformNeedsUpdate.value = ()  // For UIKit compatibility
    }

    private func formatTime(_ seconds: CGFloat) -> String {
        let totalSeconds = Int(seconds)
        return String(format: "%1d:%02d", totalSeconds / 60, totalSeconds % 60)
    }

    private func formatPercentage(_ value: CGFloat, total: CGFloat) -> String {
        String(format: "%.1f%%", (value / total) * 100)
    }

    private func updateCurrentTime(by interval: TimeInterval) {
        state.updateCurrentTime(by: CGFloat(interval))
        notifyStateUpdated()
    }
}

// MARK: - PlaybackManagerDelegate
extension MusicEditorViewModel: PlaybackManagerDelegate {
    func playbackManagerDidUpdateTime(by interval: TimeInterval) {
        updateCurrentTime(by: interval)
    }
}
