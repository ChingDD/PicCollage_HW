//
//  WaveformViewModel.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/11/6.
//

import Foundation

class WaveformViewModel {
    private(set) var bars: [WaveformBarState] = []
    private(set) var onBarsUpdated = ObservableObject<Void>(value: ())

    init(amplitudes: [CGFloat]) {
        bars = amplitudes.map { WaveformBarState(amplitude: $0, scale: 1.0, brightness: 1.0) }
    }

    func adjustBarCount(to targetCount: Int) {
        let currentCount = bars.count

        if targetCount > currentCount {
            // Generate new random bars
            let newBars = (0..<(targetCount - currentCount)).map { _ in
                WaveformBarState(amplitude: CGFloat.random(in: 0...1), scale: 1.0, brightness: 1.0)
            }
            bars.append(contentsOf: newBars)
        } else if targetCount < currentCount {
            // Truncate bars
            bars = Array(bars.prefix(targetCount))
        }
        // If equal, no change needed
    }

    func update(for visibleFrame: CGRect, selectedFrame: CGRect, barWidth: CGFloat, gap: CGFloat) {
        for i in bars.indices {
            let barX = CGFloat(i) * (barWidth + gap)
            let barFrame = CGRect(x: barX,
                                  y: 0,
                                  width: barWidth,
                                  height: 1)

            // 1️⃣ 計算與 selected 區域的重疊
            let intersection = barFrame.intersection(selectedFrame)
            let overlapRatio = max(0, intersection.width / barFrame.width)

            // 2️⃣ 計算亮度（重疊越多越亮）
            let brightness = 0.3 + 0.7 * overlapRatio

            // 3️⃣ 計算縮放（越靠近選擇區中心越大）
            let barCenterX = barFrame.midX
            let rangeCenterX = selectedFrame.midX
            let distance = abs(barCenterX - rangeCenterX)
            let maxDistance = selectedFrame.width / 2
            let normalized = max(0, 1 - distance / maxDistance)
            let scale = 1 + 0.4 * normalized

            bars[i].brightness = brightness
            bars[i].scale = scale
        }
        onBarsUpdated.value = ()
    }
}
