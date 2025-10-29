//
//  Coordinator.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/10/29.
//

import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    func startCoordinator()
    func push()
    
}

class MainCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController = UINavigationController()
    
    func startCoordinator() {
        let initViewController = MusicEditorViewController(viewModel: MusicEditorViewModel(state: MusicStateModel(totalDuration: 300, currentTime: 0, keyTimes: [], selectedRange: TrimmerRangeModel(start: 0, end: 10))))
        navigationController.pushViewController(initViewController, animated: false)
    }
    
    func push() {
        
    }
    
    
}
