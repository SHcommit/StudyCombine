//
//  SceneDelegate.swift
//  MVVM Inputs-Outputs binding with combine
//
//  Created by 양승현 on 2023/04/27.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(windowScene: windowScene)
    let model = Model(defaultString: "Outputs UI Rendered")
    let vm = ClockViewModel(model: model)
    
    /// Dependency injection
    window?.rootViewController = ClockViewController(viewModel: vm)
    window?.makeKeyAndVisible()
  }
}

extension SceneDelegate {
  func sceneDidDisconnect(_ scene: UIScene) {}
  func sceneDidBecomeActive(_ scene: UIScene) {}
  func sceneWillResignActive(_ scene: UIScene) {}
  func sceneWillEnterForeground(_ scene: UIScene) {}
  func sceneDidEnterBackground(_ scene: UIScene) {}
}
