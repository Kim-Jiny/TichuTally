//
//  AppDelegate.swift
//  TPoint
//
//  Created by 김미진 on 1/8/26.
//

import UIKit
import GoogleMobileAds

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 가족용 광고 설정 (Google Play/App Store 가족 정책 준수)
        MobileAds.shared.requestConfiguration.maxAdContentRating = .general
        MobileAds.shared.requestConfiguration.tagForChildDirectedTreatment = true

        // Initialize Google Mobile Ads SDK
        MobileAds.shared.start(completionHandler: nil)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
