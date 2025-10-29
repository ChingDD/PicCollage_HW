//
//  MusicEditorViewController.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/10/29.
//

import UIKit

class MusicEditorViewController: UIViewController {
    let viewModel: MusicEditorViewModel
    
    init(viewModel: MusicEditorViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("進入 MusicEditorViewController")
        // Do any additional setup after loading the view.
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
