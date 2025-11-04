//
//  WaveformView.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/11/2.
//

import UIKit

protocol WaveformViewDelegate: MusicTrimmerViewDelegate, UIScrollViewDelegate {}

class WaveformView: UIView {
    // MARK: - UI Components
    let selectedRangeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 153/255, green: 152/255, blue: 156/255, alpha: 1)
        view.layer.borderColor = UIColor.systemBlue.cgColor
        view.layer.borderWidth = 3
        view.isUserInteractionEnabled = false
        return view
    }()

    let waveScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    let progressView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 56/255, green: 215/255, blue: 98/255, alpha: 1)
        return view
    }()

    // MARK: - Properties

    /// 動態波形視圖
    private var waveView: WaveView?

    /// 振幅數據
    private let amplitudes: [CGFloat]

    /// Bar 寬度
    private let barWidth: CGFloat

    /// Bar 間距
    private let barSpacing: CGFloat

    private var progressViewWidthConstraint: NSLayoutConstraint?

    /// ContentOffset observer
    private var contentOffsetObservation: NSKeyValueObservation?

    weak var delegate: WaveformViewDelegate? {
        didSet {
            waveScrollView.delegate = delegate
        }
    }

    // MARK: - Initialization

    /// 初始化波形視圖
    /// - Parameters:
    ///   - amplitudes: 振幅陣列（0~1），如果為空則使用預設測試數據
    ///   - barWidth: Bar 寬度，預設 3
    ///   - barSpacing: Bar 間距，預設 2
    init(amplitudes: [CGFloat] = [], barWidth: CGFloat = 3, barSpacing: CGFloat = 2) {
        // 如果沒有提供振幅數據，生成測試數據
        self.amplitudes = amplitudes.isEmpty ? Self.generateTestAmplitudes(count: 200) : amplitudes
        self.barWidth = barWidth
        self.barSpacing = barSpacing
        super.init(frame: .zero)
        commonInit()
        setupContentOffsetObserver()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        contentOffsetObservation?.invalidate()
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        // 設置 contentInset 讓 waveView 的邊緣可以對齊 selectedRangeView 的邊緣
        // selectedRangeView 居中且寬度為 50%，所以左右各留 25% 空間
        let insetHorizontal = bounds.width * 0.25

        waveScrollView.contentInset = UIEdgeInsets(
            top: 0,
            left: insetHorizontal,
            bottom: 0,
            right: insetHorizontal
        )

        // Layout 更新後重新計算波形效果
        updateWaveEffects()
    }

    // MARK: - Public Methods

    func setScrollOffset(_ offsetX: CGFloat) {
        waveScrollView.contentOffset.x = offsetX
    }

    func updateProgressView(ratio: CGFloat) {
        let width = selectedRangeView.frame.width * ratio
        progressViewWidthConstraint?.constant = width
    }

    // MARK: - Private Methods

    private func commonInit() {
        backgroundColor = .black

        // 創建波形視圖
        let wave = WaveView(amplitudes: amplitudes, barWidth: barWidth, barSpacing: barSpacing)
        self.waveView = wave

        // 視圖疊加順序（從下到上）：selectedRangeView -> progressView -> waveScrollView
        addSubview(selectedRangeView)   // 最底層（灰色底）
        addSubview(progressView)        // 中間層（綠色進度蓋在灰色上）
        addSubview(waveScrollView)      // 最上層（波形顯示在最上面）
        waveScrollView.addSubview(wave)

        setupWaveScrollView()
        setupSelectedRangeView()
        setupWaveView()
        setupProgressView()
    }

    private func setupWaveScrollView() {
        waveScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            waveScrollView.centerYAnchor.constraint(equalTo: centerYAnchor),
            waveScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            waveScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            waveScrollView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: (1/2.5))
        ])
    }

    private func setupSelectedRangeView() {
        selectedRangeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectedRangeView.centerYAnchor.constraint(equalTo: centerYAnchor),
            selectedRangeView.centerXAnchor.constraint(equalTo: centerXAnchor),
            selectedRangeView.heightAnchor.constraint(equalTo: waveScrollView.heightAnchor, multiplier: 1),
            selectedRangeView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5)
        ])
    }

    private func setupWaveView() {
        guard let waveView = waveView else { return }

        waveView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            waveView.leadingAnchor.constraint(equalTo: waveScrollView.leadingAnchor),
            waveView.trailingAnchor.constraint(equalTo: waveScrollView.trailingAnchor),
            waveView.heightAnchor.constraint(equalTo: waveScrollView.heightAnchor, multiplier: 1),
            waveView.widthAnchor.constraint(equalToConstant: waveView.contentWidth)
        ])
    }
    
    private func setupProgressView() {
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressViewWidthConstraint = progressView.widthAnchor.constraint(equalToConstant: 0)

        // border width 為 3，所以要讓 progressView 在 border 內部
        let borderWidth: CGFloat = 3

        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: selectedRangeView.leadingAnchor, constant: borderWidth),
            progressView.topAnchor.constraint(equalTo: selectedRangeView.topAnchor, constant: borderWidth),
            progressView.heightAnchor.constraint(equalTo: selectedRangeView.heightAnchor, constant: -borderWidth * 2),
            progressViewWidthConstraint!
        ])
    }

    // MARK: - Wave Effects

    private func setupContentOffsetObserver() {
        // 監聽 scrollView 的 contentOffset 變化
        contentOffsetObservation = waveScrollView.observe(
            \.contentOffset,
            options: [.new]
        ) { [weak self] _, _ in
            self?.updateWaveEffects()
        }
    }

    /// 更新波形動態效果
    private func updateWaveEffects() {
        guard let waveView = waveView, bounds.width > 0 else { return }

        // 計算中央框在 scrollView 內容中的位置
        let centerXInContent = waveScrollView.contentOffset.x + bounds.width / 2

        // 高亮框的範圍（selectedRangeView 寬度為 50%）
        let highlightWidth = bounds.width * 0.5
        let highlightLeft = centerXInContent - highlightWidth / 2
        let highlightRight = centerXInContent + highlightWidth / 2

        // 更新每個 bar 的效果
        for (index, barView) in waveView.allBarViews.enumerated() {
            // 計算 bar 在 scrollView 內容中的中心位置
            let barCenterX = CGFloat(index) * (barWidth + barSpacing) + barWidth / 2

            // 計算 bar 與高亮框中心的距離
            let distanceFromCenter = abs(barCenterX - centerXInContent)

            // 計算 normalized 值（0~1）
            let brightnessNormalized: CGFloat
            let scaleNormalized: CGFloat

            // Brightness
            if barCenterX >= highlightLeft && barCenterX <= highlightRight {
                // bar 在高亮框內，亮度設為最大值
                brightnessNormalized = 1.0
            } else {
                // bar 在高亮框外
                brightnessNormalized = 0
            }

            // Scale
            let maxDistance = highlightWidth / 2
            scaleNormalized = max(0, 1.0 - distanceFromCenter / maxDistance)

            // 更新 bar 效果
            barView.updateEffect(scaleNormalized: scaleNormalized, brightnessNormalized: brightnessNormalized)
        }
    }

    // MARK: - Test Data Generation

    /// 生成測試振幅數據
    private static func generateTestAmplitudes(count: Int) -> [CGFloat] {
        return (0..<count).map { _ in CGFloat.random(in: 0.3...0.6) }
    }
}
