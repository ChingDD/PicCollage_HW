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
        trimmerView.setAutoLayout(view: view)
        trimmerView.setDelegate(self)
        
        binding()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        trimmerView.layoutIfNeeded()
        trimmerView.updateUI(viewModel: viewModel)
    }
    
    func binding() {
        viewModel.start.bind { [weak self] start in
            guard let self = self else { return }
            self.trimmerView.updateUI(viewModel: self.viewModel)
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
        viewModel.shiftTime(to: time)
    }
}
