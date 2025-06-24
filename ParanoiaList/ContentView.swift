import SwiftUI

struct RoundedCorner: Shape {
    var radius: CGFloat = 20.0
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct ContentView: View {
    @StateObject private var store = ParanoiaStore()
    @State private var newItemText = ""
    @State private var showingAddSheet = false
    @State private var animateCards = false
    @State private var userColorScheme: ColorScheme? = nil
    @State private var showingShareSheet = false
    
    @Environment(\.colorScheme) var colorScheme

    // Computed properties for adaptive colors
    private var resetBackgroundColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.15) : Color.gray.opacity(0.15)
    }
    
    private var resetForegroundColor: Color {
        colorScheme == .dark ? .white : .primary
    }
    
    private var fabColor: Color {
        // Use green as the primary action color
        return .green
    }

    var body: some View {
        NavigationView {
            ZStack {
                // 渐变背景
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        Color(.systemGray6).opacity(0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Header
                            HStack {
                        // Reset Button
                        Button {
                            HapticManager.shared.impact(.medium)
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                store.resetAllItems()
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Reset")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(resetForegroundColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(resetBackgroundColor)
                            )
                                }

                                Spacer()

                        // The old Add Button is removed from here

                        // 切换模式
                        Button {
                            withAnimation {
                                if userColorScheme == .dark {
                                    userColorScheme = .light
                                } else {
                                    userColorScheme = .dark
                                }
                            }
                        } label: {
                            Image(systemName: userColorScheme == .dark ? "moon.fill" : "sun.max.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(userColorScheme == .dark ? .white : .black)
                                .padding(10)
                                .background(
                                    Circle()
                                        .fill(Color(.systemBackground).opacity(0.7))
                                )
                        }

                        Button {
                            showingShareSheet = true
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .padding(10)
                                .background(
                                    Circle()
                                        .fill(Color(.systemBackground).opacity(0.7))
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 10)

                    // 简化的统计视图
                    SimpleStatsView(store: store)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        .offset(x: animateCards ? 0 : -50)
                        .opacity(animateCards ? 1 : 0)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.8)
                            .delay(0.2),
                            value: animateCards
                        )
                    
                    // 项目列表
                    List {
                        ForEach($store.items) { $item in
                            SimpleParanoiaCardView(item: $item, store: store)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                                .offset(x: animateCards ? 0 : 50)
                                .opacity(animateCards ? 1 : 0)
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.8)
                                    .delay(0.3),
                                    value: animateCards
                                )
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                }
                
                // #9. Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                    Button {
                            showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .frame(width: 60, height: 60)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .shadow(radius: 4, y: 2)
                        }
                        .padding()
                        .zIndex(1)
                    }
                }

                // 自定义添加弹窗
                if showingAddSheet {
                    AddItemSheet(
                        isPresented: $showingAddSheet,
                        text: $newItemText
                    ) {
                        if !newItemText.trimmingCharacters(in: .whitespaces).isEmpty {
                            HapticManager.shared.notification(.success)
                            store.addItem(title: newItemText.trimmingCharacters(in: .whitespaces))
                        }
                    }
                    .zIndex(10)
                }

                if showingShareSheet {
                    let unchecked = store.items.filter { $0.status == .unchecked }
                    let allChecked = unchecked.isEmpty
                    let uncheckedTitles = unchecked.map { $0.title }
                    ShareCard(
                        allChecked: allChecked,
                        uncheckedTitles: uncheckedTitles
                    ) {
                        // 分享内容
                        let shareText: String
                        if allChecked {
                            shareText = "I have completed all my checklist items! ✅"
                        } else {
                            shareText = "Still need to check:\n" + uncheckedTitles.map { "• \($0)" }.joined(separator: "\n")
                        }
                        let av = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootVC = windowScene.windows.first?.rootViewController {
                            rootVC.present(av, animated: true)
                        }
                        showingShareSheet = false
                    }
                    .zIndex(20)
                    .onTapGesture {} // 防止点击卡片关闭
                    // 背景遮罩
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                        .onTapGesture { withAnimation { showingShareSheet = false } }
                        .zIndex(19)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5)) {
                    animateCards = true
                }
            }
        }
        .preferredColorScheme(userColorScheme)
        .navigationViewStyle(.stack)
        .animation(.spring(), value: showingAddSheet)
    }
    
    private func deleteItems(offsets: IndexSet) {
        HapticManager.shared.impact(.medium)
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            for index in offsets {
                store.removeItem(store.items[index])
            }
        }
    }
}

struct SimpleStatsView: View {
    @ObservedObject var store: ParanoiaStore
    
