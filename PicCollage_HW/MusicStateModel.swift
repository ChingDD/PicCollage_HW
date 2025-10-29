//
//  MusicStateModel.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/10/29.
//

import Foundation

struct MusicStateModel {
    var totalDuration: Int
    var currentTime: Int
    var keyTimes: [Int]
    var selectedRange: TrimmerRangeModel
    
    mutating func updateTotalDurarion(value: Int) {
        totalDuration = value
    }
    
    mutating func updateCurrentTime(start: Int, offset: Int) {
        currentTime = start + offset
    }
}
