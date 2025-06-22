import SwiftUI

struct ContentView: View {
    @StateObject private var store = ParanoiaStore()
    @State private var newItemText: String = ""
    @State private var showingAddAlert = false
    @State private var animateCards = false
    
    @Environment(\.colorScheme) var colorScheme

    // Computed properties for adaptive colors
    private var resetButtonGradient: LinearGradient {
        let colors: [Color]
        if colorScheme == .dark {
            // A dark gray gradient for dark mode
            colors = [Color(white: 0.25), Color(white: 0.2)]
        } else {
            // Original accent color for light mode
            colors = [Color.accentColor, Color.accentColor.opacity(0.8)]
        }
        return LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    private var resetButtonShadowColor: Color {
        // No shadow in dark mode, accent color shadow in light mode
        colorScheme == .dark ? .clear : Color.accentColor.opacity(0.3)
    }
    
    private var fabColor: Color {
        // Dark gray in dark mode, accent color in light mode
        colorScheme == .dark ? Color(white: 0.25) : Color.accentColor
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
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(resetButtonGradient)
                                    .shadow(color: resetButtonShadowColor, radius: 4, x: 0, y: 2)
                            )
                        }

                        Spacer()

                        // The old Add Button is removed from here
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
                        ForEach(store.items, id: \.id) { item in
                            SimpleParanoiaCardView(item: item, store: store)
                                .id(item.id) // 强制刷新绑定，避免重用 bug
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
                            HapticManager.shared.impact(.light)
                            showingAddAlert = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .frame(width: 60, height: 60)
                                .background(fabColor)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .shadow(radius: 4, y: 2)
                        }
                        .padding()
                        .transition(.scale.animation(.spring()))
                    }
                }
            }
            .navigationBarHidden(true)
            .alert("Add New Item", isPresented: $showingAddAlert) {
                TextField("What do you want to track?", text: $newItemText)
                Button("Add") {
                    if !newItemText.trimmingCharacters(in: .whitespaces).isEmpty {
                        HapticManager.shared.notification(.success)
                        store.addItem(title: newItemText.trimmingCharacters(in: .whitespaces))
                        newItemText = ""
                    }
                }
                Button("Cancel", role: .cancel) {
                    newItemText = ""
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5)) {
                    animateCards = true
                }
            }
        }
        .navigationViewStyle(.stack)
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
    let item: ParanoiaItem
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
