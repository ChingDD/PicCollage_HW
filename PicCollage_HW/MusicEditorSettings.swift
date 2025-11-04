//
//  MusicEditorSettings.swift
//  PicCollage_HW
//
//  Created by Claude Code on 2025/11/5.
//

import Foundation

// Data model for music editor settings
// Handles conversion between percentages and absolute time values
struct MusicEditorSettings {
    let totalDuration: CGFloat
    let keyTimePercentages: [CGFloat]
    let timelineLengthPercentage: CGFloat?

    // MARK: - Computed Properties

    // Convert key time percentages to absolute time values
    var keyTimes: [CGFloat] {
        return keyTimePercentages.map { ($0 / 100) * totalDuration }
    }

    // Convert timeline percentage to absolute duration
    var timelineDuration: CGFloat? {
        guard let percentage = timelineLengthPercentage else { return nil }
        return (percentage / 100) * totalDuration
    }

    // MARK: - Initialization

    // Initialize with absolute values (from ViewModel state)
    init(totalDuration: CGFloat, keyTimes: [CGFloat], selectedRangeDuration: CGFloat) {
        self.totalDuration = totalDuration
        self.keyTimePercentages = keyTimes.map { ($0 / totalDuration) * 100 }
        self.timelineLengthPercentage = (selectedRangeDuration / totalDuration) * 100
    }

    // Initialize with user input (from UI)
    init(totalDuration: CGFloat, keyTimePercentages: [CGFloat], timelineLengthPercentage: CGFloat?) {
        self.totalDuration = totalDuration
        self.keyTimePercentages = keyTimePercentages
        self.timelineLengthPercentage = timelineLengthPercentage
    }

    // MARK: - Validation

    // Validate all settings using SettingsValidator
    func validate() throws {
        try SettingsValidator.validateTotalDuration(totalDuration)

        for percentage in keyTimePercentages {
            try SettingsValidator.validatePercentage(percentage, allowEmpty: false)
        }

        try SettingsValidator.validateTimelinePercentage(timelineLengthPercentage)
    }
}
