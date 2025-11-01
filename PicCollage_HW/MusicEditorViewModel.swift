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
    let currentTime: ObservableObject<Int> = ObservableObject(value: 0)
    let start: ObservableObject<Int> = ObservableObject(value: 0)
    let end: ObservableObject<Int> = ObservableObject(value: 0)
    let totalDuration: ObservableObject<Int> = ObservableObject(value: 0)

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

    func shiftTime(to time: Int) {
        let shift = time - state.selectedRange.start
        state.updateTrimmerRange(by: shift)
        updateObservables()
    }

    func updateTotalDuration(_ duration: Int) {
        state.updateTotalDurarion(value: duration)
        updateObservables()
    }

    // MARK: - Private Methods

    private func updateObservables() {
        currentTime.value = state.currentTime
        start.value = state.selectedRange.start
        end.value = state.selectedRange.end
        totalDuration.value = state.totalDuration
    }

    private func formatTime(_ seconds: Int) -> String {
        String(format: "%1d:%02d", seconds / 60, seconds % 60)
    }

    private func formatPercentage(_ value: Int, total: Int) -> String {
        String(format: "%.1f%%", CGFloat(value) / CGFloat(total) * 100)
    }
}
