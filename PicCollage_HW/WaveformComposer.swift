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
    
    static func makeWaveformCanvas(width: CGFloat, height: CGFloat) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear

        // Create wave
        /*
         amplitude = 0    →  bar height = rangeViewRect.height * 0.3
         amplitude = 1    →  bar height = rangeViewRect.height * 0.6
         amplitude = 0.5  →  bar height = rangeViewRect.height * 0.45
         */
        let lineCount = Int((width - UIConstants.lineWidth) / (UIConstants.lineWidth + UIConstants.gap))
        let amplitudes: [CGFloat] = (0..<lineCount).map { _ in CGFloat.random(in: 0...1) }
        
        for i in amplitudes.indices {
            // UI
            let bar = UIView()
            bar.backgroundColor = .white
            bar.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(bar)
            
            // Properties
            let amplitude = amplitudes[i]
            let ratio = UIConstants.minHeightRatio + (UIConstants.maxHeightRatio - UIConstants.minHeightRatio) * amplitude
            let barHeight = height * ratio
            
            // Layout
            NSLayoutConstraint.activate([
                bar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,
                                             constant: (CGFloat(i+1) * UIConstants.lineWidth + CGFloat(i) * UIConstants.gap)),
                bar.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                bar.widthAnchor.constraint(equalToConstant: UIConstants.lineWidth),
                bar.heightAnchor.constraint(equalToConstant: barHeight)
            ])
        }
        
        containerView.frame = CGRect(x: 0,
                                     y: 0,
                                     width: width,
                                     height: height)
        return containerView
    }
}
