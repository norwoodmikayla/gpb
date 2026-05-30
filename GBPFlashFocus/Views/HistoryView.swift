import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var store: FocusStore

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 18) {
                    HeaderBar(title: "Recall History", subtitle: "\(store.sessions.count) saved attempts")
                    ForEach(store.sessions) { session in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label(session.isCorrect ? "Perfect" : "Missed", systemImage: session.isCorrect ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                                    .font(.headline)
                                    .foregroundStyle(session.isCorrect ? FocusColor.gold : FocusColor.danger)
                                Spacer()
                                Text(session.date.focusShortDate)
                                    .font(.caption)
                                    .foregroundStyle(FocusColor.muted)
                            }
                            HStack {
                                Text(session.mode.rawValue)
                                Text(session.path.shortName)
                                Text("Level \(session.level)")
                                Spacer()
                                Text("\(session.score) pts")
                                    .foregroundStyle(FocusColor.gold)
                            }
                            .font(.subheadline.bold())
                            .foregroundStyle(FocusColor.white)
                            Text(session.sequence.joined(separator: " "))
                                .font(.system(.body, design: .rounded).weight(.semibold))
                                .foregroundStyle(FocusColor.muted)
                        }
                        .focusCard()
                    }
                }
                .padding(18)
            }
        }
        .navigationViewStyle(.stack)
    }
}
