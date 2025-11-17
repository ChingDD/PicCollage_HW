//
//  ScrollViewContainer.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/11/17.
//

import SwiftUI

struct StrollViewContainer: View {
    @State private var isDragging: Bool = false
    @State private var position = ScrollPosition()
    @State private var timer: Timer?
    @State private var waveformStates: [WaveformBarData] = []
    @State private var lastContentWidth: CGFloat = 0

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
                    Color.white
//                    WaveformContentView(barStates: waveformStates)    // Custom View can't sync data
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
                .onAppear {
                    // Generate waveform states only once when view appears
                    if waveformStates.isEmpty {
                        waveformStates = generateWaveformStates(for: contentSizeWidth)
                        lastContentWidth = contentSizeWidth
                    }
                }
                .onChange(of: contentSizeWidth) { oldWidth, newWidth in
                    // Regenerate only when content width changes
                    if abs(newWidth - lastContentWidth) > 0.1 {
                        waveformStates = generateWaveformStates(for: newWidth)
                        lastContentWidth = newWidth
                    }
                }
                .frame(height:  MusicTimelineView.UIConstants.scrollViewHeight)
            
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
    
    private func calculateBarCount(for width: CGFloat) -> Int {
        let barWidth = 3.0
        let gap = 3.0
        return Int((width - barWidth) / (barWidth + gap))
    }
    
    private func generateWaveformStates(for width: CGFloat) -> [WaveformBarData] {
        let count = calculateBarCount(for: width)
        return (0..<count).map { _ in
            WaveformBarData(amplitude: CGFloat.random(in: 0...1))
        }
    }
}


// MARK: - Preference Key for Scroll Offset
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
