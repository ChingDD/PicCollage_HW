//
//  WaveformView.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/11/2.
//

import UIKit

protocol WaveformViewDelegate: MusicTrimmerViewDelegate, UIScrollViewDelegate {}

// MARK: - WaveBarView

/// 表示單一波形 bar 的視圖
class WaveBarView: UIView {

    init(amplitude: CGFloat) {
        super.init(frame: .zero)
        setupView(amplitude: amplitude)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(amplitude: CGFloat) {
        backgroundColor = .white
        alpha = 0.7 + (amplitude * 0.3) // 振幅越大，透明度越高
        layer.cornerRadius = 1
    }
}

// MARK: - WaveView

/// 包含多個 WaveBarView 的容器視圖，根據振幅資料顯示波形
class WaveView: UIView {

    // MARK: - Properties

    private let barWidth: CGFloat = 3
    private let barSpacing: CGFloat = 2
    private var barViews: [WaveBarView] = []

    // MARK: - Initialization

    init() {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    /// 設定波形資料並更新顯示
    /// - Parameters:
    ///   - amplitudes: 振幅陣列，範圍 0.0~1.0
    ///   - totalWidth: 整個波形的總寬度
    func configure(amplitudes: [CGFloat], totalWidth: CGFloat) {
        clearBars()
        createBars(amplitudes: amplitudes, totalWidth: totalWidth)
    }

    // MARK: - Private Methods

    private func setupView() {
        backgroundColor = .clear
    }

    private func clearBars() {
        barViews.forEach { $0.removeFromSuperview() }
        barViews.removeAll()
    }

    private func createBars(amplitudes: [CGFloat], totalWidth: CGFloat) {
        let barCount = amplitudes.count

        for (index, amplitude) in amplitudes.enumerated() {
            let barView = WaveBarView(amplitude: amplitude)
            addSubview(barView)
            barViews.append(barView)

            // 設定 bar 的位置和大小
            barView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                barView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CGFloat(index) * (barWidth + barSpacing)),
                barView.centerYAnchor.constraint(equalTo: centerYAnchor),
                barView.widthAnchor.constraint(equalToConstant: barWidth),
                barView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: max(amplitude, 0.1)) // 最小高度 10%
            ])
        }
    }
}

// MARK: - WaveContainerView

/// 中央容器視圖，提供選取範圍的視覺效果（亮區、邊框、放大效果）
class WaveContainerView: UIView {

    // MARK: - Properties

    private let borderWidth: CGFloat = 3
    private let highlightAlpha: CGFloat = 0.2

    // MARK: - Initialization

    init() {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    private func setupView() {
        backgroundColor = .lightGray.withAlphaComponent(highlightAlpha)
        layer.borderColor = UIColor.systemBlue.cgColor
        layer.borderWidth = borderWidth
        isUserInteractionEnabled = false
    }

    // MARK: - Public Methods

    /// 更新邊框顏色
    func updateBorderColor(_ color: UIColor) {
        layer.borderColor = color.cgColor
    }

    /// 更新背景高亮度
    func updateHighlightAlpha(_ alpha: CGFloat) {
        backgroundColor = .lightGray.withAlphaComponent(alpha)
    }
}

class WaveformView: UIView {
    let selectedRangeView = WaveContainerView()
    let waveView = WaveView()
    
    let waveScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    let progressView: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        return view
    }()
    
    private var progressViewWidthConstraint: NSLayoutConstraint?
    
    weak var delegate: WaveformViewDelegate? {
        didSet {
            waveScrollView.delegate = delegate
        }
    }

    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
    }
    
    func setScrollOffset(_ offsetX: CGFloat) {
        waveScrollView.contentOffset.x = offsetX
    }
    
    func updateProgressView(ratio: CGFloat) {
        let width = selectedRangeView.frame.width * ratio
        progressViewWidthConstraint?.constant = width
    }

    /// 配置波形資料
    /// - Parameter amplitudes: 振幅陣列，範圍 0.0~1.0
    func configureWaveform(amplitudes: [CGFloat]) {
        let totalWidth = bounds.width * 0.5 * 100 // 與 waveView 的寬度約束一致
        waveView.configure(amplitudes: amplitudes, totalWidth: totalWidth)
    }

    // MARK: - Private Methods

    private func commonInit() {
        backgroundColor = .black

        addSubview(waveScrollView)
        addSubview(progressView)
        addSubview(selectedRangeView)
        waveScrollView.addSubview(waveView)

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
        waveView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            waveView.leadingAnchor.constraint(equalTo: waveScrollView.leadingAnchor),
            waveView.trailingAnchor.constraint(equalTo: waveScrollView.trailingAnchor),
            waveView.heightAnchor.constraint(equalTo: waveScrollView.heightAnchor, multiplier: 1),
            waveView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: (0.5 * 100))    // 100 is Test
        ])
    }
    
    private func setupProgressView() {
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressViewWidthConstraint = progressView.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: selectedRangeView.leadingAnchor),
            progressView.topAnchor.constraint(equalTo: selectedRangeView.topAnchor),
            progressView.heightAnchor.constraint(equalTo: selectedRangeView.heightAnchor, multiplier: 1),
            progressViewWidthConstraint!
        ])
    }
}
