//
//  MusicTrimmerView.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/10/31.
//

import UIKit

protocol MusicTrimmerViewDelegate: AnyObject {
    func playButtonTapped()
    func resetButtonTapped()
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
    private let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "Play"
        config.baseForegroundColor = .white
        button.configuration = config
        return button
    }()
    private let ResetButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "Reset"
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .gray
        button.configuration = config
        return button
    }()
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        return stackView
    }()
    
    private var lastWidth: CGFloat = 0
    var onWidthChanged: ((CGFloat) -> Void)?

    weak var musicTrimmerDelegate: MusicTrimmerViewDelegate?
    weak var keyTimeDelegate: KeyTimeViewDelegate? {
        didSet {
            keyTimeView.delegate = keyTimeDelegate
        }
    }
    weak var waveformDelegate: WaveformViewDelegate? {
        didSet {
            waveformView.delegate = waveformDelegate
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
        
        if bounds.width != lastWidth {
            lastWidth = bounds.width
            onWidthChanged?(bounds.width)
        }
    }
    
    func updateUI(viewModel: MusicEditorViewModel) {
        keyTimeView.updateKeyTimeViewUI(start: viewModel.state.selectedRange.start,
                                        keyTimes: viewModel.state.keyTimes,
                                        totalDuration: viewModel.state.totalDuration,
                                        duration: viewModel.state.selectedRange.duration)
        sectionPercentLabel.text = viewModel.sectionPercentage
        currentPercentLabel.text = viewModel.currentPercentage
        sectionTimeLabel.text = viewModel.sectionTimeline
        currentTimeLabel.text = viewModel.currentTimeline
        updateWaveformUI(viewModel: viewModel)
    }

    func setDelegates(musicTrimmer: MusicTrimmerViewDelegate?,
                      keyTime: KeyTimeViewDelegate?,
                      waveform: WaveformViewDelegate?) {
        self.musicTrimmerDelegate = musicTrimmer
        self.keyTimeDelegate = keyTime
        self.waveformDelegate = waveform
    }
    
    func updateButtonUI(isPlaying: Bool) {
        playPauseButton.setTitle(isPlaying ? "Pause" : "Play", for: .normal)
    }
    
    func setupkeyTimeButton(keyTimes: [CGFloat]) {
        keyTimeView.setupKeyTimes(keyTimes)
    }
    
    func updateWaveView(viewModel: MusicEditorViewModel) {
        waveformView.updateWaveformCanvasWidth(durationRatio: viewModel.durationRatio)
    }
    
    @objc func playButtonTapped() {
        musicTrimmerDelegate?.playButtonTapped()
    }

    @objc func resetButtonTapped() {
        musicTrimmerDelegate?.resetButtonTapped()
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
        addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(playPauseButton)
        buttonStackView.addArrangedSubview(ResetButton)

        setupKeyTimeTitle()
        setupSectionPercentLabel()
        setupCurrentPercentLabel()
        setupKeyTimeView()
        setupSectionTimeLabel()
        setupCurrentTimeLabel()
        setupWaveformView()
        setupButton()
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
            waveformView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func setupButton() {
        playPauseButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        ResetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            buttonStackView.topAnchor.constraint(equalTo: waveformView.bottomAnchor, constant: 10),
            buttonStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }

    private func updateWaveformUI(viewModel: MusicEditorViewModel) {
        waveformView.updateProgressView(ratio: viewModel.progressRatio)
        // Calculate scroll offset through ViewModel, then apply it to View
        if let offsetX = viewModel.calculateScrollOffset(scrollViewBounds: waveformView.waveScrollView.bounds,
                                                         contentSize: waveformView.waveScrollView.contentSize,
                                                         contentInsetLeft: waveformView.waveScrollView.contentInset.left,
                                                         contentInsetRight: waveformView.waveScrollView.contentInset.right) {
            waveformView.setScrollOffset(offsetX)
        }
    }
}
