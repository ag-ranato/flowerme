// AppDelegate.swift

import UIKit
import FirebaseCore
import GoogleSignIn
import KakaoSDKCommon
import KakaoSDKAuth
import NaverThirdPartyLogin

// ✅ ⛔️ 'main' 제거
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // ✅ Firebase 초기화
        FirebaseApp.configure()

        // ✅ Google 로그인 설정
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("❌ Firebase에서 clientID를 가져오지 못했습니다.")
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        // ✅ Kakao SDK 초기화 (네이티브 앱 키 직접 입력 필요)
        KakaoSDK.initSDK(appKey: "네이티브 앱 키 입력")

        // ✅ Naver SDK 초기화
        setupNaverLogin()

        return true
    }

    func setupNaverLogin() {
        let naverInstance = NaverThirdPartyLoginConnection.getSharedInstance()
        naverInstance?.isNaverAppOauthEnable = true
        naverInstance?.isInAppOauthEnable = true
        naverInstance?.serviceUrlScheme = "naver2TGw2d7j1JuLqW5tqmBj"
        naverInstance?.consumerKey = "2TGw2d7j1JuLqW5tqmBj"
        naverInstance?.consumerSecret = "FDDw7lhMxr"
        naverInstance?.appName = "Flowerme"
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        if GIDSignIn.sharedInstance.handle(url) {
            return true
        }

        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.handleOpenUrl(url: url)
        }

        if url.scheme == "naver2TGw2d7j1JuLqW5tqmBj" {
            NaverThirdPartyLoginConnection.getSharedInstance()?.receiveAccessToken(url)
            return true
        }

        return false
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}
