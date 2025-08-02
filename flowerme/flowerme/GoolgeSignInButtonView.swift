import SwiftUI

struct GoogleSignInButtonView: View {
    var completion: () -> Void

    var body: some View {
        Button(action: {
            GoogleSignInManager.shared.signIn {
                completion()
            }
        }) {
            HStack {
                Image(systemName: "globe")
                Text("구글로 로그인")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}
