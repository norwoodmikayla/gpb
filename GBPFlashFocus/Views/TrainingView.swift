import SwiftUI
import UIKit

struct TrainingView: View {
    @EnvironmentObject private var store: FocusStore
    @State private var mode: FocusMode = .digits
    @State private var path: GrowthPath = .memory
    @State private var sequence: [String] = []
    @State private var answer: [String] = []
    @State private var visibleToken = "?"
    @State private var phase: Phase = .ready
    @State private var startedAt = Date()
    @State private var lastResult: FocusSession?
    @State private var activePlan = GrowthPath.memory.plan(for: 1)
    @State private var showCongrats = false

    private var currentPlan: RoundPlan {
        store.plan(for: path)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 18) {
                    HeaderBar(title: "Focus Flash", subtitle: "Watch, hold, rebuild")

                    controls
                    flashPanel
                    answerPanel
                    keypad
                    resultPanel
                }
                .padding(18)
            }
            .onAppear {
                mode = store.preferredMode
                path = store.preferredPath
                activePlan = store.plan(for: store.preferredPath)
            }
            .alert("Clean recall", isPresented: $showCongrats) {
                Button("Next Round", action: startRound)
                Button("Stay Here", role: .cancel) { }
            } message: {
                if let lastResult {
                    Text("Perfect order at \(lastResult.path.shortName) level \(lastResult.level). Score \(lastResult.score).")
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    private var controls: some View {
        VStack(spacing: 12) {
            Picker("Mode", selection: $mode) {
                ForEach(FocusMode.allCases) { mode in
                    Label(mode.rawValue, systemImage: mode.icon).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            Picker("Growth", selection: $path) {
                ForEach(GrowthPath.allCases) { path in
                    Text(path.shortName).tag(path)
                }
            }
            .pickerStyle(.segmented)

            HStack(spacing: 12) {
                Image(systemName: path.icon)
                    .foregroundStyle(FocusColor.gold)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(path.rawValue) · Level \(currentPlan.level)")
                        .font(.headline)
                        .foregroundStyle(FocusColor.white)
                    Text("\(currentPlan.length) flashes · \(currentPlan.exposureLabel) each · \(currentPlan.focus)")
                        .font(.caption)
                        .foregroundStyle(FocusColor.muted)
                }
                Spacer()
            }
        }
        .focusCard()
        .disabled(phase == .showing)
    }

    private var flashPanel: some View {
        VStack(spacing: 16) {
            Text(phase.title)
                .font(.subheadline.bold())
                .foregroundStyle(FocusColor.muted)
            Text(visibleToken)
                .font(.system(size: 82, weight: .black, design: .rounded))
                .foregroundStyle(phase == .result ? FocusColor.gold : FocusColor.white)
                .frame(maxWidth: .infinity, minHeight: 150)
                .background(FocusColor.raised.opacity(0.72), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            Button(action: startRound) {
                Label(phase == .ready ? "Start Gentle Round" : "Next Round", systemImage: "play.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
            }
            .buttonStyle(.borderedProminent)
            .tint(FocusColor.gold)
            .foregroundStyle(FocusColor.deep)
            .disabled(phase == .showing)
        }
        .focusCard()
    }

    private var answerPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Your order")
                    .font(.headline)
                    .foregroundStyle(FocusColor.white)
                Spacer()
                Button {
                    answer.removeLast()
                } label: {
                    Image(systemName: "delete.left.fill")
                        .frame(width: 38, height: 34)
                }
                .disabled(answer.isEmpty || phase != .input)
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                ForEach(0..<max(sequence.count, 3), id: \.self) { index in
                    TokenChip(text: index < answer.count ? answer[index] : "·", isSelected: index < answer.count)
                }
            }
        }
        .focusCard()
    }

    private var keypad: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
            ForEach(mode.pool, id: \.self) { token in
                Button {
                    append(token)
                } label: {
                    TokenChip(text: token)
                }
                .buttonStyle(.plain)
                .disabled(phase != .input)
            }
        }
    }

    @ViewBuilder
    private var resultPanel: some View {
        if let lastResult {
            VStack(alignment: .leading, spacing: 10) {
                Text(lastResult.isCorrect ? "Clean recall" : "Review the order")
                    .font(.headline)
                    .foregroundStyle(lastResult.isCorrect ? FocusColor.gold : FocusColor.danger)
                if lastResult.isCorrect {
                    Text("Sequence: \(lastResult.sequence.joined(separator: " "))")
                        .foregroundStyle(FocusColor.white)
                } else {
                    Text("Red tiles show the exact position where recall drifted.")
                        .font(.caption)
                        .foregroundStyle(FocusColor.muted)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                        ForEach(lastResult.sequence.indices, id: \.self) { index in
                            ReviewToken(
                                index: index + 1,
                                expected: lastResult.sequence[index],
                                actual: index < lastResult.answer.count ? lastResult.answer[index] : "·"
                            )
                        }
                    }
                }
                Text("Score \(lastResult.score) · \(String(format: "%.1fs", lastResult.responseTime))")
                    .font(.caption.bold())
                    .foregroundStyle(FocusColor.mint)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .focusCard()
        }
    }

    private func startRound() {
        store.preferredMode = mode
        store.preferredPath = path
        activePlan = currentPlan
        lastResult = nil
        showCongrats = false
        answer = []
        sequence = store.makeSequence(plan: activePlan, mode: mode)
        phase = .showing
        visibleToken = "Ready"
        Task { await playSequence() }
    }

    private func playSequence() async {
        await MainActor.run { visibleToken = "Ready" }
        try? await Task.sleep(nanoseconds: 720_000_000)
        await MainActor.run { visibleToken = "GO" }
        try? await Task.sleep(nanoseconds: 420_000_000)
        for token in sequence {
            await MainActor.run {
                visibleToken = token
                if store.hapticsEnabled { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
            }
            try? await Task.sleep(nanoseconds: UInt64(activePlan.exposure * 1_000_000_000))
            await MainActor.run { visibleToken = "" }
            try? await Task.sleep(nanoseconds: UInt64(activePlan.gap * 1_000_000_000))
        }
        await MainActor.run {
            startedAt = .now
            visibleToken = "?"
            phase = .input
        }
    }

    private func append(_ token: String) {
        guard answer.count < sequence.count else { return }
        answer.append(token)
        if answer.count == sequence.count {
            store.record(mode: mode, path: path, plan: activePlan, sequence: sequence, answer: answer, startedAt: startedAt)
            lastResult = store.sessions.first
            visibleToken = store.sessions.first?.isCorrect == true ? "✓" : "×"
            phase = .result
            if store.sessions.first?.isCorrect == true {
                if store.hapticsEnabled { UINotificationFeedbackGenerator().notificationOccurred(.success) }
                showCongrats = true
            } else if store.hapticsEnabled {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }
}

private struct ReviewToken: View {
    let index: Int
    let expected: String
    let actual: String

    private var isCorrect: Bool {
        expected == actual
    }

    var body: some View {
        VStack(spacing: 5) {
            Text("#\(index)")
                .font(.caption2.bold())
                .foregroundStyle(FocusColor.muted)
            Text(actual)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(isCorrect ? FocusColor.deep : FocusColor.white)
                .frame(maxWidth: .infinity, minHeight: 42)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(isCorrect ? FocusColor.gold : FocusColor.danger)
                )
            if isCorrect {
                Label("OK", systemImage: "checkmark")
                    .font(.caption2.bold())
                    .foregroundStyle(FocusColor.gold)
            } else {
                Text("Need \(expected)")
                    .font(.caption2.bold())
                    .foregroundStyle(FocusColor.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(8)
        .background(FocusColor.deep.opacity(0.42), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private enum Phase {
    case ready
    case showing
    case input
    case result

    var title: String {
        switch self {
        case .ready: "Ready"
        case .showing: "Memorize"
        case .input: "Rebuild now"
        case .result: "Round complete"
        }
    }
}
