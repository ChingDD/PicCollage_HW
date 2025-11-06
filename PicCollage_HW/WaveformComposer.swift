//
//  WaveformComposer.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/11/5.
//

import UIKit

struct WaveformComposer {
    private enum UIConstants {
        static let lineWidth: CGFloat = 3
        static let gap: CGFloat = 3
        static let minHeightRatio: CGFloat = 0.3
        static let maxHeightRatio: CGFloat = 0.6
    }

    struct WaveformCanvas {
        let containerView: UIView
        let barViews: [UIView]
        let heightConstraints: [NSLayoutConstraint]
    }

    // MARK: - Public Methods

    static func makeWaveformCanvas(barStates: [WaveformBarState], height: CGFloat) -> WaveformCanvas {
        let containerView = UIView()
        containerView.backgroundColor = .clear

        var barViews: [UIView] = []
        var heightConstraints: [NSLayoutConstraint] = []
        let width = calculateWidth(barCount: barStates.count)

        for i in barStates.indices {
            let barState = barStates[i]

            // Create bar view
            let bar = UIView()
            bar.backgroundColor = .white
            bar.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(bar)

            // Calculate bar height from amplitude
            let barHeight = calculateBarHeight(amplitude: barState.amplitude, containerHeight: height)
            let heightConstraint = bar.heightAnchor.constraint(equalToConstant: barHeight)

            // Layout constraints
            NSLayoutConstraint.activate([
                bar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,
                                             constant: (CGFloat(i+1) * UIConstants.lineWidth + CGFloat(i) * UIConstants.gap)),
                bar.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                bar.widthAnchor.constraint(equalToConstant: UIConstants.lineWidth),
                heightConstraint
            ])

            barViews.append(bar)
            heightConstraints.append(heightConstraint)
        }

        containerView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        return WaveformCanvas(containerView: containerView, barViews: barViews, heightConstraints: heightConstraints)
    }

    static func calculateBarCount(width: CGFloat) -> Int {
        return Int((width - UIConstants.lineWidth) / (UIConstants.lineWidth + UIConstants.gap))
    }

    static func calculateWidth(barCount: Int) -> CGFloat {
        return CGFloat(barCount + 1) * UIConstants.lineWidth + CGFloat(barCount) * UIConstants.gap
    }

    static func calculateBarHeight(amplitude: CGFloat, containerHeight: CGFloat) -> CGFloat {
        let ratio = UIConstants.minHeightRatio + (UIConstants.maxHeightRatio - UIConstants.minHeightRatio) * amplitude
        return containerHeight * ratio
    }

    static func getBarWidth() -> CGFloat {
        return UIConstants.lineWidth
    }

    static func getGap() -> CGFloat {
        return UIConstants.gap
    }
}
