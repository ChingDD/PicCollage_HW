//
//  WaveformView.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/11/2.
//

import UIKit

protocol WaveformViewDelegate: MusicTrimmerViewDelegate {
    
}

class WaveformView: UIView {
    let selectedRangeView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray.withAlphaComponent(0.2)
        view.layer.borderColor = UIColor.systemBlue.cgColor
        view.layer.borderWidth = 3
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
    
    weak var delegate: WaveformViewDelegate?
    
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
    
    // MARK: - Private Methods
    
    private func commonInit() {
        backgroundColor = .black
        setWaveScrollView()
        setSelectedRangeView()
        setWaveView()
    }
    
    func setWaveView() {
        waveScrollView.addSubview(waveView)
        waveView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            waveView.trailingAnchor.constraint(equalTo: waveScrollView.trailingAnchor),
            waveView.leadingAnchor.constraint(equalTo: waveScrollView.leadingAnchor),
            waveView.heightAnchor.constraint(equalTo: waveScrollView.heightAnchor, multiplier: 1),
            waveView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: (0.5 * 100))    // 100 is Test
        ])
    }
    
    private func setWaveScrollView() {
        addSubview(waveScrollView)
        waveScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            waveScrollView.centerYAnchor.constraint(equalTo: centerYAnchor),
            waveScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            waveScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            waveScrollView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: (1/2.5))
        ])
    }
    
    private func setSelectedRangeView() {
        addSubview(selectedRangeView)
        selectedRangeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectedRangeView.centerYAnchor.constraint(equalTo: centerYAnchor),
            selectedRangeView.centerXAnchor.constraint(equalTo: centerXAnchor),
            selectedRangeView.heightAnchor.constraint(equalTo: waveScrollView.heightAnchor, multiplier: 1),
            selectedRangeView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5)
        ])
    }
}
