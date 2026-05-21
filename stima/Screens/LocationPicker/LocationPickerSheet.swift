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
    @State private var pickedTitle: String?
    @State private var pickedSubtitle: String?
    @State private var pickedCoordinate: CLLocationCoordinate2D?
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 25.0330, longitude: 121.5654),  // 台北
            span:   MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )

    var body: some View {
        VStack(spacing: 0) {
            navBar
            mapView
            VStack(spacing: 10) {
                SearchField(text: $searchText, placeholder: "搜尋地址、地標")
                suggestionsList
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .background(Color.bgPaper)
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
    }

    // MARK: - Nav bar

    private var navBar: some View {
        HStack {
            Text("從地圖選地點")
                .font(AppFont.sans(17, weight: .bold))
                .foregroundStyle(Color.ink)
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.inkSoft)
                    .frame(width: 32, height: 32)
                    .background(Color.bgSoft, in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 12)
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
