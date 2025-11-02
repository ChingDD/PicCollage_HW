//
//  MusicStateModel.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/10/29.
//

import Foundation

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
}
