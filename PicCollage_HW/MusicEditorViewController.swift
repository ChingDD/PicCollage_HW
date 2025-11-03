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
    }
    
    func binding() {
        viewModel.start.bind { [weak self] start in
            guard let self = self else { return }
            trimmerView.updateUI(viewModel: viewModel)
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
