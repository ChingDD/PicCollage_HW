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
        let trimmerRangeModel = TrimmerRangeModel(start: 0.0)
        let musicStateModel = MusicStateModel(totalDuration: 80.0,
                                              currentTime: 0.0,
                                              keyTimes: [10, 30, 50, 60, 75],
                                              selectedRange: trimmerRangeModel)
        let viewModel = MusicEditorViewModel(state: musicStateModel)
        let initViewController = MusicEditorViewController(viewModel: viewModel)
        navigationController.pushViewController(initViewController, animated: false)
    }
    
    func push() {
        
    }
    
    
}
