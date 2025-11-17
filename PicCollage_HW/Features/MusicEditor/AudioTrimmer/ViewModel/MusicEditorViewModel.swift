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

    // Published properties for SwiftUI/UIKit view binding
    @Published private(set) var stateVersion: Int = 0 // Triggers UI updates
    @Published private(set) var waveformNeedsUpdate: Bool = false
    @Published private(set) var isPlaying: Bool = false
    
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
    // Playback management
    private let playbackManager: PlaybackManager

    var sectionPercentage: String {
        let startPercentage = formatPercentage(state.selectedRange.start, total: state.totalDuration)
        let endPercentage = formatPercentage(state.selectedRange.end, total: state.totalDuration)
        let output = "Section: \(startPercentage) - \(endPercentage)"
        print(output)
        return output
    }

    var currentPercentage: String {
        let output = "Current: \(formatPercentage(state.currentTime, total: state.totalDuration))"
        print(output)
        return output
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
    }

    func shiftTime(to time: CGFloat) {
        let shift = time - state.selectedRange.start
        state.updateTrimmerRange(by: shift)
    }
    
    func togglePlayPause() {
        playbackManager.togglePlayPause()
        isPlaying = playbackManager.isPlaying
    }

    func resetToStart() {
        state.resetCurrentTime()
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

        state.updateTotalDuration(value: settings.totalDuration)
        state.updateKeyTimes(settings.keyTimes)

        if let duration = settings.timelineDuration {
            state.updateSelectedRangeDuration(duration)
        }
    }

    // MARK: - Private Methods
    private func formatTime(_ seconds: CGFloat) -> String {
        let totalSeconds = Int(seconds)
        return String(format: "%1d:%02d", totalSeconds / 60, totalSeconds % 60)
    }

    private func formatPercentage(_ value: CGFloat, total: CGFloat) -> String {
        String(format: "%.1f%%", (value / total) * 100)
    }

    private func updateCurrentTime(by interval: TimeInterval) {
        state.updateCurrentTime(by: CGFloat(interval))
    }
}

// MARK: - PlaybackManagerDelegate
extension MusicEditorViewModel: PlaybackManagerDelegate {
    func playbackManagerDidUpdateTime(by interval: TimeInterval) {
        updateCurrentTime(by: interval)
    }
}
