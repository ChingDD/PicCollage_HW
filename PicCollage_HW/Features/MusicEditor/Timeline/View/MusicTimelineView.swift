//
//  MusicTimelineView.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/11/11.
//

import SwiftUI

// MARK: - Main Timeline View

struct MusicTimelineView: View {
    // MARK: Binding - Two-way data binding
    @Binding var startTimeRatio: CGFloat
    @Binding var allowUpdate: Bool
    @Binding var currentTime: CGFloat
    @Binding var isPlaying: Bool
    
    // MARK: Properties - Data from parent
    var totalDuration: CGFloat
    var selectedRangeDuration: CGFloat
    var onResetTapped: () -> Void
    
    // MARK: UI Constants
    enum UIConstants {
        static let selectedRangeViewBorderWidth: CGFloat = 3
        static let contentInsetRatio: CGFloat = 0.25          // 25%
        static let selectedRangeWidthRatio: CGFloat = 0.5     // 50%
        static let scrollViewHeightRatio: CGFloat = 1/2.5
        static let barWidth: CGFloat = 3
        static let barGap: CGFloat = 3
        static let scrollViewHeight: CGFloat = 60
    }
    
    // MARK: Body
    var body: some View {
        VStack {
            // ScrollView
            scrollViewContainer
            // Button
            buttons
        }
        .background(Color.myDarkGray)
    }
}

// MARK: Subviews
extension MusicTimelineView {
    // Button
    var buttons: some View {
        HStack {
            // Playing Button
            Button(action: {
                isPlaying.toggle()
            }) {
                Text(isPlaying ? "Pause" : "Play")
                    .foregroundStyle(Color.white)
            }
            .buttonStyle(.borderedProminent)
            .cornerRadius(5)
            .padding(.trailing)

            // Reset Button
            Button(action: {
                onResetTapped()
            }) {
                Text("reset")
                    .foregroundStyle(Color.white)
            }
            .background(Color.gray)
            .buttonStyle(.bordered)
            .cornerRadius(5)
        }
    }
    
    // ScrollView
    var scrollViewContainer: some View {
        ScrollViewContainer(startTimeRatio: $startTimeRatio,
                            allowUpdate: $allowUpdate,
                            currentTime: $currentTime,
                            totalDuration: totalDuration,
                            selectedRangeDuration: selectedRangeDuration)
        .padding(.bottom)
    }
}

// MARK: - Preview
#Preview {
    MusicTimelineView(startTimeRatio: .constant(0),
                      allowUpdate: .constant(false),
                      currentTime: .constant(0),
                      isPlaying: .constant(false),
                      totalDuration: 80,
                      selectedRangeDuration: 10,
                      onResetTapped: {})
}
