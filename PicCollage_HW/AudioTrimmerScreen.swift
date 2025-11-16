//
//  AudioTrimmerScreen.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/11/11.
//

import SwiftUI

struct AudioTrimmerScreen: View {
    // MARK: ViewModel
    @StateObject var viewModel: MusicEditorViewModel
    
    // MARK: Property
    @State private var startTimeRatio: CGFloat = 0.0
    @State private var allowUpdate = false  //  whether the scrollView’s position should be programmatically updated
    
    // MARK: Call Back
    var onSettingsTapped: () -> Void
    
    // MARK: Body
    var body: some View {
        ZStack() {
            Color(.black)
            
            VStack {
                keyTimeSelectionView
                musicTimelineView
            }

            /* maxWidth: .infinity & maxHeight: .infinity
                -> Wrap the button in a full-sized container, so the alignment can position it in the corner.
            */
            settingButton
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity,
                       alignment: .topLeading)
                .padding(.top, 20)
                .padding(.leading, 20)
        }
        .onChange(of: startTimeRatio) { oldValue, newValue in
            // Convert ratio to absolute time and update ViewModel
            let newTime = newValue * viewModel.state.totalDuration
            viewModel.shiftTime(to: newTime)
        }
    }
}

// MARK: Preview
#Preview {
    let musicState = MusicStateModel(
        totalDuration: 80.0,
        currentTime: 0.0,
        keyTimes: [16.0, 40.0, 48.0, 72.0],
        selectedRange: TrimmerRangeModel(start: 0.0, duration: 10.0)
    )
    let viewModel = MusicEditorViewModel(state: musicState)
    AudioTrimmerScreen(viewModel: viewModel, onSettingsTapped: {})
}

// MARK: Subviews
extension AudioTrimmerScreen {
    var keyTimeSelectionView: some View {
        KeyTimeSelectionView(
            keyTimePercentage: viewModel.keyTimeRatio,
            durationRatio: viewModel.durationRatio,
            sectionTimeline: viewModel.sectionTimeline,
            currentTimeline: viewModel.currentTimeline,
            sectionPercentage: viewModel.sectionPercentage,
            currentPercentage: viewModel.currentPercentage,
            startTimeRatio: $startTimeRatio,
            allowUpdate: $allowUpdate
        )
    }
    
    var settingButton: some View {
        Button(action: {
            onSettingsTapped()
        }) {
            Image(systemName: "gear")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundStyle(Color.white)
        }
    }
    
    var musicTimelineView: some View {
        MusicTimelineView(
            startTimeRatio: $startTimeRatio,
            allowUpdate: $allowUpdate,
            totalDuration: viewModel.state.totalDuration,
            selectedRangeDuration: viewModel.state.selectedRange.duration
        )
    }
}
