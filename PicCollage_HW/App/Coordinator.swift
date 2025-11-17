//
//  Coordinator.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/10/29.
//

import UIKit
import SwiftUI

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    func startCoordinator()
    func back()
}

class MainCoordinator: Coordinator {
    var navigationController: UINavigationController = UINavigationController()
    
    func startCoordinator() {
        // MusicEditorViewModel
        let trimmerRangeModel = TrimmerRangeModel(start: 0.0)
        let musicStateModel = MusicStateModel(totalDuration: 80.0,
                                              currentTime: 0.0,
                                              keyTimes: [10, 30, 50, 60, 75],
                                              selectedRange: trimmerRangeModel)
        let editViewModel = MusicEditorViewModel(state: musicStateModel)

        // Creat AudioTrimmerScreen
        navigateToTrimmerView(viewModel: editViewModel)
    }
    
    func navigateToSettings(viewModel:MusicEditorViewModel) {
        let settingsView = SettingsView(viewModel: viewModel,
                                        onBack: {
            [weak self] in
            // Leave SettingView
            self?.back()
        })
        
        let hostingController = UIHostingController(rootView: settingsView)
        navigationController.pushViewController(hostingController, animated: true)
    }
    
    func navigateToTrimmerView(viewModel:MusicEditorViewModel) {
        let audioTrimmerScreen = AudioTrimmerScreen(viewModel: viewModel,
                                                    onSettingsTapped: { [weak self] in
            // GO to SettingView
            self?.navigateToSettings(viewModel: viewModel)
        })
        let hostingController = UIHostingController(rootView: audioTrimmerScreen)
        navigationController.pushViewController(hostingController, animated: true)
    }
    
    func back() {
        navigationController.popViewController(animated: true)
    }
}
