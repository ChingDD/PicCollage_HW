//
//  MusicTimelineView.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/11/11.
//

import SwiftUI

// MARK: - Main Timeline View

struct MusicTimelineView: View {
    // Scroll offset tracking
    @State private var scrollOffset: CGFloat = 0
    @State private var progressRatio: CGFloat = 0

    var totalDuration: CGFloat
    var selectedRangeDuration: CGFloat
    
    // Button
    var isPlaying: Bool = false
    
    // UI Constants
    enum UIConstants {
        static let selectedRangeViewBorderWidth: CGFloat = 3
        static let contentInsetRatio: CGFloat = 0.25          // 25%
        static let selectedRangeWidthRatio: CGFloat = 0.5     // 50%
        static let scrollViewHeightRatio: CGFloat = 1/2.5
        static let barWidth: CGFloat = 3
        static let barGap: CGFloat = 3
        static let scrollViewHeight: CGFloat = 60
    }

    // Callbacks
    var onScrollOffsetChanged: ((CGFloat) -> Void)?

    var body: some View {
        VStack {
            // ScrollView
            scrollViewContainer
            // Button
            buttons
        }
        .background(Color.darkGray)
    }

    // Public methods to match UIKit API
    func setScrollOffset(_ offsetX: CGFloat) {
        scrollOffset = offsetX
    }

    func updateProgressView(ratio: CGFloat) {
        progressRatio = ratio
    }
}

// MARK: Subviews
extension MusicTimelineView {
    // Button
    var buttons: some View {
        HStack {
            // Playing Button
            Button(action: {
                
            }) {
                Text(isPlaying ? "Pause" : "Play")
                    .foregroundStyle(Color.white)
            }
            .buttonStyle(.borderedProminent)
            .cornerRadius(5)
            .padding(.trailing)
            
            // Playing Button
            Button(action: {
                
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
        StrollViewContainer(totalDuration: totalDuration,
                            selectedRangeDuration: selectedRangeDuration)
        .padding(.bottom)
    }
}

// MARK: - Waveform Scroll View
struct StrollViewContainer: View {
    var totalDuration: CGFloat
    var selectedRangeDuration: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                // ScrollView
                ScrollView(.horizontal) {
                    Color.cyan
                        .frame(width: (geometry.size.width *  MusicTimelineView.UIConstants.selectedRangeWidthRatio) / (selectedRangeDuration / totalDuration),
                               height: MusicTimelineView.UIConstants.scrollViewHeight)
                        .padding(MusicTimelineView.UIConstants.contentInsetRatio * geometry.size.width)
                }
                .frame(height:  MusicTimelineView.UIConstants.scrollViewHeight)
                .background(Color.yellow)
                
                // SelectedRangeView
                Rectangle()
                    .fill(.clear)
                    .frame(width: geometry.size.width * MusicTimelineView.UIConstants.selectedRangeWidthRatio,
                           height: MusicTimelineView.UIConstants.scrollViewHeight + MusicTimelineView.UIConstants.selectedRangeViewBorderWidth * 2)
                    .overlay {
                        // Gradient Border (Orange → Purple)
                        RoundedRectangle(cornerRadius: 5)
                            .strokeBorder(
                                LinearGradient(gradient: Gradient(colors: [.orange, .purple]),
                                               startPoint: .leading,
                                               endPoint: .trailing),
                                lineWidth: MusicTimelineView.UIConstants.selectedRangeViewBorderWidth
                            )
                    }
            }
            .frame(height:  MusicTimelineView.UIConstants.scrollViewHeight / MusicTimelineView.UIConstants.scrollViewHeightRatio)
            .background(Color.black)
        }
        .frame(height:  MusicTimelineView.UIConstants.scrollViewHeight / MusicTimelineView.UIConstants.scrollViewHeightRatio)
    }
}

// MARK: - Preference Key for Scroll Offset

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview

#Preview {
    MusicTimelineView(totalDuration: 80, selectedRangeDuration: 10)
}
