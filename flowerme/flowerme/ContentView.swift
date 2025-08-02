import SwiftUI
import CoreLocation
import FirebaseFirestore

struct ContentView: View {
    @State private var isSending = false
    @State private var sendSuccess = false
    @State private var nearbyUserCount = 5
    @State private var latestFlowerMessage: String = ""
    @StateObject var locationManager = LocationManager()
    @StateObject var flowerManager = FlyFlower()
    
    var body: some View {
        VStack(spacing: 30) {
            Text("마음 속 꽃을 전해보세요")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 50)
            
            Text(latestFlowerMessage)
                .font(.subheadline)
                .foregroundColor(.purple)
                .padding(.bottom ,5)
            
            // 🌸 꽃 이모지 버튼
            Button(action: {
                sendFlower()
            }) {
                Text("🌸")
                    .font(.system(size: 100))
                    .scaleEffect(isSending ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: isSending)
            }
            .disabled(isSending)
            
            if let location = locationManager.userLocation {
                Text("위도: \(location.latitude), 경도: \(location.longitude)")
            }
            
            if sendSuccess {
                Text("꽃을 보냈어요 💌")
                    .foregroundColor(.pink)
                    .transition(.opacity)
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                Text("근처에 있는 사용자: \(nearbyUserCount)명")
                    .font(.subheadline)
                Text("반경 내 모든 사용자에게 꽃이 전달됩니다.")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 40)
        }
        .padding()
        .onReceive(locationManager.$userLocation.compactMap { $0 }) { location in
            print("✅ 위치 업데이트됨 → 리스너 실행")
            
            let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            
            flowerManager.listenForFlowers(near: clLocation, radiusInMeters: 5000.0) { documents in
                print("🌸 [DEBUG] 수신된 전체 문서 개수: \(documents.count)")
                
                guard let first = documents.first else {
                    print("⚠️ 꽃 데이터가 없습니다.")
                    return
                }
                
                if let data = first.data() {
                    print("🌸 [DEBUG] 첫 문서 데이터: \(data)")
                    if let timestamp = data["timestamp"] as? Timestamp {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "HH:mm:ss"
                        let timeString = formatter.string(from: timestamp.dateValue())
                        latestFlowerMessage = "💐 꽃을 받았어요! (\(timeString))"
                    } else {
                        print("⚠️ timestamp 필드가 없거나 타입이 잘못됨")
                    }
                } else {
                    print("⚠️ 문서에 데이터가 없음")
                }
            }
        }
    }
    
    func sendFlower() {
        isSending = true
        sendSuccess = false
        
        if let location = locationManager.userLocation {
            let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            flowerManager.sendFlower(from: clLocation)
        } else {
            print("❌ 현재 위치가 없어 꽃을 전송할 수 없음")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSending = false
            sendSuccess = true
        }
    }
}

