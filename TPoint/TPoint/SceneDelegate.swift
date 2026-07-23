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
        // 저장된 라이트/다크 테마를 윈도우 생성 시점에 적용 (콜드 런치 시 잘못된 테마 방지)
        applyStoredTheme(to: window)
        window.makeKeyAndVisible()
        self.window = window
    }

    private func applyStoredTheme(to window: UIWindow) {
        let mode = ThemeMode(rawValue: UserDefaults.standard.integer(forKey: "themeMode")) ?? .system
        switch mode {
        case .system: window.overrideUserInterfaceStyle = .unspecified
        case .light: window.overrideUserInterfaceStyle = .light
        case .dark: window.overrideUserInterfaceStyle = .dark
        }
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
