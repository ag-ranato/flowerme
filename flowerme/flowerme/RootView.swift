import SwiftUI

struct RootView: View {
    @State private var isLoggedIn = false
    
    var body: some View {
        if isLoggedIn {
            ContentView()  // ✅ 로그인 성공 → 꽃 보내기 메인 화면
        } else {
            LoginView(onLoginSuccess: {
                isLoggedIn = true
            })
        }
    }
}
