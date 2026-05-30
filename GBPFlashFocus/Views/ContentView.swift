import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: FocusStore

    var body: some View {
        ZStack {
            FocusBackground()
            if store.hasCompletedOnboarding {
                MainShellView()
            } else {
                OnboardingView()
            }
        }
        .tint(FocusColor.gold)
    }
}

private struct MainShellView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Today", systemImage: "bolt.fill") }
            TrainingView()
                .tabItem { Label("Train", systemImage: "scope") }
            HistoryView()
                .tabItem { Label("History", systemImage: "chart.xyaxis.line") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "slider.horizontal.3") }
        }
    }
}

private struct OnboardingView: View {
    @EnvironmentObject private var store: FocusStore

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 24)
            BrandMark(size: 96)
            VStack(spacing: 8) {
                Text("GBP Flash Focus")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(FocusColor.white)
                    .multilineTextAlignment(.center)
                Text("Short memory reps with fast flashes, clean recall, and a calm daily rhythm.")
                    .font(.headline)
                    .foregroundStyle(FocusColor.muted)
                    .multilineTextAlignment(.center)
            }
            VStack(spacing: 12) {
                OnboardingRow(icon: "eye.fill", title: "Flash sequence", detail: "Numbers and symbols appear one at a time.")
                OnboardingRow(icon: "keyboard.fill", title: "Rebuild order", detail: "Tap the exact order before the timer pressure rises.")
                OnboardingRow(icon: "chart.line.uptrend.xyaxis", title: "Adaptive climb", detail: "Levels, pace, streaks, and history make it a real trainer.")
            }
            .focusCard()
            Button {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.86)) {
                    store.hasCompletedOnboarding = true
                }
            } label: {
                Label("Start Training", systemImage: "play.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
            }
            .buttonStyle(.borderedProminent)
            .tint(FocusColor.gold)
            .foregroundStyle(FocusColor.deep)
            Spacer(minLength: 24)
        }
        .padding(22)
    }
}

private struct OnboardingRow: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(FocusColor.gold)
                .frame(width: 28, height: 28)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(FocusColor.white)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(FocusColor.muted)
            }
            Spacer()
        }
    }
}
