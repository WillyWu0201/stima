import SwiftUI
import SwiftData

/// 畫面 12 · 客戶簿
/// 從 Settings → 客戶簿 push 進來。可搜尋、可新增（NewClientSheet）、可推進客戶詳情。
struct ContactsScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Client.name) private var clients: [Client]
    @Query private var quotes: [Quote]

    @State private var search = ""
    @State private var addOpen = false

    private var filtered: [Client] {
        guard !search.isEmpty else { return clients }
        return clients.filter {
            $0.name.localizedStandardContains(search)
            || $0.phone.localizedStandardContains(search)
            || $0.address.localizedStandardContains(search)
        }
    }

    /// 每位客戶的案件數 + 已收款總額。
    /// 用 for-loop 避免 reduce closure 在跨檔型別推斷時 type-check timeout。
    private func summary(for client: Client) -> (count: Int, paid: Int) {
        var count = 0
        var paid = 0
        for q in quotes where q.clientName == client.name {
            count += 1
            if q.quoteStatus == .paid {
                paid += q.total
            }
        }
        return (count, paid)
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            VStack(spacing: 0) {
                SearchField(text: $search, placeholder: "搜尋客戶名、電話、地址")
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .padding(.bottom, 8)
            }

            ScrollView {
                LazyVStack(spacing: 8) {
                    if filtered.isEmpty {
                        Text(clients.isEmpty ? "還沒加過客戶。\n點右上「+」開始" : "找不到客戶")
                            .font(AppFont.sans(14))
                            .foregroundStyle(Color.inkSoft)
                            .multilineTextAlignment(.center)
                            .padding(.top, 60)
                            .frame(maxWidth: .infinity)
                    } else {
                        ForEach(filtered) { client in
                            ClientCard(
                                client: client,
                                summary: summary(for: client)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 30)
            }
        }
        .background(Color.bgPaper)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $addOpen) {
            NewClientSheet { newClient in
                modelContext.insert(newClient)
                addOpen = false
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        AppHeader(
            title: "客戶簿",
            subtitle: "師傅的人脈",
            accent: true,
            onBack: { dismiss() }
        ) {
            Button {
                addOpen = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(Color.accent2)
            }
            .accessibilityLabel("新增客戶")
        }
    }
}

// MARK: - ClientCard

private struct ClientCard: View {
    let client: Client
    let summary: (count: Int, paid: Int)

    var body: some View {
        NavigationLink(value: client) {
            VStack(alignment: .leading, spacing: 0) {
                topPart
                    .padding(.horizontal, 14)
                    .padding(.top, 14)
                    .padding(.bottom, 12)

                Rectangle()
                    .fill(Color.appBorder)
                    .frame(height: 1)

                actions
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
            }
            .background(Color.appSurface,
                        in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                    .strokeBorder(Color.appBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var topPart: some View {
        HStack(alignment: .top, spacing: 12) {
            ClientAvatar(name: client.name, style: .neutral)

            VStack(alignment: .leading, spacing: 4) {
                Text(client.name)
                    .font(AppFont.sans(16, weight: .bold))
                    .foregroundStyle(Color.ink)

                if !client.phone.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "phone")
                            .font(.system(size: 11, weight: .semibold))
                        Text(client.phone)
                    }
                    .font(AppFont.mono(12))
                    .foregroundStyle(Color.inkSoft)
                }

                if !client.address.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.system(size: 11, weight: .semibold))
                        Text(client.address)
                            .lineLimit(1)
                    }
                    .font(AppFont.sans(12))
                    .foregroundStyle(Color.inkSoft)
                }
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(summary.count) 案")
                    .font(AppFont.mono(11))
                    .foregroundStyle(Color.inkSoft)
                Money(summary.paid, size: 13, color: .ink)
            }
        }
    }

    private var actions: some View {
        HStack(spacing: 6) {
            QuickActionButton(systemImage: "phone", label: "撥打") {
                callPhone()
            }
            QuickActionButton(systemImage: "mappin", label: "導航") {
                openMaps()
            }
            QuickActionButton(systemImage: "plus", label: "新報價", primary: true) {
                // TODO: 推進新增報價單流程，預填這位客戶
            }
        }
    }

    private func callPhone() {
        guard !client.phone.isEmpty,
              let url = URL(string: "tel:\(client.phone.filter { $0.isNumber })")
        else { return }
        UIApplication.shared.open(url)
    }

    private func openMaps() {
        guard !client.address.isEmpty else { return }
        let encoded = client.address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "http://maps.apple.com/?q=\(encoded)") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    NavigationStack {
        ContactsScreen()
    }
    .environment(PreviewData.settings)
    .modelContainer(PreviewData.container)
}
