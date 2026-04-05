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

        // Initialize Google Mobile Ads SDK - 어댑터 상태 로깅으로 초기화 실패 진단 가능
        MobileAds.shared.start { status in
            let adapters = status.adapterStatusesByClassName
            if adapters.isEmpty {
                print("❌ AdMob 초기화 실패: 어댑터 상태가 비어 있습니다.")
            } else {
                for (adapterClass, adapterStatus) in adapters {
                    print("🟢 AdMob 어댑터 \(adapterClass): state=\(adapterStatus.state.rawValue), \(adapterStatus.description)")
                }
            }
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
