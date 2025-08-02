import SwiftUI
import KakaoSDKAuth
import KakaoSDKUser
import NaverThirdPartyLogin

struct LoginView: View {
    var onLoginSuccess: () -> Void
    @State private var naverLoginHandler: NaverLoginHandler? = nil

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Flowerme에 로그인")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 10)

            GoogleSignInButtonView {
                print("✅ 구글 로그인 실행!")
                onLoginSuccess()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .padding(.horizontal, 40)

            Button(action: {
                kakaoLogin()
            }) {
                HStack {
                    Image(systemName: "message.fill")
                    Text("카카오 로그인")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.yellow)
                .foregroundColor(.black)
                .cornerRadius(8)
            }
            .padding(.horizontal, 40)

            Button(action: {
                naverLogin()
            }) {
                HStack {
                    Image(systemName: "n.circle.fill")
                    Text("네이버 로그인")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .padding()
    }

    func kakaoLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { token, error in
                if let error = error {
                    print("❌ 카카오톡 로그인 실패: \(error.localizedDescription)")
                } else {
                    fetchKakaoUserInfo()
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { token, error in
                if let error = error {
                    print("❌ 카카오계정 로그인 실패: \(error.localizedDescription)")
                } else {
                    fetchKakaoUserInfo()
                }
            }
        }
    }

    func fetchKakaoUserInfo() {
        UserApi.shared.me { user, error in
            if let error = error {
                print("❌ 사용자 정보 요청 실패: \(error.localizedDescription)")
            } else {
                onLoginSuccess()
            }
        }
    }

    func naverLogin() {
        guard let naverInstance = NaverThirdPartyLoginConnection.getSharedInstance() else {
            print("❌ NaverThirdPartyLoginConnection 초기화 실패")
            return
        }

        let handler = NaverLoginHandler { accessToken in
            fetchNaverUserInfo(accessToken: accessToken)
        }
        self.naverLoginHandler = handler
        naverInstance.delegate = handler
        naverInstance.requestThirdPartyLogin()
    }

    func fetchNaverUserInfo(accessToken: String) {
        let url = URL(string: "https://openapi.naver.com/v1/nid/me")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("❌ 네이버 사용자 정보 요청 실패: \(error.localizedDescription)")
                return
            }
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let _ = json["response"] as? [String: Any] {
                DispatchQueue.main.async {
                    onLoginSuccess()
                }
            }
        }.resume()
    }
}

