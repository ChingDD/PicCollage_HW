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

    // MARK: Binding - Two-way data binding
    @Binding var startTimeRatio: CGFloat
    @Binding var allowUpdate: Bool
    @Binding var currentTime: CGFloat
    @Binding var isPlaying: Bool

    var totalDuration: CGFloat
    var selectedRangeDuration: CGFloat
    var onResetTapped: () -> Void
    
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
        StrollViewContainer(startTimeRatio: $startTimeRatio,
                            allowUpdate: $allowUpdate,
                            currentTime: $currentTime,
                            totalDuration: totalDuration,
                            selectedRangeDuration: selectedRangeDuration)
        .padding(.bottom)
    }
}


// MARK: - StrollViewContainer
struct StrollViewContainer: View {
    @State private var isDragging: Bool = false
    @State private var position = ScrollPosition()
    @State private var timer: Timer?
    
    @Binding var startTimeRatio: CGFloat
    @Binding var allowUpdate: Bool
    @Binding var currentTime: CGFloat

    var totalDuration: CGFloat
    var selectedRangeDuration: CGFloat
    
    // Computed Properties
    var start: CGFloat {
        startTimeRatio * totalDuration
    }
    var end: CGFloat {
        start + selectedRangeDuration
    }
    
    var body: some View {
        GeometryReader { geometry in
            let durationRatio = selectedRangeDuration / totalDuration
            let contentSizeWidth = (geometry.size.width *  MusicTimelineView.UIConstants.selectedRangeWidthRatio) / durationRatio

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
                        .id("scrollContent")
                }
                .scrollPosition($position)
                .coordinateSpace(name: "scroll")
                // When user is dragging scrollView，update data actively
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                    guard isDragging else { return }
                    
                    // reset timer
                    self.timer?.invalidate()
                    self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                        // When finish dragging，reset flag
                        isDragging = false
                    }
                    
                    var newRatio = updateStartTimeRatio(scrollOffset: offset, contentSizeWidth: contentSizeWidth)

                    if newRatio + durationRatio > 1.0 {
                        newRatio = 1.0 - durationRatio
                    }

                    startTimeRatio = newRatio
                }
                // Monitor dragging gesture
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { _ in isDragging = true }
                )

                .onChange(of: startTimeRatio) { oldValue, newValue in
                    guard allowUpdate else { return }
                    allowUpdate = false

                    let targetOffset = newValue * contentSizeWidth

                    withAnimation(.easeOut(duration: 0.2)) {
                        position = ScrollPosition(x: targetOffset)
                    }
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
                        
                        // Progress
                        GeometryReader { progressGeo in
                            let maxWidth = progressGeo.size.width
                            let progressRatio = min(max((currentTime - start) / selectedRangeDuration, 0), 1)

                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.green)
                                .frame(width: maxWidth * progressRatio,
                                       height: MusicTimelineView.UIConstants.scrollViewHeight)
                        }
                        .padding(MusicTimelineView.UIConstants.selectedRangeViewBorderWidth)
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
