//
//  WaveformContentView.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/11/17.
//

import SwiftUI

struct WaveformContentView: View {
    // MARK: Properties - Data from parent
    let barStates: [WaveformBarData]
    
    // MARK: UI Properties
    private enum UIConstants {
        static let lineWidth: CGFloat = 3
        static let gap: CGFloat = 3
        static let minHeightRatio: CGFloat = 0.3
        static let maxHeightRatio: CGFloat = 0.6
    }

    // MARK: Body
    var body: some View {
        HStack(alignment: .center, spacing: UIConstants.gap) {
            ForEach(barStates.indices, id: \.self) { i in
                let amplitude = barStates[i].amplitude
                let height = calculateBarHeight(amplitude: amplitude, containerHeight: 60)

                Rectangle()
                    .fill(.white)
                    .frame(width: UIConstants.lineWidth,
                           height: height)
            }
        }
    }
}


// MARK: Get ContentView Height
extension WaveformContentView {
    func calculateBarHeight(amplitude: CGFloat, containerHeight: CGFloat) -> CGFloat {
        let ratio = UIConstants.minHeightRatio
                 + (UIConstants.maxHeightRatio - UIConstants.minHeightRatio) * amplitude
        return containerHeight * ratio
    }
}
