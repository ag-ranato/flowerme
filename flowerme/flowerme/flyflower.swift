import Foundation
import FirebaseFirestore
import CoreLocation

class FlyFlower: ObservableObject {
    private let db = Firestore.firestore()
    private let collectionName = "flowers"

    // ✅ 꽃 메시지 보내기
    func sendFlower(from location: CLLocation) {
        let data: [String: Any] = [
            "senderLatitude": location.coordinate.latitude,
            "senderLongitude": location.coordinate.longitude,
            "timestamp": Timestamp(date: Date())
        ]

        db.collection(collectionName).addDocument(data: data) { error in
            if let error = error {
                print("🌸 꽃 전송 실패: \(error.localizedDescription)")
            } else {
                print("🌸 꽃이 성공적으로 전송되었습니다.")
            }
        }
    }

    // ✅ 꽃 메시지 수신 리스너 (안전 처리)
    func listenForFlowers(
        near location: CLLocation,
        radiusInMeters: Double = 100.0,
        completion: @escaping ([DocumentSnapshot]) -> Void
    ) {
        db.collection(collectionName)
            .order(by: "timestamp", descending: true)
            .limit(to: 50)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("🌸 꽃 수신 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
                    return
                }

                let nearbyFlowers = documents.filter { doc in
                    let data = doc.data()  // ✅ [String: Any]
                    guard
                        let lat = data["senderLatitude"] as? Double,
                        let lon = data["senderLongitude"] as? Double
                    else {
                        print("⚠️ 위치 데이터가 없거나 잘못됨")
                        return false
                    }

                    let flowerLocation = CLLocation(latitude: lat, longitude: lon)
                    return location.distance(from: flowerLocation) <= radiusInMeters
                }

                completion(nearbyFlowers)
            }
    }
}
