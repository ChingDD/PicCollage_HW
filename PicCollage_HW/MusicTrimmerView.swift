//
//  MusicTrimmerView.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/10/31.
//

import UIKit

protocol MusicTrimmerViewDelegate: AnyObject {
    
}

class MusicTrimmerView: UIView {
    private(set) var waveformView = WaveformView()
    private let keyTimeView: KeyTimeView = KeyTimeView()
    private let keyTimeTitle: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "KeyTime Section"
        return label
    }()
    private let sectionPercentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "Selection: 0.0% - 100.0%"
        return label
    }()
    private let currentPercentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .green
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "Current: 0.0%"
        return label
    }()
    private let timelineTitle: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "Music Timeline"
        return label
    }()
    private let sectionTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "Selected: 0:00 - 1:00"
        return label
    }()
    private let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .green
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "Current: 0:00"
        return label
    }()
    private let currentTimeIndicator = UIView()
    
    weak var delegate: MusicTrimmerViewDelegate?
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateUI(viewModel: MusicEditorViewModel) {
        keyTimeView.updateKeytimeViewUI(start: viewModel.start.value,
                                        keyTimes: viewModel.state.keyTimes,
                                        totalDuration: viewModel.state.totalDuration)
        sectionPercentLabel.text = viewModel.sectionPercentage
        currentPercentLabel.text = viewModel.currentPercentage
        sectionTimeLabel.text = viewModel.sectionTimeline
        currentTimeLabel.text = viewModel.currentTimeline
    }
    
    func updateSelectedRangeView(viewModel: MusicEditorViewModel) {
        
    }
    
    
    func setDelegate(_ delegate: MusicTrimmerViewDelegate?) {
        self.delegate = delegate
        keyTimeView.delegate = delegate as? KeyTimeViewDelegate
    }
    
    // MARK: - Private Methods

    private func commonInit() {
        backgroundColor = .lightGray

        addSubview(keyTimeTitle)
        addSubview(sectionPercentLabel)
        addSubview(currentPercentLabel)
        addSubview(keyTimeView)
        addSubview(sectionTimeLabel)
        addSubview(currentTimeLabel)
        addSubview(waveformView)

        setupKeyTimeTitle()
        setupSectionPercentLabel()
        setupCurrentPercentLabel()
        setupKeyTimeView()
        setupSectionTimeLabel()
        setupCurrentTimeLabel()
        setupWaveformView()
    }

    private func setupKeyTimeTitle() {
        keyTimeTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            keyTimeTitle.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            keyTimeTitle.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    private func setupSectionPercentLabel() {
        sectionPercentLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sectionPercentLabel.topAnchor.constraint(equalTo: keyTimeTitle.bottomAnchor, constant: 10),
            sectionPercentLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    private func setupCurrentPercentLabel() {
        currentPercentLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currentPercentLabel.topAnchor.constraint(equalTo: sectionPercentLabel.bottomAnchor, constant: 10),
            currentPercentLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    private func setupKeyTimeView() {
        keyTimeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            keyTimeView.topAnchor.constraint(equalTo: currentPercentLabel.bottomAnchor, constant: 10),
            keyTimeView.heightAnchor.constraint(equalToConstant: 40),
            keyTimeView.leadingAnchor.constraint(equalTo: leadingAnchor),
            keyTimeView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func setupSectionTimeLabel() {
        sectionTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sectionTimeLabel.topAnchor.constraint(equalTo: keyTimeView.bottomAnchor, constant: 10),
            sectionTimeLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    private func setupCurrentTimeLabel() {
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currentTimeLabel.topAnchor.constraint(equalTo: sectionTimeLabel.bottomAnchor, constant: 10),
            currentTimeLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    private func setupWaveformView() {
        waveformView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            waveformView.topAnchor.constraint(equalTo: currentTimeLabel.bottomAnchor, constant: 10),
            waveformView.leadingAnchor.constraint(equalTo: leadingAnchor),
            waveformView.trailingAnchor.constraint(equalTo: trailingAnchor),
            waveformView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            waveformView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
}
