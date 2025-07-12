import SwiftUI
import Foundation
import UIKit

let cbtTips: [String] = [
    "This is a false alarm from my brain. I don't need to act on it.",
    "Feeling unsure doesn't mean something's wrong.",
    "I've checked already — checking again won't make me feel better.",
    "It's okay to feel uncomfortable. I can sit with it.",
    "I've had this thought before — and everything turned out fine.",
    "The goal is to tolerate doubt, not eliminate it.",
    "Doing nothing right now is actually progress.",
    "Resisting the urge is how I retrain my brain.",
    "It's just a thought, not a fact.",
    "My safety doesn't depend on checking again.",
    "I can feel anxious and still make the right choice.",
    "If I delay checking, the urge will pass.",
    "Discomfort won't hurt me — it just feels intense.",
    "I'm learning to trust my past actions.",
    "Repeating the same action won't bring new certainty.",
    "This fear has no evidence — only imagination.",
    "One time of trusting myself is better than 10 checks.",
    "What if is not a reason to act.",
    "My memory is not perfect, and that's okay.",
    "The more I check, the more anxious I stay.",
    "I've done my part. Now I let go.",
    "Just because I can think it doesn't mean it's true.",
    "Relief from checking is temporary — I want long-term peace.",
    "I'm building resilience, not chasing certainty.",
    "My brain wants safety. But safety is already here.",
    "This worry doesn't define me.",
    "Each time I resist, I gain strength.",
    "I accept doubt. I don't need to solve it.",
    "I've locked the door. That's a fact. The rest is noise.",
    "I choose calm over control."
]

func todayTipIndex() -> Int {
    let calendar = Calendar.current
    let startDate = calendar.startOfDay(for: Date(timeIntervalSince1970: 1704067200))
    let today = calendar.startOfDay(for: Date())
    let days = calendar.dateComponents([.day], from: startDate, to: today).day ?? 0
    return days % cbtTips.count
}

struct CBTTipsView: View {
    @State private var revealed = false
    @State private var showCopied = false
    @State private var animateCard = false
    @Namespace private var animation

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()
                if revealed {
                    VStack(spacing: 0) {
                        // 顶部icon
                        Image(systemName: "quote.opening")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(.accentColor)
                            .padding(.top, 12)
                            .opacity(animateCard ? 1 : 0)
                            .offset(y: animateCard ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(0.1), value: animateCard)

                        // 卡片内容
                        ZStack {
                            // 渐变边框
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.accentColor.opacity(0.18), .green.opacity(0.18), .clear],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                                .background(
                                    // 毛玻璃材质
                                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                                        .fill(.ultraThinMaterial)
                                )
                                .shadow(color: .black.opacity(0.10), radius: 18, y: 8)
                                .overlay(
                                    // 内阴影
                                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                                        .stroke(Color.black.opacity(0.04), lineWidth: 1)
                                        .blur(radius: 1)
                                )

                            VStack(spacing: 18) {
                                Text("Today's CBT Tip")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.accentColor)
                                    .opacity(animateCard ? 1 : 0)
                                    .offset(y: animateCard ? 0 : 10)
                                    .animation(.easeOut(duration: 0.5).delay(0.15), value: animateCard)

                                Text(cbtTips[todayTipIndex()])
                                    .font(.custom("PlayfairDisplay-Regular", size: 22))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                    .opacity(animateCard ? 1 : 0)
                                    .offset(y: animateCard ? 0 : 20)
                                    .animation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.22), value: animateCard)

                                Button(action: {
                                    UIPasteboard.general.string = cbtTips[todayTipIndex()]
                                    withAnimation { showCopied = true }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                        withAnimation { showCopied = false }
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "doc.on.doc")
                                        Text("Copy")
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 32)
                                    .background(Color.green)
                                    .cornerRadius(16)
                                    .shadow(radius: 2, y: 1)
                                }
                                .padding(.top, 8)
                                .opacity(animateCard ? 1 : 0)
                                .scaleEffect(animateCard ? 1 : 0.8)
                                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.35), value: animateCard)

                                Button(action: {
                                    shareTipCard(tip: cbtTips[todayTipIndex()])
                                }) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.up")
                                        Text("Share")
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 32)
                                    .background(Color.accentColor)
                                    .cornerRadius(16)
                                    .shadow(radius: 2, y: 1)
                                }
                                .padding(.top, 8)
                                .opacity(animateCard ? 1 : 0)
                                .scaleEffect(animateCard ? 1 : 0.8)
                                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.38), value: animateCard)

                                if showCopied {
                                    Text("Copied!")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                        .transition(.opacity)
                                }
                            }
                            .padding(32)
                        }
                        .padding(.horizontal, 12)
                        .scaleEffect(animateCard ? 1 : 0.92)
                        .opacity(animateCard ? 1 : 0)
                        .animation(.spring(response: 0.7, dampingFraction: 0.7), value: animateCard)
                    }
                    .onAppear {
                        animateCard = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            withAnimation { animateCard = true }
                        }
                    }
                } else {
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            revealed = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "eye")
                            Text("Reveal Today's Tip")
                        }
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 18)
                        .padding(.horizontal, 48)
                        .background(
                            LinearGradient(
                                colors: [Color.green, Color.accentColor],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(24)
                        .shadow(color: .black.opacity(0.10), radius: 12, y: 4)
                        .scaleEffect(revealed ? 0.95 : 1)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: revealed)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                Spacer()
            }
        }
    }
}

struct CBTTipsView_Previews: PreviewProvider {
    static var previews: some View {
        CBTTipsView()
    }
}

struct TipShareCard: View {
    let tip: String
    var body: some View {
        ZStack {
            LinearGradient(colors: [.purple, .blue], startPoint: .top, endPoint: .bottom)
            VStack(spacing: 24) {
                Text("Everyday Tip")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Text(tip)
                    .font(.title3)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Spacer()
                Text("From ParanoiaList")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
        }
        .frame(width: 340, height: 220)
        .cornerRadius(24)
        .shadow(radius: 8)
    }
}

@MainActor
func shareTipCard(tip: String) {
    let card = TipShareCard(tip: tip)
    let renderer = ImageRenderer(content: card)
    renderer.scale = 3
    if let uiImage = renderer.uiImage {
        let activityVC = UIActivityViewController(activityItems: [uiImage], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = rootVC.view
                popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }
}
