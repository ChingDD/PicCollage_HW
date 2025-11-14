//
//  AudioTrimmerScreen.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/11/11.
//

import SwiftUI

struct AudioTrimmerScreen: View {
    @StateObject var viewModel: MusicEditorViewModel
    @State private var startTimeRatio: CGFloat = 0.0

    // MARK: Body
    var body: some View {
        VStack {
            keyTimeSelectionView
        }
        .background(Color.black)
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
    AudioTrimmerScreen(viewModel: viewModel)
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
            startTimeRatio: $startTimeRatio
        )
    }
}
