//
//  KeyTimeView.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/10/31.
//

import UIKit

protocol KeyTimeViewDelegate:  MusicTrimmerViewDelegate {
    func didTapKeytime(time: Int)
}

class KeyTimeView: UIView {
    let keytimeBar: UIView = UIView()
    let selectedRangeView: UIView = UIView()
    var keyTimeButtons: [UIButton] = []
    
    // test
    let fakeKeyTimes = [10, 30, 50, 60, 75]
    let fakeTotalDuration = 80
    
    weak var delegate: KeyTimeViewDelegate?
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateKeytimeViewUI(start: Int, keyTimes: [Int], totalDuration: Int) {
        updateSelectedRangeView(start: start, totalDuration: totalDuration)
        updatekeyTimeButtons(keyTimes: keyTimes, totalDuration: totalDuration)
    }
    
    @objc func didTapButton(button: UIButton) {
        delegate?.didTapKeytime(time: button.tag)
        print("time: \(button.tag)")
    }
    
    // MARK: - Private Methods
    
    private func commonInit() {
        backgroundColor = .black
        layer.cornerRadius = 20
        setkeytimeBar()
        setSelectedRangeView()
        setKeytimeButton()
    }
    
    private func setkeytimeBar() {
        // background color
        keytimeBar.backgroundColor = .systemGray
        keytimeBar.layer.cornerRadius = 8
        addSubview(keytimeBar)
        // layout
        keytimeBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            keytimeBar.heightAnchor.constraint(equalToConstant: 16),
            keytimeBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            keytimeBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            keytimeBar.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func setSelectedRangeView() {
        selectedRangeView.backgroundColor = .yellow
        selectedRangeView.layer.cornerRadius = 8
        keytimeBar.addSubview(selectedRangeView)
    }
    
    private func setKeytimeButton() {
        for time in fakeKeyTimes {
            let btn = UIButton()
            btn.backgroundColor = .red
            btn.layer.cornerRadius = 10
            btn.frame = CGRect(x: keytimeBar.frame.minX + (keytimeBar.frame.width / CGFloat(fakeTotalDuration) * CGFloat(time)),
                               y: keytimeBar.frame.midY - (20 / 2),
                               width: 20,
                               height: 20)
            btn.tag = time
            btn.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
            addSubview(btn)
            keyTimeButtons.append(btn)
        }
    }
    
    private func updateSelectedRangeView(start: Int, totalDuration: Int) {
        print("Start: \(start)")
        selectedRangeView.frame = CGRect(x: keytimeBar.frame.width / CGFloat(fakeTotalDuration) * CGFloat(start),
                                         y: 0,
                                         width: (keytimeBar.frame.width / CGFloat(fakeTotalDuration) * 10),
                                         height: 16)
    }
    
    private func updatekeyTimeButtons(keyTimes: [Int], totalDuration: Int) {
        for (idx,btn) in keyTimeButtons.enumerated() {
            let time = fakeKeyTimes[idx]
            btn.frame = CGRect(x: keytimeBar.frame.minX + (keytimeBar.frame.width / CGFloat(fakeTotalDuration) * CGFloat(time)),
                               y: keytimeBar.frame.midY - (20 / 2),
                               width: 20,
                               height: 20)
        }
    }
}
