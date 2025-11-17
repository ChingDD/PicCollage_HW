//
//  WaveformContentView.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/11/17.
//

import SwiftUI

struct WaveformContentView: View {
    let barStates: [WaveformBarState]
    
    private enum UIConstants {
        static let lineWidth: CGFloat = 3
        static let gap: CGFloat = 3
        static let minHeightRatio: CGFloat = 0.3
        static let maxHeightRatio: CGFloat = 0.6
    }

    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .center, spacing: UIConstants.gap) {
                ForEach(barStates.indices, id: \.self) { i in
                    let amplitude = barStates[i].amplitude
                    let height = calculateBarHeight(amplitude: amplitude, containerHeight: geo.size.height)

                    Rectangle()
                        .fill(.white)
                        .frame(width: UIConstants.lineWidth,
                               height: height)
                }
            }
            .frame(width: calculateWidth(barCount: barStates.count),
                   height: geo.size.height,
                   alignment: .center)
        }
        .frame(height: 100)  // 你可從外部設定
    }
}

extension WaveformContentView {
    func calculateWidth(barCount: Int) -> CGFloat {
        CGFloat(barCount) * (UIConstants.lineWidth + UIConstants.gap) + UIConstants.lineWidth
    }

    func calculateBarHeight(amplitude: CGFloat, containerHeight: CGFloat) -> CGFloat {
        let ratio = UIConstants.minHeightRatio
                 + (UIConstants.maxHeightRatio - UIConstants.minHeightRatio) * amplitude
        return containerHeight * ratio
    }
}
