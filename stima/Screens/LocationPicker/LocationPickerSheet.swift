import SwiftUI
import MapKit

/// 畫面 04b · 從地圖選地點
/// 從 NewQuoteInfoScreen / NewClientSheet 的「地圖」按鈕召喚。
/// 設計稿是「faux map + 預設建議列表」，這裡接真實的 MapKit：
/// MKLocalSearchCompleter 即時建議 + SwiftUI Map 顯示選中位置。
struct LocationPickerSheet: View {
    @Binding var address: String
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var completer = LocationSearchCompleter()
    @State private var fetcher = LocationFetcher()
    @State private var pickedTitle: String?
    @State private var pickedSubtitle: String?
    @State private var pickedCoordinate: CLLocationCoordinate2D?
    @State private var showingDeniedAlert = false
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 25.0330, longitude: 121.5654),  // 台北
            span:   MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                mapView
                VStack(spacing: 10) {
                    currentLocationRow
                    SearchField(text: $searchText, placeholder: "搜尋地址、地標")
                    suggestionsList
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .background(Color.bgPaper)
            .navigationTitle("從地圖選地點")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                BottomCTA {
                    PrimaryButton("確認此地點", systemImage: "checkmark") {
                        commit()
                    }
                    .disabled(!canConfirm)
                }
            }
            .onChange(of: searchText) { _, newValue in
                completer.updateQuery(newValue)
            }
            .onAppear {
                // 把現有地址帶進 search 方便修
                if !address.isEmpty && searchText.isEmpty {
                    searchText = address
                }
            }
            .alert("無法存取位置", isPresented: $showingDeniedAlert) {
                Button("好", role: .cancel) {}
            } message: {
                Text("位置權限被拒。請到「設定 → 隱私權與安全性 → 定位服務 → Stima」開啟，再回來試一次。")
            }
        }
        .tint(.accent)
    }

    // MARK: - 使用目前位置

    private var currentLocationRow: some View {
        Button {
            Task { await useCurrentLocation() }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "location.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.accent)
                VStack(alignment: .leading, spacing: 1) {
                    Text("使用目前位置")
                        .font(AppFont.sans(14, weight: .semibold))
                        .foregroundStyle(Color.ink)
                    Text(currentLocationSubtitle)
                        .font(AppFont.sans(11))
                        .foregroundStyle(Color.inkSoft)
                }
                Spacer()
                if case .requesting = fetcher.state {
                    ProgressView().controlSize(.small)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.appSurface,
                        in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                    .strokeBorder(Color.appBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled({
            if case .requesting = fetcher.state { return true } else { return false }
        }())
    }

    private var currentLocationSubtitle: String {
        switch fetcher.state {
        case .idle:                                          "點下取得 GPS 位置"
        case .requesting:                                    "定位中…"
        case .denied:                                        "位置權限被拒"
        case .success(_, let address) where !address.isEmpty: address
        case .success:                                       "已取得座標"
        case .failed(let msg):                               "定位失敗：\(msg)"
        }
    }

    private func useCurrentLocation() async {
        await fetcher.requestCurrentLocation()
        switch fetcher.state {
        case .success(let coord, let address):
            pickedTitle = address.isEmpty ? "目前位置" : address
            pickedSubtitle = nil
            pickedCoordinate = coord
            searchText = pickedTitle ?? ""
            withAnimation(.easeOut(duration: 0.4)) {
                cameraPosition = .region(
                    MKCoordinateRegion(center: coord,
                                       span: MKCoordinateSpan(latitudeDelta: 0.01,
                                                              longitudeDelta: 0.01))
                )
            }
        case .denied:
            showingDeniedAlert = true
        default:
            break
        }
    }

    // MARK: - Map

    private var mapView: some View {
        Map(position: $cameraPosition, interactionModes: [.zoom, .pan]) {
            if let coord = pickedCoordinate {
                Marker("", coordinate: coord)
                    .tint(Color.accent)
            }
        }
        .frame(height: 220)
    }

    // MARK: - Suggestions

    @ViewBuilder
    private var suggestionsList: some View {
        if !completer.results.isEmpty {
            VStack(spacing: 0) {
                ForEach(Array(completer.results.enumerated()), id: \.offset) { idx, item in
                    suggestionRow(item)
                    if idx < completer.results.count - 1 {
                        Rectangle()
                            .fill(Color.appBorder)
                            .frame(height: 1)
                            .padding(.leading, 14)
                    }
                }
            }
            .background(Color.appSurface,
                        in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                    .strokeBorder(Color.appBorder, lineWidth: 1)
            )
        } else if !searchText.isEmpty {
            Text("找不到符合的地點")
                .font(AppFont.sans(13))
                .foregroundStyle(Color.inkSoft)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
        }
    }

    private func suggestionRow(_ item: MKLocalSearchCompletion) -> some View {
        Button {
            select(item)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "mappin")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(AppFont.sans(14, weight: .semibold))
                        .foregroundStyle(Color.ink)
                    if !item.subtitle.isEmpty {
                        Text(item.subtitle)
                            .font(AppFont.sans(12))
                            .foregroundStyle(Color.inkSoft)
                    }
                }
                Spacer()
                if pickedTitle == item.title && pickedSubtitle == item.subtitle {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.accent)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private var canConfirm: Bool {
        pickedTitle != nil || !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func select(_ item: MKLocalSearchCompletion) {
        pickedTitle = item.title
        pickedSubtitle = item.subtitle
        Task {
            if let coord = await completer.resolve(item) {
                pickedCoordinate = coord
                withAnimation(.easeOut(duration: 0.4)) {
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: coord,
                            span:   MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    )
                }
            }
        }
    }

    private func commit() {
        if let title = pickedTitle {
            if let sub = pickedSubtitle, !sub.isEmpty {
                address = "\(title) \(sub)"
            } else {
                address = title
            }
        } else {
            address = searchText.trimmingCharacters(in: .whitespaces)
        }
        dismiss()
    }
}

#Preview {
    @Previewable @State var address = ""
    return Color.bgPaper
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            LocationPickerSheet(address: $address)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
}
