
import Foundation
import NaverThirdPartyLogin

class NaverLoginHandler: NSObject, NaverThirdPartyLoginConnectionDelegate {
    var onLoginSuccess: (String) -> Void
    
    init(onLoginSuccess: @escaping (String) -> Void) {
        self.onLoginSuccess = onLoginSuccess
    }

    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        guard let accessToken = NaverThirdPartyLoginConnection.getSharedInstance()?.accessToken else {
            print("❌ AccessToken 획득 실패")
            return
        }
        print("✅ Naver 로그인 성공 → 토큰: \(accessToken)")
        onLoginSuccess(accessToken)
    }

    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {}
    func oauth20ConnectionDidFinishDeleteToken() {}
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print("❌ Naver 로그인 실패: \(error.localizedDescription)")
    }
}
