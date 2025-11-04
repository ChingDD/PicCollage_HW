//
//  WaveformView.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/11/2.
//

import UIKit

protocol WaveformViewDelegate: AnyObject, UIScrollViewDelegate {}

class WaveformView: UIView {
    let selectedRangeView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray.withAlphaComponent(0.2)
        view.layer.borderColor = UIColor.systemBlue.cgColor
        view.layer.borderWidth = 3
        view.isUserInteractionEnabled = false
        return view
    }()
    
    let waveView: UIView = {
        let view = UIView()
        view.backgroundColor = .brown
        return view
    }()
    
    let waveScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    let progressView: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private var progressViewWidthConstraint: NSLayoutConstraint?
    private var waveViewWidthConstraint: NSLayoutConstraint?

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
        layoutIfNeeded()

        let width = selectedRangeView.frame.width * ratio
        progressViewWidthConstraint?.constant = width
    }

    func updateWaveformContentSizeWidth(durationRatio: CGFloat) {
        layoutIfNeeded()

        let width = selectedRangeView.frame.width * durationRatio
        waveViewWidthConstraint?.constant = width
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
        waveViewWidthConstraint = waveView.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            waveView.leadingAnchor.constraint(equalTo: waveScrollView.leadingAnchor),
            waveView.trailingAnchor.constraint(equalTo: waveScrollView.trailingAnchor),
            waveView.heightAnchor.constraint(equalTo: waveScrollView.heightAnchor, multiplier: 1),
            waveViewWidthConstraint!
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
