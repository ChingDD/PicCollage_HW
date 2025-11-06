//
//  MusicEditorViewController.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/10/29.
//

import UIKit

class MusicEditorViewController: UIViewController {
    // MARK: - ViewModel
    let editorViewModel: MusicEditorViewModel
    let waveViewModel: WaveformViewModel

    // MARK: - UI
    let trimmerView: MusicTrimmerView = MusicTrimmerView()

    let settingPageButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = .black
        config.baseBackgroundColor = .white
        config.title = "Setting"
        button.configuration = config
        return button
    }()

    weak var coordinator: MainCoordinator?
    
    // MARK: - Initialization
    init(viewModel: MusicEditorViewModel, waveformViewModel: WaveformViewModel) {
        self.editorViewModel = viewModel
        self.waveViewModel = waveformViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(trimmerView)
        view.addSubview(settingPageButton)
        
        // UI Setting
        setupTrimmerView()
        trimmerView.setupKeyTimeButton(keyTimes: editorViewModel.state.keyTimes)
        trimmerView.setDelegates(musicTrimmer: self, keyTime: self, waveform: self)
        setupSettingButton()
        
        // Add target action
        settingPageButton.addTarget(self, action: #selector(didTapSettingButton), for: .touchUpInside)
        
        // Binding
        binding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trimmerView.setupKeyTimeButton(keyTimes: editorViewModel.state.keyTimes)
        trimmerView.updateUI(viewModel: editorViewModel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("viewDidLayoutSubviews")
    }


    @objc func didTapSettingButton() {
        coordinator?.toSettingPage(viewModel: editorViewModel)
    }

    // MARK: - Private Methods
    private func setupTrimmerView() {
        trimmerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trimmerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            trimmerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            trimmerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trimmerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupSettingButton() {
        settingPageButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settingPageButton.safeAreaLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            settingPageButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
        ])
    }
    
    private func binding() {
        editorViewModel.onStateUpdated.bind { [weak self] _ in
            guard let self = self else { return }
            trimmerView.updateUI(viewModel: editorViewModel)
        }

        editorViewModel.onWaveformNeedsUpdate.bind { [weak self] _ in
            guard let self = self else { return }
            // Rebuild all waveform canvas
            trimmerView.updateWaveView(editorViewModel: editorViewModel, waveViewModel: waveViewModel)

            // Update UI after canvas rebuild (this will recalculate and set correct scroll offset)
            trimmerView.updateUI(viewModel: editorViewModel)

            // Update bar states
            updateWaveformBarStates(scrollView: trimmerView.waveformView.waveScrollView)
        }

        editorViewModel.isPlaying.bind { [weak self] isPlaying in
            guard let self = self else { return }
            trimmerView.updateButtonUI(isPlaying: isPlaying)
        }
        
        trimmerView.onWidthChanged = { [weak self] _ in
            guard let self = self else { return }
            // Rebuild all waveform canvas first
            trimmerView.updateWaveView(editorViewModel: editorViewModel, waveViewModel: waveViewModel)

            // Update UI after canvas rebuild (this will recalculate and set correct scroll offset)
            trimmerView.updateUI(viewModel: editorViewModel)

            // Update bar states
            updateWaveformBarStates(scrollView: trimmerView.waveformView.waveScrollView)
        }

        waveViewModel.onBarsUpdated.bind { [weak self] _ in
            guard let self = self else { return }
            // Update bars UI
            trimmerView.updateWaveBar(viewModel: waveViewModel)
        }
    }

    private func updateWaveformBarStates(scrollView: UIScrollView) {
        let waveformView = trimmerView.waveformView

        // Calculate selected frame in waveformCanvas coordinate system
        let selectedRangeView = waveformView.selectedRangeView
        let waveformCanvas = waveformView.waveformCanvas

        // Convert selectedRangeView bounds to waveformCanvas coordinate
        let selectedFrameInCanvas = waveformCanvas.convert(selectedRangeView.bounds, from: selectedRangeView)
        let selectedFrame = CGRect(x: max(0, selectedFrameInCanvas.minX),
                                   y: 0,
                                   width: selectedRangeView.bounds.width,
                                   height: 1)

        // Calculate visible frame in waveformCanvas coordinate
        let visibleX = scrollView.contentOffset.x + scrollView.contentInset.left
        let visibleFrame = CGRect(x: max(0, visibleX),
                                  y: 0,
                                  width: scrollView.bounds.width,
                                  height: 1)

        // Get bar dimensions
        let barWidth = WaveformComposer.getBarWidth()
        let gap = WaveformComposer.getGap()

        // Update ViewModel
        waveViewModel.update(for: visibleFrame,
                             selectedFrame: selectedFrame,
                             barWidth: barWidth,
                             gap: gap)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - MusicTrimmerViewDelegate
extension MusicEditorViewController: MusicTrimmerViewDelegate {
    func playButtonTapped() {
        editorViewModel.togglePlayPause()
    }
    
    func resetButtonTapped() {
        editorViewModel.resetToStart()
    }
}

// MARK: - KeyTimeViewDelegate
extension MusicEditorViewController: KeyTimeViewDelegate {
    func didTapKeytime(time: Int) {
        editorViewModel.shiftTime(to: CGFloat(time))
    }
}

// MARK: - WaveformViewDelegate
extension MusicEditorViewController: WaveformViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Update waveform bar states
        updateWaveformBarStates(scrollView: scrollView)

        guard scrollView.isDragging else { return }

        // Update editor time
        editorViewModel.updateTimeFromScrollOffset(
            contentOffsetX: scrollView.contentOffset.x,
            contentInsetLeft: scrollView.contentInset.left,
            contentInsetRight: scrollView.contentInset.right,
            contentSizeWidth: scrollView.contentSize.width,
            scrollViewWidth: scrollView.bounds.width
        )
    }
}
