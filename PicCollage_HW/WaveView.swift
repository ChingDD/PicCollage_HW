//
//  WaveView.swift
//  PicCollage_HW
//
//  Created by 林仲景
//

import UIKit

/// 完整的波形視圖
/// 根據振幅陣列產生整體波形
class WaveView: UIView {

    // MARK: - Properties

    /// 所有的波形 bar
    private var barViews: [WaveBarView] = []

    /// Bar 的寬度
    private let barWidth: CGFloat

    /// Bar 之間的間距
    private let barSpacing: CGFloat

    /// 振幅陣列（0~1 的數值）
    private let amplitudes: [CGFloat]

    // MARK: - Initialization

    /// 初始化波形視圖
    /// - Parameters:
    ///   - amplitudes: 振幅陣列，每個值應該在 0~1 之間
    ///   - barWidth: 每個 bar 的寬度，預設 3
    ///   - barSpacing: bar 之間的間距，預設 2
    init(amplitudes: [CGFloat], barWidth: CGFloat = 3, barSpacing: CGFloat = 2) {
        self.amplitudes = amplitudes
        self.barWidth = barWidth
        self.barSpacing = barSpacing
        super.init(frame: .zero)
        setupBars()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        updateBarConstraints()
    }

    // MARK: - Setup

    private func setupBars() {
        backgroundColor = .clear

        for (_, amplitude) in amplitudes.enumerated() {
            // 計算 bar 的高度（相對於容器高度）
            let normalizedAmplitude = max(0.1, min(1.0, amplitude)) // 確保在 0.1~1 範圍
            let barHeight = normalizedAmplitude * 100 // 基準高度，會在 layoutSubviews 中調整

            let barView = WaveBarView(height: barHeight, width: barWidth)
            addSubview(barView)
            barViews.append(barView)
        }
    }

    private func updateBarConstraints() {
        guard !barViews.isEmpty else { return }

        let maxHeight = bounds.height

        for (index, barView) in barViews.enumerated() {
            let amplitude = amplitudes[index]
            let normalizedAmplitude = max(0.1, min(1.0, amplitude))
            let barHeight = normalizedAmplitude * maxHeight

            // 移除舊的約束（如果有）
            barView.constraints.forEach { barView.removeConstraint($0) }

            NSLayoutConstraint.activate([
                barView.widthAnchor.constraint(equalToConstant: barWidth),
                barView.heightAnchor.constraint(equalToConstant: barHeight),
                barView.centerYAnchor.constraint(equalTo: centerYAnchor),
                barView.leadingAnchor.constraint(
                    equalTo: leadingAnchor,
                    constant: CGFloat(index) * (barWidth + barSpacing)
                )
            ])
        }
    }

    // MARK: - Public Methods

    /// 計算整個波形視圖的總寬度
    var contentWidth: CGFloat {
        guard !amplitudes.isEmpty else { return 0 }
        return CGFloat(amplitudes.count) * (barWidth + barSpacing) - barSpacing
    }

    /// 更新指定索引的 bar 效果
    /// - Parameters:
    ///   - index: bar 的索引
    ///   - normalized: 亮度係數（0~1）
    func updateBarEffect(at index: Int, normalized: CGFloat) {
        guard index >= 0 && index < barViews.count else { return }
        barViews[index].updateEffect(scaleNormalized: normalized, brightnessNormalized: normalized)
    }

    /// 取得指定索引的 bar 視圖
    /// - Parameter index: bar 的索引
    /// - Returns: WaveBarView 或 nil
    func getBarView(at index: Int) -> WaveBarView? {
        guard index >= 0 && index < barViews.count else { return nil }
        return barViews[index]
    }

    /// 取得所有 bar 視圖
    var allBarViews: [WaveBarView] {
        return barViews
    }

    /// 重置所有 bar 的效果
    func resetAllEffects() {
        barViews.forEach { $0.resetEffect() }
    }
}
