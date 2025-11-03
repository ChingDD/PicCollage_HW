//
//  MusicEditorViewModel.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/10/29.
//

import Foundation

class MusicEditorViewModel {
    // Single source of truth
    private(set) var state: MusicStateModel

    // Playback management
    private let playbackManager: PlaybackManager

    // Observable properties for view binding
    let currentTime: ObservableObject<CGFloat> = ObservableObject(value: 0)
    let start: ObservableObject<CGFloat> = ObservableObject(value: 0)
    let end: ObservableObject<CGFloat> = ObservableObject(value: 0)
    let totalDuration: ObservableObject<CGFloat> = ObservableObject(value: 0)
    let isPlaying: ObservableObject<Bool> = ObservableObject(value: false)

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

    init(state: MusicStateModel, playbackManager: PlaybackManager = PlaybackManager()) {
        self.state = state
        self.playbackManager = playbackManager
        self.playbackManager.delegate = self
        updateObservables()
    }

    func shiftTime(to time: CGFloat) {
        let shift = time - state.selectedRange.start
        state.updateTrimmerRange(by: shift)
        updateObservables()
    }

    func updateTotalDuration(_ duration: CGFloat) {
        state.updateTotalDurarion(value: duration)
        updateObservables()
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
        isPlaying.value = playbackManager.isPlaying
    }
    
    func updateCurrentTime(by interval: TimeInterval) {
        state.updateCurrentTime(by: CGFloat(interval))
        updateObservables()
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

    private func updateObservables() {
        currentTime.value = state.currentTime
        start.value = state.selectedRange.start
        end.value = state.selectedRange.end
        totalDuration.value = state.totalDuration
    }

    private func formatTime(_ seconds: CGFloat) -> String {
        let totalSeconds = Int(seconds)
        return String(format: "%1d:%02d", totalSeconds / 60, totalSeconds % 60)
    }

    private func formatPercentage(_ value: CGFloat, total: CGFloat) -> String {
        String(format: "%.1f%%", (value / total) * 100)
    }
}

// MARK: - PlaybackManagerDelegate
extension MusicEditorViewModel: PlaybackManagerDelegate {
    func playbackManagerDidUpdateTime(by interval: TimeInterval) {
        updateCurrentTime(by: interval)
    }
}
