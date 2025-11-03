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

    // Observable properties for view binding
    let currentTime: ObservableObject<CGFloat> = ObservableObject(value: 0)
    let start: ObservableObject<CGFloat> = ObservableObject(value: 0)
    let end: ObservableObject<CGFloat> = ObservableObject(value: 0)
    let totalDuration: ObservableObject<CGFloat> = ObservableObject(value: 0)

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

    init(state: MusicStateModel) {
        self.state = state
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

    func updateTimeFromScrollOffset(
        contentOffsetX: CGFloat,
        contentInsetLeft: CGFloat,
        contentInsetRight: CGFloat,
        contentSizeWidth: CGFloat,
        scrollViewWidth: CGFloat
    ) {
        // Start from 0
        let adjustedOffset = contentOffsetX + contentInsetLeft
        
        // Changeable width
        let scrollableWidth = contentSizeWidth + contentInsetLeft + contentInsetRight - scrollViewWidth
        
        // Changeable duration
        let totalDuration = state.totalDuration
        let selectedRangeDuration = state.selectedRange.duration
        let changeableDuration = totalDuration - selectedRangeDuration

        guard scrollableWidth > 0 else { return }
        
        let currentStart = adjustedOffset / scrollableWidth * changeableDuration

        shiftTime(to: currentStart)
    }

    // MARK: - Private Methods

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
