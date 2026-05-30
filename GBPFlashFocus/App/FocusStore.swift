import Foundation

@MainActor
final class FocusStore: ObservableObject {
    @Published var sessions: [FocusSession] { didSet { saveSessions() } }
    @Published var hasCompletedOnboarding: Bool { didSet { defaults.set(hasCompletedOnboarding, forKey: Keys.onboarding) } }
    @Published var preferredMode: FocusMode { didSet { defaults.set(preferredMode.rawValue, forKey: Keys.mode) } }
    @Published var preferredPace: FocusPace { didSet { defaults.set(preferredPace.rawValue, forKey: Keys.pace) } }
    @Published var preferredPath: GrowthPath { didSet { defaults.set(preferredPath.rawValue, forKey: Keys.path) } }
    @Published var dailyTarget: Int { didSet { defaults.set(dailyTarget, forKey: Keys.target) } }
    @Published var soundEnabled: Bool { didSet { defaults.set(soundEnabled, forKey: Keys.sound) } }
    @Published var hapticsEnabled: Bool { didSet { defaults.set(hapticsEnabled, forKey: Keys.haptics) } }
    @Published private var pathLevels: [String: Int] { didSet { defaults.set(pathLevels, forKey: Keys.pathLevels) } }

    private let defaults = UserDefaults.standard

    init() {
        let loadedSessions = Self.loadSessions()
        self.sessions = loadedSessions.isEmpty ? SampleData.sessions : loadedSessions
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: Keys.onboarding)
        self.preferredMode = FocusMode(rawValue: UserDefaults.standard.string(forKey: Keys.mode) ?? "") ?? .digits
        self.preferredPace = FocusPace(rawValue: UserDefaults.standard.string(forKey: Keys.pace) ?? "") ?? .calm
        self.preferredPath = GrowthPath(rawValue: UserDefaults.standard.string(forKey: Keys.path) ?? "") ?? .memory
        let storedTarget = UserDefaults.standard.integer(forKey: Keys.target)
        self.dailyTarget = storedTarget == 0 ? 5 : storedTarget
        self.soundEnabled = UserDefaults.standard.object(forKey: Keys.sound) as? Bool ?? true
        self.hapticsEnabled = UserDefaults.standard.object(forKey: Keys.haptics) as? Bool ?? true
        self.pathLevels = UserDefaults.standard.dictionary(forKey: Keys.pathLevels) as? [String: Int] ?? [:]
    }

    var stats: FocusStats {
        FocusStats(sessions: sessions, dailyTarget: dailyTarget)
    }

    var suggestedLevel: Int {
        level(for: preferredPath)
    }

    func level(for path: GrowthPath) -> Int {
        max(1, pathLevels[path.rawValue] ?? 1)
    }

    func plan(for path: GrowthPath) -> RoundPlan {
        path.plan(for: level(for: path))
    }

    func makeSequence(plan: RoundPlan, mode: FocusMode) -> [String] {
        let length = plan.length
        return (0..<length).map { _ in mode.pool.randomElement() ?? "1" }
    }

    func record(mode: FocusMode, path: GrowthPath, plan: RoundPlan, sequence: [String], answer: [String], startedAt: Date) {
        let correct = sequence == answer
        let matched = zip(sequence, answer).filter { $0 == $1 }.count
        let response = Date().timeIntervalSince(startedAt)
        let base = correct ? plan.level * 90 : matched * 22
        let speed = max(0, 70 - Int(response * 3))
        let score = max(10, base + speed + plan.length * 8)
        sessions.insert(
            FocusSession(
                date: .now,
                mode: mode,
                pace: .calm,
                path: path,
                level: plan.level,
                sequence: sequence,
                answer: answer,
                isCorrect: correct,
                score: score,
                responseTime: response
            ),
            at: 0
        )
        sessions = Array(sessions.prefix(80))
        updateLevel(for: path, wasCorrect: correct)
    }

    func resetHistory() {
        sessions.removeAll()
        pathLevels.removeAll()
    }

    private func updateLevel(for path: GrowthPath, wasCorrect: Bool) {
        guard wasCorrect else { return }
        let needed = path.plan(for: level(for: path)).masteryGoal
        let recentPathSessions = sessions.filter { $0.path == path }.prefix(needed)
        guard recentPathSessions.count == needed,
              recentPathSessions.allSatisfy(\.isCorrect) else { return }
        pathLevels[path.rawValue] = min(30, level(for: path) + 1)
    }

    private func saveSessions() {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        defaults.set(data, forKey: Keys.sessions)
    }

    private static func loadSessions() -> [FocusSession] {
        guard let data = UserDefaults.standard.data(forKey: Keys.sessions),
              let sessions = try? JSONDecoder().decode([FocusSession].self, from: data) else {
            return []
        }
        return sessions
    }
}

private enum Keys {
    static let sessions = "gbp.flash.focus.sessions"
    static let onboarding = "gbp.flash.focus.onboarding"
    static let mode = "gbp.flash.focus.mode"
    static let pace = "gbp.flash.focus.pace"
    static let path = "gbp.flash.focus.path"
    static let pathLevels = "gbp.flash.focus.path.levels"
    static let target = "gbp.flash.focus.target"
    static let sound = "gbp.flash.focus.sound"
    static let haptics = "gbp.flash.focus.haptics"
}
