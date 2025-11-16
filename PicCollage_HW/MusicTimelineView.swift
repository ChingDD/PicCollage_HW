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
    
    @Binding var startTimeRatio: CGFloat

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
        StrollViewContainer(startTimeRatio: $startTimeRatio,
                            totalDuration: totalDuration,
                            selectedRangeDuration: selectedRangeDuration)
        .padding(.bottom)
    }
}

// MARK: - StrollViewContainer
struct StrollViewContainer: View {
    @Binding var startTimeRatio: CGFloat

    var totalDuration: CGFloat
    var selectedRangeDuration: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            let contentSizeWidth = (geometry.size.width *  MusicTimelineView.UIConstants.selectedRangeWidthRatio) / (selectedRangeDuration / totalDuration)
            
            ZStack(alignment: .center) {
                // ScrollView
                ScrollView(.horizontal, showsIndicators: false) {
                    Color.cyan
                        .frame(width: contentSizeWidth,
                               height: MusicTimelineView.UIConstants.scrollViewHeight)
                        .padding(MusicTimelineView.UIConstants.contentInsetRatio * geometry.size.width)
                        .background(
                            GeometryReader { scrollGeo in
                                Color.clear
                                    .preference(key: ScrollOffsetPreferenceKey.self,
                                              value: scrollGeo.frame(in: .named("scroll")).minX)
                            }
                        )
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                    let newRatio = updateStartTimeRatio(scrollOffset: offset, contentSizeWidth: contentSizeWidth)
                    startTimeRatio = newRatio
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
    
    private func updateStartTimeRatio(scrollOffset: CGFloat, contentSizeWidth: CGFloat) -> CGFloat {
        let ratio = calculateRatio(from: scrollOffset, contentSizeWidth: contentSizeWidth)
        return ratio
    }

    private func calculateRatio(from offset: CGFloat, contentSizeWidth: CGFloat) -> CGFloat {
        let ratio = max(0, min(1, -offset / contentSizeWidth))
        return ratio
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
//    MusicTimelineView(startTimeRatio:, totalDuration: 80, selectedRangeDuration: 10)
}
