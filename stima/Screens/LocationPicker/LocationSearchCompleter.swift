import Foundation
import MapKit

/// 包 MKLocalSearchCompleter 成 SwiftUI 可觀察的 helper。
/// LocationPickerSheet 內 @State 一份使用。
@MainActor
@Observable
final class LocationSearchCompleter: NSObject, MKLocalSearchCompleterDelegate {
    var results: [MKLocalSearchCompletion] = []

    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
        // 預設集中在台灣
        completer.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 23.7, longitude: 121.0),
            span:   MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
        )
    }

    func updateQuery(_ q: String) {
        let trimmed = q.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            results = []
            completer.queryFragment = ""
        } else {
            completer.queryFragment = trimmed
        }
    }

    /// 解析 completion 拿 coordinate（給 Map view marker 用）
    func resolve(_ completion: MKLocalSearchCompletion) async -> CLLocationCoordinate2D? {
        let request = MKLocalSearch.Request(completion: completion)
        do {
            let response = try await MKLocalSearch(request: request).start()
            return response.mapItems.first?.location.coordinate
        } catch {
            return nil
        }
    }

    // MARK: - MKLocalSearchCompleterDelegate (nonisolated)

    nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let newResults = completer.results
        Task { @MainActor in
            self.results = newResults
        }
    }

    nonisolated func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        Task { @MainActor in
            self.results = []
        }
    }
}
