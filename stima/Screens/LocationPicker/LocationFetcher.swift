import Foundation
import CoreLocation
import MapKit

/// 包 CLLocationManager 成 async/await + @Observable 形式。
/// 一次性取目前位置 → reverse geocode 變地址字串。
@MainActor
@Observable
final class LocationFetcher: NSObject, CLLocationManagerDelegate {

    enum State: Equatable {
        case idle
        case requesting
        case denied            // 使用者拒絕或受限
        case success(coordinate: CLLocationCoordinate2D, address: String)
        case failed(String)

        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.requesting, .requesting), (.denied, .denied): true
            case (.success(let a, let sa), .success(let b, let sb)):
                a.latitude == b.latitude && a.longitude == b.longitude && sa == sb
            case (.failed(let a), .failed(let b)): a == b
            default: false
            }
        }
    }

    var state: State = .idle

    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Error>?
    private var authContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    /// 請求目前位置（含 permission flow），完成後 state 變 .success / .denied / .failed
    func requestCurrentLocation() async {
        state = .requesting

        // 1. 確認授權
        var status = manager.authorizationStatus
        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
            status = await withCheckedContinuation { cont in
                authContinuation = cont
            }
        }

        guard status.isAuthorized else {
            state = .denied
            return
        }

        // 2. 一次性取座標
        do {
            let location: CLLocation = try await withCheckedThrowingContinuation { cont in
                continuation = cont
                manager.requestLocation()
            }

            // 3. 反查地址（用 iOS 26 新 API MKReverseGeocodingRequest 取代 CLGeocoder）
            let address = await reverseGeocode(location)
            state = .success(coordinate: location.coordinate, address: address)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    private func reverseGeocode(_ location: CLLocation) async -> String {
        guard let request = MKReverseGeocodingRequest(location: location) else { return "" }
        do {
            let items = try await request.mapItems
            return items.first?.name ?? ""
        } catch {
            return ""
        }
    }

    // MARK: - CLLocationManagerDelegate (nonisolated)

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        Task { @MainActor in
            continuation?.resume(returning: location)
            continuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            continuation?.resume(throwing: error)
            continuation = nil
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            authContinuation?.resume(returning: status)
            authContinuation = nil
        }
    }
}

private extension CLAuthorizationStatus {
    /// 把 iOS / macOS / watchOS / tvOS / visionOS 的 in-use 授權差異收斂在一個 helper。
    var isAuthorized: Bool {
        #if os(iOS) || os(watchOS) || os(tvOS) || os(visionOS)
        return self == .authorizedWhenInUse || self == .authorizedAlways
        #else
        return self == .authorizedAlways
        #endif
    }
}