    var body: some View {
        let stats = store.getStats()
        let total = stats.checked + stats.unchecked
        let progress = total > 0 ? Double(stats.checked) / Double(total) : 0.0
        
        HStack(spacing: 20) {
            // Merged Checked + Progress Ring
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 8)
                        .opacity(0.1)
                        .foregroundColor(.gray)

                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                        .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.green)
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear, value: progress)
                    
                    Text("\(stats.checked)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                .frame(width: 66, height: 66)
                
                Text("Checked")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)

            // Corresponding Unchecked View
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(stats.unchecked == 0 ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))

                    if stats.unchecked == 0 {
                        Image(systemName: "checkmark")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.green)
                    } else {
                        Text("\(stats.unchecked)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                }
                .frame(width: 66, height: 66)
                
                Text(stats.unchecked == 0 ? "All Done!" : "Unchecked")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(stats.unchecked == 0 ? .green : .secondary)
            }
            .frame(maxWidth: .infinity)
            .animation(.easeInOut, value: stats.unchecked)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [.clear, Color.accentColor.opacity(0.3), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct SimpleParanoiaCardView: View {
    @Binding var item: ParanoiaItem
    @ObservedObject var store: ParanoiaStore
    @State private var isPressed = false
    @State private var showCheckmark = false // Re-purposed for checkmark animation

    var body: some View {
        Button(action: {
            HapticManager.shared.impact(.light)

            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                store.toggleStatus(for: item)
                // This will trigger the animation based on item.status change
            }
        }) {
            HStack(spacing: 16) {
                // New, simpler, high-end status indicator
                ZStack {
                    Circle()
                        .strokeBorder(Color.gray.opacity(0.4), lineWidth: 2)
                        .background(Circle().fill(Color.green).opacity(item.status == .checked ? 1 : 0))

                    if item.status == .checked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .transition(.scale.animation(.spring(response: 0.4, dampingFraction: 0.6)))
                    }
                }
                .frame(width: 50, height: 50)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: item.status)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(.system(size: 20, design: .serif))
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Time appears on the right, aligned to the bottom, only when checked
                if let date = item.lastChecked {
                    VStack {
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                            Text(date.formatted(.dateTime.hour().minute()))
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .transition(.opacity.animation(.easeIn(duration: 0.3)))
                }
            }
            .padding(20)
            .background(
                ZStack {
                    // Base material background
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.thinMaterial)

                    // Green overlay for checked state
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.green)
                        .opacity(item.status == .checked ? 0.2 : 0)
                        .animation(.easeIn(duration: 0.4), value: item.status)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(.white.opacity(0.15), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(
                color: item.status.color.opacity(0.1),
                radius: isPressed ? 2 : 8,
                x: 0,
                y: isPressed ? 1 : 4
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// 触觉反馈管理器
class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.impactOccurred()
    }
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(type)
    }
}

extension ParanoiaStatus {
    var color: Color {
        switch self {
        case .unchecked: return .gray
        case .checked: return .green
        }
    }
    
    var iconName: String {
        switch self {
        case .unchecked: return "questionmark.circle"
        case .checked: return "checkmark.circle.fill"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct AddItemSheet: View {
    @Binding var isPresented: Bool
    @Binding var text: String
    var onAdd: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            // 背景遮罩
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .onTapGesture { withAnimation { isPresented = false } }

            VStack(spacing: 0) {
                VStack(spacing: 24) {
                    // 顶部图标
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.accentColor)
                        .padding(.top, 8)

                    // 标题
                    Text("Add New Item")
                        .font(.custom("PlayfairDisplay-Bold", size: 24))
                        .foregroundColor(.primary)

                    // 输入框
                    TextField("What do you want to track?", text: $text)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.accentColor.opacity(0.12), lineWidth: 1)
                        )
                        .font(.custom("PlayfairDisplay-Regular", size: 18))
                        .focused($isFocused)
                        .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
                    // 新增padding
                    Spacer().frame(height: 15)
                }
                .padding(.horizontal, 28)
                .padding(.top, 32)
                .background(
                    RoundedCorner(radius: 20, corners: [.topLeft, .topRight])
                        .fill(.ultraThinMaterial)
                )

                // 分割线
                Divider()

                // 横向按钮
                HStack(spacing: 0) {
                    Button(action: {
                        withAnimation { isPresented = false }
                        text = ""
                    }) {
                        Text("Cancel")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .contentShape(Rectangle())
                    }

                    Rectangle()
                        .fill(Color.secondary.opacity(0.15))
                        .frame(width: 1, height: 32)
                        .padding(.vertical, 10)

                    Button(action: {
                        if !text.trimmingCharacters(in: .whitespaces).isEmpty {
                            onAdd()
                            withAnimation { isPresented = false }
                            text = ""
                        }
                    }) {
                        Text("Add")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(
                                text.trimmingCharacters(in: .whitespaces).isEmpty
                                    ? Color.green.opacity(0.5)
                                    : Color.green
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 0))
                            .contentShape(Rectangle())
                    }
                    .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .background(
                    RoundedCorner(radius: 20, corners: [.bottomLeft, .bottomRight])
                        .fill(.ultraThinMaterial)
                )
            }
            .frame(maxWidth: 400)
            .clipShape(RoundedCorner(radius: 20, corners: [.allCorners]))
            .shadow(color: .black.opacity(0.12), radius: 24, y: 8)
            .padding(.horizontal, 32)
            .transition(.scale.combined(with: .opacity))
            .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { isFocused = true } }
        }
        .animation(.spring(), value: isPresented)
    }
}

struct ShareCard: View {
    let allChecked: Bool
    let uncheckedTitles: [String]
    let shareAction: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: allChecked ? "checkmark.seal.fill" : "exclamationmark.circle")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(allChecked ? .green : .orange)
                .padding(.top, 8)

            Text(allChecked ? "All Done!" : "Still Unchecked")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            if allChecked {
                Text("I have completed all my checklist items!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Still need to check:")
                        .font(.body)
                        .foregroundColor(.secondary)
                    ForEach(uncheckedTitles, id: \.self) { title in
                        HStack {
                            Image(systemName: "circle")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(title)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }

            Button(action: shareAction) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(14)
            }
        }
        .padding(32)
        .background(.ultraThinMaterial)
        .cornerRadius(28)
        .shadow(color: .black.opacity(0.12), radius: 24, y: 8)
        .padding(.horizontal, 32)
        .transition(.scale.combined(with: .opacity))
    }
}
