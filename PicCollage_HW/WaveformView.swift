//
//  WaveformView.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/11/2.
//

import UIKit

protocol WaveformViewDelegate: AnyObject, UIScrollViewDelegate {}

class WaveformView: UIView {
    private enum UIConstants {
        static let selectedRangeViewBorderWidth: CGFloat = 3
        static let contentInsetRatio: CGFloat = 0.25          // 25%
        static let selectedRangeWidthRatio: CGFloat = 0.5     // 50%
        static let scrollViewHightRatio: CGFloat = 1/2.5
    }
    
    let selectedRangeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 153/255, green: 152/255, blue: 156/255, alpha: 1)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    var waveformCanvas: UIView = {
        let view = UIView()
        return view
    }()
    
    let waveScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    let progressView: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private var progressViewWidthConstraint: NSLayoutConstraint?
    private var waveformCanvasWidthConstraint: NSLayoutConstraint?
    private var gradientBorderLayer: CAGradientLayer?

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
        // Setup scrollView Offset
        setupScrollViewOffset()

        // Setup gradient border for selectedRangeView
        setupGradientBorder()
    }
    
    func setScrollOffset(_ offsetX: CGFloat) {
        waveScrollView.contentOffset.x = offsetX
    }
    
    func updateProgressView(ratio: CGFloat) {
        layoutIfNeeded()

        let width = selectedRangeView.frame.width * ratio
        progressViewWidthConstraint?.constant = width - (2 * UIConstants.selectedRangeViewBorderWidth)
    }

    func updateWaveformCanvasWidth(durationRatio: CGFloat) {
        layoutIfNeeded()

        // Set waveformCanvas width
        let width = selectedRangeView.frame.width * durationRatio
        waveformCanvasWidthConstraint?.constant = width
        
        // Make canvas
        waveformCanvas.subviews.forEach { $0.removeFromSuperview() }
        let newWaveform = WaveformComposer.makeWaveformCanvas(width: width,
                                                              height: selectedRangeView.frame.height)
        waveformCanvas.addSubview(newWaveform)
    }

    // MARK: - Private Methods

    private func commonInit() {
        backgroundColor = .black
        
        addSubview(selectedRangeView)
        addSubview(progressView)
        addSubview(waveScrollView)
        waveScrollView.addSubview(waveformCanvas)

        setupWaveScrollView()
        setupSelectedRangeView()
        setupWaveformCanvas()
        setupProgressView()
    }

    private func setupWaveScrollView() {
        waveScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            waveScrollView.centerYAnchor.constraint(equalTo: centerYAnchor),
            waveScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            waveScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            waveScrollView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: UIConstants.scrollViewHightRatio)
        ])
    }

    private func setupSelectedRangeView() {
        selectedRangeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectedRangeView.centerYAnchor.constraint(equalTo: centerYAnchor),
            selectedRangeView.centerXAnchor.constraint(equalTo: centerXAnchor),
            selectedRangeView.heightAnchor.constraint(equalTo: waveScrollView.heightAnchor, multiplier: 1),
            selectedRangeView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: UIConstants.selectedRangeWidthRatio)
        ])
    }

    private func setupWaveformCanvas() {
        waveformCanvas.translatesAutoresizingMaskIntoConstraints = false
        waveformCanvasWidthConstraint = waveformCanvas.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            waveformCanvas.leadingAnchor.constraint(equalTo: waveScrollView.leadingAnchor),
            waveformCanvas.trailingAnchor.constraint(equalTo: waveScrollView.trailingAnchor),
            waveformCanvas.heightAnchor.constraint(equalTo: waveScrollView.heightAnchor, multiplier: 1),
            waveformCanvasWidthConstraint!
        ])
    }
    
    private func setupProgressView() {
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressViewWidthConstraint = progressView.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: selectedRangeView.leadingAnchor,
                                                  constant: UIConstants.selectedRangeViewBorderWidth),
            progressView.topAnchor.constraint(equalTo: selectedRangeView.topAnchor,
                                              constant: UIConstants.selectedRangeViewBorderWidth),
            progressView.bottomAnchor.constraint(equalTo: selectedRangeView.bottomAnchor,
                                                 constant: -(UIConstants.selectedRangeViewBorderWidth)),
            progressViewWidthConstraint!
        ])
    }
    
    private func setupGradientBorder() {
        // Remove old gradient layer if exists
        gradientBorderLayer?.removeFromSuperlayer()

        let borderWidth = UIConstants.selectedRangeViewBorderWidth

        // Create gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = selectedRangeView.bounds
        gradientLayer.colors = [
            UIColor.orange.cgColor,
            UIColor.purple.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)  // Left center
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)    // Right center

        // Create border mask (shows only the border area)
        let maskLayer = CAShapeLayer()
        let outerPath = UIBezierPath(rect: selectedRangeView.bounds)
        let innerPath = UIBezierPath(rect: selectedRangeView.bounds.insetBy(dx: borderWidth, dy: borderWidth))
        outerPath.append(innerPath)
        outerPath.usesEvenOddFillRule = true

        maskLayer.path = outerPath.cgPath
        maskLayer.fillRule = .evenOdd

        gradientLayer.mask = maskLayer

        // Insert gradient layer at the bottom so it doesn't cover other subviews
        selectedRangeView.layer.insertSublayer(gradientLayer, at: 0)
        gradientBorderLayer = gradientLayer
    }
    
    private func setupScrollViewOffset() {
        // Set contentInset so that the edges of waveformCanvas align with the edges of selectedRangeView
        // Since selectedRangeView is centered and its width is 50%, leave 25% space on each side
        let insetHorizontal = bounds.width * UIConstants.contentInsetRatio

        waveScrollView.contentInset = UIEdgeInsets(
            top: 0,
            left: insetHorizontal,
            bottom: 0,
            right: insetHorizontal
        )
    }
}
