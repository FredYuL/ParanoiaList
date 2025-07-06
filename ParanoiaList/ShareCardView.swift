import SwiftUI

struct ShareCardView: View {
    let items: [ParanoiaItem]

    init(items: [ParanoiaItem]) {
        self.items = items
        print("ShareCardView items count: \(items.count)")
    }

    var body: some View {
        ZStack {
            // 多层渐变背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.green.opacity(0.18),
                    Color.accentColor.opacity(0.12),
                    Color.blue.opacity(0.10),
                    Color.white
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(.ultraThinMaterial)
            )

            VStack(spacing: 18) {
                // 顶部标题
                Text("My Checklist")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.top, 18)

                // 条目列表
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(items) { item in
                            HStack(spacing: 14) {
                                // palette渲染的状态图标
                                Image(systemName: item.status == .checked ? "checkmark.circle.fill" : "circle")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(
                                        item.status == .checked
                                            ? LinearGradient(
                                                colors: [Color.green, Color.green.opacity(0.7)],
                                                startPoint: .top, endPoint: .bottom
                                            )
                                            : LinearGradient(
                                                colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.2)],
                                                startPoint: .top, endPoint: .bottom
                                            ),
                                        Color.white
                                    )
                                    .font(.system(size: 28, weight: .bold))
                                    .shadow(color: .black.opacity(0.08), radius: 2, y: 1)

                                Text(item.title)
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(.ultraThinMaterial)
                                            .shadow(color: .black.opacity(0.04), radius: 1, y: 1)
                                    )
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .frame(maxHeight: 220)

                Spacer(minLength: 0)

                // 底部水印
                HStack {
                    Spacer()
                    Text("Shared from ParanoiaList")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.trailing, 8)
                }
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
        }
        .frame(width: 480, height: 340)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.12), radius: 24, y: 8)
        )
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .padding()
    }
}
