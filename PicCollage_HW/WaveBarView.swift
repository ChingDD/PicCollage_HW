//
//  WaveBarView.swift
//  PicCollage_HW
//
//  Created by 林仲景
//

import UIKit

/// 單一波形 bar 視圖
/// 負責顯示一條垂直的音訊振幅 bar
class WaveBarView: UIView {

    // MARK: - Properties

    /// 原始高度（代表振幅）
    private var originalHeight: CGFloat

    /// 當前的亮度係數（0~1）
    private var brightness: CGFloat = 0.4

    /// 當前的縮放係數
    private var scale: CGFloat = 1.0

    // MARK: - Initialization

    init(height: CGFloat, width: CGFloat = 3) {
        self.originalHeight = height
        super.init(frame: .zero)
        setupView(width: width)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupView(width: CGFloat) {
        backgroundColor = .white
        layer.cornerRadius = width / 2
        translatesAutoresizingMaskIntoConstraints = false

        // 設置初始亮度
        alpha = brightness
    }

    // MARK: - Public Methods

    // 更新 bar 的視覺效果
    // Parameter normalized: 亮度係數（0~1），0 表示最遠，1 表示最近中央
    func updateEffect(scaleNormalized : CGFloat, brightnessNormalized : CGFloat) {
        // 計算縮放比例：1 + 0.4 * normalized
        let newScale = 1.0 + 0.7 * scaleNormalized

        // 計算亮度：alpha = 0.4 + 0.6 * normalized
        let newBrightness = 0.4 + 0.6 * brightnessNormalized

        // 更新屬性
        self.scale = newScale
        self.brightness = newBrightness

        // 應用變換
        applyTransform()
        alpha = newBrightness
    }

    // 重置為預設狀態
    func resetEffect() {
        updateEffect(scaleNormalized: 0, brightnessNormalized: 0)
    }

    // MARK: - Private Methods

    private func applyTransform() {
        // 只在垂直方向縮放
        transform = CGAffineTransform(scaleX: 1.0, y: scale)
    }
}
