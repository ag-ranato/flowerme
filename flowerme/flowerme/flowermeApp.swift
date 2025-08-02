import SwiftUI
import SwiftData
import FirebaseCore

@main
struct flowermeApp: App {
    
    // ✅ AppDelegate 연결만 유지 (여기서 Firebase 초기화 관리)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // ✅ FirebaseApp.configure() 제거 (중복 방지)
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView() // ContentView() 또는 RootView 사용
        }
        .modelContainer(sharedModelContainer)
    }
}
