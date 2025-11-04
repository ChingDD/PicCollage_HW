//
//  MusicEditorViewController.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/10/29.
//

import UIKit

class MusicEditorViewController: UIViewController {
    let viewModel: MusicEditorViewModel
    
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
    init(viewModel: MusicEditorViewModel) {
        self.viewModel = viewModel
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
        trimmerView.setupkeyTimeButton(keyTimes: viewModel.state.keyTimes)
        trimmerView.setDelegate(self)
        setupSettingButton()
        
        // Add target action
        settingPageButton.addTarget(self, action: #selector(didTapSettingButton), for: .touchUpInside)
        
        // Binding
        binding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trimmerView.setupkeyTimeButton(keyTimes: viewModel.state.keyTimes)
        trimmerView.updateUI(viewModel: viewModel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("viewDidLayoutSubviews")
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
    
    func binding() {
        viewModel.start.bind { [weak self] start in
            guard let self = self else { return }
            trimmerView.updateUI(viewModel: viewModel)
        }
        
        viewModel.isPlaying.bind { [weak self] isPlaying in
            guard let self = self else { return }
            trimmerView.updateButtonUI(isPlaying: isPlaying)
        }
        
        trimmerView.onWidthChanged = { [weak self] _ in
            guard let self = self else { return }
            trimmerView.updateUI(viewModel: viewModel)
        }
    }
    
    @objc func didTapSettingButton() {
        coordinator?.toSettingPage(viewModel: viewModel)
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

extension MusicEditorViewController: MusicTrimmerViewDelegate {
    func playButtonTapped() {
        viewModel.togglePlayPause()
    }
    
    func resetButtonTapped() {
        viewModel.resetToStart()
    }
}

extension MusicEditorViewController: KeyTimeViewDelegate {
    func didTapKeytime(time: Int) {
        viewModel.shiftTime(to: CGFloat(time))
    }
}

extension MusicEditorViewController: WaveformViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging else { return }

        viewModel.updateTimeFromScrollOffset(
            contentOffsetX: scrollView.contentOffset.x,
            contentInsetLeft: scrollView.contentInset.left,
            contentInsetRight: scrollView.contentInset.right,
            contentSizeWidth: scrollView.contentSize.width,
            scrollViewWidth: scrollView.bounds.width
        )
    }
}
