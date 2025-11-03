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
    
    init(viewModel: MusicEditorViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var hasConfiguredWaveform = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(trimmerView)
        setupTrimmerView()
        trimmerView.setDelegate(self)

        binding()
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("viewDidLayoutSubviews")

        // 在第一次 layout 完成後配置波形假資料
        if !hasConfiguredWaveform {
            hasConfiguredWaveform = true
            setupMockWaveformData()
        }
    }

    /// 設定假的波形資料用於測試
    private func setupMockWaveformData() {
        // 生成 200 個假的振幅資料點，模擬音樂波形
        let mockAmplitudes = generateMockAmplitudes(count: 200)
        trimmerView.waveformView.configureWaveform(amplitudes: mockAmplitudes)
    }

    /// 生成模擬的振幅資料
    /// - Parameter count: 資料點數量
    /// - Returns: 振幅陣列，範圍 0.0~1.0
    private func generateMockAmplitudes(count: Int) -> [CGFloat] {
        var amplitudes: [CGFloat] = []

        for i in 0..<count {
            // 使用多種波形組合創造更真實的音樂波形
            let progress = CGFloat(i) / CGFloat(count)

            // 基礎正弦波
            let sine = sin(progress * .pi * 8) * 0.3

            // 隨機變化
            let random = CGFloat.random(in: 0.2...0.8)

            // 包絡線（音樂通常中間較強）
            let envelope = sin(progress * .pi) * 0.3

            // 組合波形
            let amplitude = max(0.1, min(1.0, sine + random + envelope))
            amplitudes.append(amplitude)
        }

        return amplitudes
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
