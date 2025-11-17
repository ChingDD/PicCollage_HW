//
//  AudioTrimmerScreen.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/11/11.
//

import SwiftUI

struct AudioTrimmerScreen: View {
    // MARK: ViewModel
    @ObservedObject var viewModel: MusicEditorViewModel
    
    // MARK: Property
    @State private var startTimeRatio: CGFloat = 0.0
    @State private var allowUpdate = false  //  whether the scrollView's position should be programmatically updated
    @State private var currentTime: CGFloat = 0.0
    @State private var isPlaying: Bool = false
    
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
        .onChange(of: isPlaying) { oldValue, newValue in
            // Sync isPlaying state with ViewModel
            if newValue != viewModel.isPlaying {
                viewModel.togglePlayPause()
            }
        }
        .onReceive(viewModel.$state) { newState in
            // Update currentTime from ViewModel
            currentTime = newState.currentTime
        }
        .onReceive(viewModel.$isPlaying) { newValue in
            // Sync ViewModel's isPlaying to local state
            if newValue != isPlaying {
                isPlaying = newValue
            }
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
            currentTime: $currentTime,
            isPlaying: $isPlaying,
            totalDuration: viewModel.state.totalDuration,
            selectedRangeDuration: viewModel.state.selectedRange.duration,
            onResetTapped: {
                viewModel.resetToStart()
            }
        )
    }
}
