//
//  TimeRangeModel.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/10/29.
//

import Foundation

struct TrimmerRangeModel {
    var start: Int
    var end: Int
    var duration: Int = 10
    
    func shift(by offset: Int, totalDuration: Int) -> TrimmerRangeModel {
        let newStart = start + offset
        let newEnd = end + offset
        if newStart < 0 {
            return TrimmerRangeModel(start: 0, end: totalDuration - offset, duration: duration)
        } else if newEnd > totalDuration {
            return TrimmerRangeModel(start: totalDuration - duration, end: totalDuration, duration: duration)
        } else {
            return TrimmerRangeModel(start: newStart, end: newEnd, duration: duration)
        }
    }
}
