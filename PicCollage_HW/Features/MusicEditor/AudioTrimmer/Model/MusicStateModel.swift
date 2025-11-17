//
//  MusicStateModel.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/10/29.
//

import Foundation

struct MusicStateModel {
    private(set) var totalDuration: CGFloat
    private(set) var currentTime: CGFloat
    private(set) var keyTimes: [CGFloat]
    private(set) var selectedRange: TrimmerRangeModel

    mutating func updateTotalDuration(value: CGFloat) {
        totalDuration = value
    }

    mutating func updateTrimmerRange(by: CGFloat) {
        let oldStart = selectedRange.start
        let newRange = selectedRange.shift(by: by, totalDuration: totalDuration)
        selectedRange = newRange
        currentTime += newRange.start - oldStart
    }
    
    mutating func updateCurrentTime(by interval: CGFloat) {
        if !(currentTime >= selectedRange.end) {
            currentTime += interval
        } else {
            currentTime = selectedRange.start
        }
    }

    mutating func resetCurrentTime() {
        currentTime = selectedRange.start
    }

    mutating func updateKeyTimes(_ newKeyTimes: [CGFloat]) {
        keyTimes = newKeyTimes
    }

    mutating func updateSelectedRangeDuration(_ duration: CGFloat) {
        selectedRange.duration = duration
        // Ensure current time stays within bounds
        if currentTime < selectedRange.start {
            currentTime = selectedRange.start
        } else if currentTime > selectedRange.end {
            currentTime = selectedRange.end
        }
    }
}
