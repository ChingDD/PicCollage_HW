//
//  MusicStateModel.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/10/29.
//

import Foundation

struct ScrollParameters {
    let scrollableWidth: CGFloat
    let changeableDuration: CGFloat
}

struct MusicStateModel {
    var totalDuration: CGFloat
    var currentTime: CGFloat
    var keyTimes: [CGFloat]
    var selectedRange: TrimmerRangeModel

    mutating func updateTotalDurarion(value: CGFloat) {
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
}
