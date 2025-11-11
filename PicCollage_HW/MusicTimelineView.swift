//
//  MusicTimelineView.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/11/11.
//

import SwiftUI

// MARK: - Main Timeline View

struct MusicTimelineView: View {
    var viewModel: WaveformViewModel

    // Scroll offset tracking
    @State private var scrollOffset: CGFloat = 0
    @State private var progressRatio: CGFloat = 0

    // UI Constants
    enum UIConstants {
        static let selectedRangeViewBorderWidth: CGFloat = 3
        static let contentInsetRatio: CGFloat = 0.25          // 25%
        static let selectedRangeWidthRatio: CGFloat = 0.5     // 50%
        static let scrollViewHeightRatio: CGFloat = 1/2.5
        static let barWidth: CGFloat = 3
        static let barGap: CGFloat = 3
    }

    // Callbacks
    var onScrollOffsetChanged: ((CGFloat) -> Void)?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black.ignoresSafeArea()

                VStack {
                    Spacer()

                    // Waveform Container
                    ZStack(alignment: .center) {
                        // Scrollable Waveform Canvas
                        WaveformScrollView(
                            viewModel: viewModel,
                            scrollOffset: $scrollOffset,
                            geometry: geometry,
                            onScrollChanged: { offset in
                                onScrollOffsetChanged?(offset)
                            }
                        )
                        .frame(height: geometry.size.height * UIConstants.scrollViewHeightRatio)

                        // Selected Range View with Gradient Border
                        SelectedRangeView(
                            progressRatio: progressRatio,
                            borderWidth: UIConstants.selectedRangeViewBorderWidth
                        )
                        .frame(
                            width: geometry.size.width * UIConstants.selectedRangeWidthRatio,
                            height: geometry.size.height * UIConstants.scrollViewHeightRatio
                        )
                    }

                    Spacer()
                }
            }
        }
    }

    // Public methods to match UIKit API
    func setScrollOffset(_ offsetX: CGFloat) {
        scrollOffset = offsetX
    }

    func updateProgressView(ratio: CGFloat) {
        progressRatio = ratio
    }
}

// MARK: - Waveform Scroll View

struct WaveformScrollView: View {
    var viewModel: WaveformViewModel
    @Binding var scrollOffset: CGFloat
    let geometry: GeometryProxy
    let onScrollChanged: ((CGFloat) -> Void)?

    @State private var canvasWidth: CGFloat = 0

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MusicTimelineView.UIConstants.barGap) {
                    ForEach(viewModel.bars.indices, id: \.self) { index in
                        WaveformBarView(barState: viewModel.bars[index])
                            .id(index)
                    }
                }
                .frame(height: geometry.size.height * MusicTimelineView.UIConstants.scrollViewHeightRatio)
                .padding(.horizontal, geometry.size.width * MusicTimelineView.UIConstants.contentInsetRatio)
                .background(
                    GeometryReader { scrollGeometry in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: scrollGeometry.frame(in: .named("waveformScrollView")).origin.x
                        )
                    }
                )
            }
            .coordinateSpace(name: "waveformScrollView")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                let newOffset = -value
                if scrollOffset != newOffset {
                    scrollOffset = newOffset
                    onScrollChanged?(newOffset)
                }
            }
        }
    }
}

// MARK: - Selected Range View

struct SelectedRangeView: View {
    let progressRatio: CGFloat
    let borderWidth: CGFloat

    var body: some View {
        ZStack(alignment: .leading) {
            // Background with semi-transparent gray
            Rectangle()
                .fill(Color(red: 153/255, green: 152/255, blue: 156/255, opacity: 0.3))

            // Progress View (green overlay)
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.green)
                    .frame(width: max(0, (geometry.size.width - borderWidth * 2) * progressRatio))
                    .offset(x: borderWidth, y: borderWidth)
            }
            .padding(.vertical, borderWidth)
        }
        .overlay(
            // Gradient Border (Orange → Purple)
            RoundedRectangle(cornerRadius: 0)
                .strokeBorder(
                    LinearGradient(
                        gradient: Gradient(colors: [.orange, .purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: borderWidth
                )
        )
    }
}

// MARK: - Waveform Bar View

struct WaveformBarView: View {
    let barState: WaveformBarState

    var body: some View {
        Rectangle()
            .fill(Color(white: barState.brightness))
            .frame(width: MusicTimelineView.UIConstants.barWidth)
            .scaleEffect(x: 1.0, y: barState.scale, anchor: .center)
            .animation(.easeInOut(duration: 0.1), value: barState.scale)
            .animation(.easeInOut(duration: 0.1), value: barState.brightness)
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
    // Create mock view model for preview
    let viewModel = WaveformViewModel(amplitudes: (0..<300).map { _ in CGFloat.random(in: 0...1) })

    // Add some sample bars
//    for _ in 0..<100 {
//        viewModel.bars.append(
//            WaveformBarState(
//                amplitude: Double.random(in: 0.3...1.0),
//                scale: 1.0,
//                brightness: 0.7
//            )
//        )
//    }

    MusicTimelineView(
        viewModel: viewModel,
        onScrollOffsetChanged: { offset in
            print("Scroll offset: \(offset)")
        }
    )
    .frame(height: 300)
}
