//
//  SceneDelegate.swift
//  TPoint
//
//  Created by 김미진 on 1/8/26.
//

import UIKit
import AppTrackingTransparency
import AdSupport

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var hasRequestedATT = false

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let gameViewController = GameViewController()
        let navigationController = UINavigationController(rootViewController: gameViewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Request ATT permission when app becomes active
        requestTrackingAuthorization()
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }

    // MARK: - App Tracking Transparency

    private func requestTrackingAuthorization() {
        guard !hasRequestedATT else { return }
        hasRequestedATT = true

        // Delay to ensure the app is fully loaded
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    print("✅ ATT: Authorized")
                case .denied:
                    print("❌ ATT: Denied")
                case .notDetermined:
                    print("⏳ ATT: Not Determined")
                case .restricted:
                    print("🚫 ATT: Restricted")
                @unknown default:
                    print("❓ ATT: Unknown")
                }
            }
        }
    }
}
