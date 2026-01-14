//
//  BannerAdView.swift
//  TPoint
//

import UIKit
import GoogleMobileAds

final class BannerAdView: UIView, BannerViewDelegate {

    // MARK: - Properties

    private var bannerView: BannerView?
    private weak var rootViewController: UIViewController?

    // Ad Unit ID
    private var adUnitID: String {
        #if DEBUG
        return "ca-app-pub-3940256099942544/2435281174" // Test Banner Ad Unit ID
        #else
        return "ca-app-pub-2707874353926722/4632543750" // Production Ad Unit ID
        #endif
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Setup

    private func setupView() {
        backgroundColor = .clear
    }

    // MARK: - Public Methods

    func configure(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        loadBannerAd()
    }

    func loadBannerAd() {
        guard let rootViewController = rootViewController else { return }

        // Remove existing banner if any
        bannerView?.removeFromSuperview()
        bannerView = nil

        // Get adaptive banner size
        let viewWidth = rootViewController.view.frame.inset(by: rootViewController.view.safeAreaInsets).width
        guard viewWidth > 0 else { return }

        let adaptiveSize = currentOrientationAnchoredAdaptiveBanner(width: viewWidth)

        // Create banner view
        let banner = BannerView(adSize: adaptiveSize)
        banner.adUnitID = adUnitID
        banner.rootViewController = rootViewController
        banner.delegate = self
        banner.translatesAutoresizingMaskIntoConstraints = false

        addSubview(banner)

        NSLayoutConstraint.activate([
            banner.centerXAnchor.constraint(equalTo: centerXAnchor),
            banner.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        bannerView = banner

        // Load ad
        print("🔵 Loading banner ad with adUnitID: \(adUnitID)")
        banner.load(Request())
    }

    // MARK: - Size

    func getAdHeight() -> CGFloat {
        return bannerView?.adSize.size.height ?? 50
    }

    // MARK: - BannerViewDelegate

    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        print("✅ Banner ad loaded successfully!")
        // Ad loaded successfully - fade in animation
        bannerView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            bannerView.alpha = 1
        }
    }

    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        print("❌ Banner ad failed to load: \(error.localizedDescription)")
    }
}
