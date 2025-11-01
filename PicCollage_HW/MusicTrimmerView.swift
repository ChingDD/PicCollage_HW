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
    private let waveformView = UIView()
    private var keyTimeView: KeyTimeView = KeyTimeView()
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
    
    func commonInit(viewModel: MusicEditorViewModel) {
        backgroundColor = .lightGray
        addSubview(keyTimeTitle)
        
        addSubview(sectionPercentLabel)
        addSubview(currentPercentLabel)
        
        addSubview(sectionTimeLabel)
        addSubview(currentTimeLabel)
        
        addSubview(keyTimeView)
        
        keyTimeView.commonInit()
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
    
    func setAutoLayout(view: UIView) {
        // MusicTrimmerView
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerYAnchor.constraint(equalTo: view.centerYAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // SubViews
        keyTimeTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            keyTimeTitle.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            keyTimeTitle.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])

        sectionPercentLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sectionPercentLabel.topAnchor.constraint(equalTo: keyTimeTitle.bottomAnchor, constant: 10),
            sectionPercentLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        currentPercentLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currentPercentLabel.topAnchor.constraint(equalTo: sectionPercentLabel.bottomAnchor, constant: 10),
            currentPercentLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        keyTimeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            keyTimeView.topAnchor.constraint(equalTo: currentPercentLabel.bottomAnchor, constant: 10),
            keyTimeView.heightAnchor.constraint(equalToConstant: 40),
            keyTimeView.leadingAnchor.constraint(equalTo: leadingAnchor),
            keyTimeView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        sectionTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sectionTimeLabel.topAnchor.constraint(equalTo: keyTimeView.bottomAnchor, constant: 10),
            sectionTimeLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currentTimeLabel.topAnchor.constraint(equalTo: sectionTimeLabel.bottomAnchor, constant: 10),
            currentTimeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            currentTimeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    func setDelegate(_ delegate: MusicTrimmerViewDelegate?) {
        self.delegate = delegate
        keyTimeView.delegate = delegate as? KeyTimeViewDelegate
    }
}
