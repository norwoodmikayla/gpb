import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var store: FocusStore

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 18) {
                    HeaderBar(title: "GBP Flash Focus", subtitle: "Daily recall workout")

                    HStack(spacing: 12) {
                        ProgressRing(value: store.stats.targetProgress, label: "today")
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(store.stats.todayCount) of \(store.dailyTarget) reps")
                                .font(.title3.bold())
                                .foregroundStyle(FocusColor.white)
                            Text("\(store.preferredPath.rawValue) level \(store.suggestedLevel) in \(store.preferredMode.rawValue.lowercased()) mode.")
                                .font(.subheadline)
                                .foregroundStyle(FocusColor.muted)
                        }
                        Spacer()
                    }
                    .focusCard()

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        MetricTile(title: "Best level", value: "\(store.stats.bestLevel)", icon: "flag.checkered")
                        MetricTile(title: "Accuracy", value: "\(Int(store.stats.accuracy * 100))%", icon: "checkmark.seal.fill", tint: FocusColor.mint)
                        MetricTile(title: "Score", value: "\(store.stats.totalScore)", icon: "star.fill")
                        MetricTile(title: "Avg recall", value: store.stats.averageResponse == 0 ? "-" : String(format: "%.1fs", store.stats.averageResponse), icon: "timer", tint: FocusColor.mint)
                    }

                    NavigationLink {
                        TrainingView()
                    } label: {
                        HStack {
                            Image(systemName: "bolt.fill")
                            Text("Run Focus Flash")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .font(.headline)
                        .foregroundStyle(FocusColor.deep)
                        .padding(16)
                        .background(FocusColor.gold, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Growth paths")
                            .font(.headline)
                            .foregroundStyle(FocusColor.white)
                        ForEach(GrowthPath.allCases) { path in
                            PathProgressRow(path: path, level: store.level(for: path), best: store.stats.bestLevel(for: path))
                        }
                    }
                    .focusCard()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Achievements")
                            .font(.headline)
                            .foregroundStyle(FocusColor.white)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(store.stats.achievements) { achievement in
                                AchievementTile(achievement: achievement)
                            }
                        }
                    }
                    .focusCard()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Latest attempts")
                            .font(.headline)
                            .foregroundStyle(FocusColor.white)
                        ForEach(store.sessions.prefix(3)) { session in
                            SessionRow(session: session)
                        }
                    }
                    .focusCard()
                }
                .padding(18)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
}

struct SessionRow: View {
    let session: FocusSession

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: session.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title3)
                .foregroundStyle(session.isCorrect ? FocusColor.gold : FocusColor.danger)
            VStack(alignment: .leading, spacing: 3) {
                Text("\(session.mode.rawValue) · level \(session.level)")
                    .font(.subheadline.bold())
                    .foregroundStyle(FocusColor.white)
                Text("\(session.path.shortName) · \(session.sequence.joined(separator: " "))")
                    .font(.caption)
                    .foregroundStyle(FocusColor.muted)
                    .lineLimit(1)
            }
            Spacer()
            Text("\(session.score)")
                .font(.headline)
                .foregroundStyle(FocusColor.gold)
        }
    }
}

private struct PathProgressRow: View {
    let path: GrowthPath
    let level: Int
    let best: Int

    var body: some View {
        let plan = path.plan(for: level)
        HStack(spacing: 12) {
            Image(systemName: path.icon)
                .foregroundStyle(FocusColor.gold)
                .frame(width: 28, height: 28)
            VStack(alignment: .leading, spacing: 3) {
                Text("\(path.rawValue) · Level \(level)")
                    .font(.subheadline.bold())
                    .foregroundStyle(FocusColor.white)
                Text("\(plan.length) flashes · \(plan.exposureLabel) · best \(best)")
                    .font(.caption)
                    .foregroundStyle(FocusColor.muted)
            }
            Spacer()
        }
    }
}

private struct AchievementTile: View {
    let achievement: Achievement

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: achievement.icon)
                .foregroundStyle(achievement.isUnlocked ? FocusColor.gold : FocusColor.muted)
                .frame(width: 28, height: 28)
            Text(achievement.title)
                .font(.caption.bold())
                .foregroundStyle(FocusColor.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(achievement.detail)
                .font(.caption2)
                .foregroundStyle(FocusColor.muted)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(achievement.isUnlocked ? FocusColor.raised : FocusColor.deep.opacity(0.45))
        )
    }
}
