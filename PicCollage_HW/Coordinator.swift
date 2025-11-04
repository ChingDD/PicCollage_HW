//
//  Coordinator.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/10/29.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    func startCoordinator()
    func back()
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
        initViewController.coordinator = self
        navigationController.pushViewController(initViewController, animated: false)
    }
    
    func toSettingPage(viewModel:MusicEditorViewModel ) {
        let settingPage = SettingViewController(viewModel: viewModel)
        settingPage.coordinator = self
        settingPage.navigationItem.setHidesBackButton(true, animated: false)
        navigationController.pushViewController(settingPage, animated: true)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        navigationController.present(alert, animated: true)
    }
    
    func back() {
        navigationController.popViewController(animated: true)
    }
    
    
}
