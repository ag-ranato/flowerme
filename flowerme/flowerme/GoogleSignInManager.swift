import GoogleSignIn
import FirebaseAuth
import UIKit

extension UIApplication {
    var topViewController: UIViewController? {
        guard let windowScene = connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return nil
        }
        return getTopViewController(from: rootVC)
    }

    private func getTopViewController(from root: UIViewController) -> UIViewController {
        if let presented = root.presentedViewController {
            return getTopViewController(from: presented)
        }
        if let nav = root as? UINavigationController, let visible = nav.visibleViewController {
            return getTopViewController(from: visible)
        }
        if let tab = root as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(from: selected)
        }
        return root
    }
}

class GoogleSignInManager {
    static let shared = GoogleSignInManager()
    
    func signIn(completion: @escaping () -> Void) {
        print("✅ GoogleSignInManager: signIn() 호출됨")

        guard let rootVC = UIApplication.shared.topViewController else {
            print("❌ 화면에 보이는 VC를 찾지 못함")
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            if let error = error {
                print("❌ Google 로그인 실패: \(error.localizedDescription)")
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                print("❌ idToken 없음")
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            Auth.auth().signIn(with: credential) { _, error in
                if let error = error {
                    print("❌ Firebase 인증 실패: \(error.localizedDescription)")
                } else {
                    print("✅ Google 로그인 및 Firebase 인증 성공")
                    completion()
                }
            }
        }
    }
}
