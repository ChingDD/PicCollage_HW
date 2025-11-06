//
//  KeyTimeView.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/10/31.
//

import UIKit

protocol KeyTimeViewDelegate: AnyObject {
    func didTapKeyTime(time: Int)
}

class KeyTimeView: UIView {
    private let keyTimeBar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray
        view.layer.cornerRadius = 8
        return view
    }()
    private let selectedRangeView: UIView = {
        let view = UIView()
        view.backgroundColor = .yellow
        view.layer.cornerRadius = 8
        return view
    }()
    private var keyTimeButtons: [UIButton] = []

    // Auto Layout constraints for dynamic updates
    private var selectedRangeLeadingConstraint: NSLayoutConstraint?
    private var selectedRangeWidthConstraint: NSLayoutConstraint?
    private var buttonCenterXConstraints: [NSLayoutConstraint] = []

    weak var delegate: KeyTimeViewDelegate?
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateKeyTimeViewUI(start: CGFloat, keyTimes: [CGFloat], totalDuration: CGFloat, duration: CGFloat) {
        updateSelectedRangeView(start: start, totalDuration: totalDuration, duration: duration)
        updateKeyTimeButtons(keyTimes: keyTimes, totalDuration: totalDuration)
    }
    
    func setupKeyTimes(_ keyTimes: [CGFloat]) {
        // Clear existing buttons
        keyTimeButtons.forEach { $0.removeFromSuperview() }
        keyTimeButtons.removeAll()
        buttonCenterXConstraints.removeAll()

        // Create new buttons with the provided keyTimes
        setKeytimeButton(keyTimes: keyTimes)
    }
    
    @objc func didTapButton(button: UIButton) {
        delegate?.didTapKeyTime(time: button.tag)
    }
    
    // MARK: - Private Methods

    private func commonInit() {
        backgroundColor = .black
        layer.cornerRadius = 20

        addSubview(keyTimeBar)

        setupKeytimeBar()
        setSelectedRangeView()
    }

    private func setupKeytimeBar() {
        keyTimeBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            keyTimeBar.heightAnchor.constraint(equalToConstant: 16),
            keyTimeBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            keyTimeBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            keyTimeBar.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func setSelectedRangeView() {
        keyTimeBar.addSubview(selectedRangeView)
        selectedRangeView.translatesAutoresizingMaskIntoConstraints = false

        selectedRangeLeadingConstraint = selectedRangeView.leadingAnchor.constraint(equalTo: keyTimeBar.leadingAnchor, constant: 0)
        selectedRangeWidthConstraint = selectedRangeView.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            selectedRangeView.topAnchor.constraint(equalTo: keyTimeBar.topAnchor),
            selectedRangeView.bottomAnchor.constraint(equalTo: keyTimeBar.bottomAnchor),
            selectedRangeLeadingConstraint!,
            selectedRangeWidthConstraint!
        ])
    }
    
    private func setKeytimeButton(keyTimes: [CGFloat]) {
        for time in keyTimes {
            let btn = UIButton()
            btn.backgroundColor = .red
            btn.layer.cornerRadius = 10
            btn.tag = Int(time)
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
            addSubview(btn)

            let centerXConstraint = btn.centerXAnchor.constraint(equalTo: keyTimeBar.leadingAnchor, constant: 0)
            buttonCenterXConstraints.append(centerXConstraint)

            NSLayoutConstraint.activate([
                btn.widthAnchor.constraint(equalToConstant: 20),
                btn.heightAnchor.constraint(equalToConstant: 20),
                btn.centerYAnchor.constraint(equalTo: keyTimeBar.centerYAnchor),
                centerXConstraint
            ])

            keyTimeButtons.append(btn)
        }
    }
    
    private func updateSelectedRangeView(start: CGFloat, totalDuration: CGFloat, duration: CGFloat) {
        layoutIfNeeded()  // Ensure keytimeBar has a valid width

        let barWidth = keyTimeBar.bounds.width
        let leadingOffset = (barWidth / CGFloat(totalDuration)) * start
        let rangeWidth = (barWidth / CGFloat(totalDuration)) * duration

        selectedRangeLeadingConstraint?.constant = leadingOffset
        selectedRangeWidthConstraint?.constant = rangeWidth
    }

    private func updateKeyTimeButtons(keyTimes: [CGFloat], totalDuration: CGFloat) {
        layoutIfNeeded()  // Ensure keytimeBar has a valid width

        let barWidth = keyTimeBar.bounds.width
        for (idx, btn) in keyTimeButtons.enumerated() {
            let time = btn.tag
            let centerXOffset = (barWidth / CGFloat(totalDuration)) * CGFloat(time)
            buttonCenterXConstraints[idx].constant = centerXOffset
        }
    }
}
