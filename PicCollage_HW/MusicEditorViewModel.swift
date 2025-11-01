//
//  MusicEditorViewModel.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/10/29.
//

import Foundation

class MusicEditorViewModel {
    var state: MusicStateModel
    
    var currentTime: ObservableObject<Int> = ObservableObject(value: 0)
    var start: ObservableObject<Int> = ObservableObject(value: 0)
    var end: ObservableObject<Int> = ObservableObject(value: 0)
    var totalDuration: ObservableObject<Int> = ObservableObject(value: 0)
    
    var sectionTimeline: String {
        let range = state.selectedRange
        let startTimeline = String(format: "%1d:%02d", range.start / 60, range.start % 60)
        let endTimeline = String(format: "%1d:%02d", range.end / 60, range.end % 60)
        return "Selected: \(startTimeline) - \(endTimeline)"
    }
    
    var currentTimeline: String {
        "Current: \(String(format: "%01d:%02d", state.currentTime / 60, state.currentTime % 60))"
    }
    
    var sectionPercentage: String {
        let startTimeline = String(format: "%1d", state.selectedRange.start / state.totalDuration * 100)
        let endTimeline = String(format: "%1d", state.selectedRange.end / state.totalDuration * 100)
        return "Section: \(startTimeline) - \(endTimeline)"
    }
    
    var currentPercentage: String {
        "Current: \(String(format: "%1d", state.currentTime / state.totalDuration * 100))"
    }
        

    init (state: MusicStateModel) {
        self.state = state
    }
    
    func shiftTime(to time: Int) {
        let shift = time - state.selectedRange.start
        print("shift: \(shift)")
        state.updateTrimmerRange(by: shift)
        
        currentTime.value = state.currentTime
        start.value = state.selectedRange.start
        end.value = state.selectedRange.end
    }
    
    func updateTotalDuration(_ duration: Int) {
        state.updateTotalDurarion(value: duration)
        totalDuration.value = duration
    }
}
