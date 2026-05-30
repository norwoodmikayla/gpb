import Foundation
import SwiftUI

enum FocusMode: String, CaseIterable, Identifiable, Codable {
    case digits = "Digits"
    case shapes = "Shapes"
    case mixed = "Mixed"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .digits: "number"
        case .shapes: "seal.fill"
        case .mixed: "sparkles"
        }
    }

    var pool: [String] {
        switch self {
        case .digits: ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
        case .shapes: ["▲", "●", "■", "◆", "★", "✚"]
        case .mixed: ["1", "2", "3", "4", "5", "6", "▲", "●", "■", "◆", "★", "✚"]
        }
    }
}

enum FocusPace: String, CaseIterable, Identifiable, Codable {
    case calm = "Calm"
    case sharp = "Sharp"
    case flash = "Flash"

    var id: String { rawValue }

    var exposure: Double {
        switch self {
        case .calm: 0.92
        case .sharp: 0.68
        case .flash: 0.48
        }
    }

    var bonus: Int {
        switch self {
        case .calm: 0
        case .sharp: 12
        case .flash: 24
        }
    }
}

enum GrowthPath: String, CaseIterable, Identifiable, Codable {
    case memory = "Memory Ladder"
    case speed = "Speed Ladder"
    case balanced = "Balanced Climb"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .memory: "square.stack.3d.up.fill"
        case .speed: "speedometer"
        case .balanced: "point.3.connected.trianglepath.dotted"
        }
    }

    var shortName: String {
        switch self {
        case .memory: "Memory"
        case .speed: "Speed"
        case .balanced: "Balanced"
        }
    }

    func plan(for level: Int) -> RoundPlan {
        let safeLevel = max(1, min(30, level))
        switch self {
        case .memory:
            return RoundPlan(
                level: safeLevel,
                length: memoryLength(for: safeLevel),
                exposure: memoryExposure(for: safeLevel),
                gap: safeLevel <= 3 ? 0.48 : 0.34,
                masteryGoal: 2,
                focus: "More items, gentle speed"
            )
        case .speed:
            return RoundPlan(
                level: safeLevel,
                length: speedLength(for: safeLevel),
                exposure: speedExposure(for: safeLevel),
                gap: max(0.18, 0.42 - Double(max(0, safeLevel - 3)) * 0.006),
                masteryGoal: 2,
                focus: "Same load, faster flashes"
            )
        case .balanced:
            return RoundPlan(
                level: safeLevel,
                length: balancedLength(for: safeLevel),
                exposure: balancedExposure(for: safeLevel),
                gap: max(0.18, 0.44 - Double(max(0, safeLevel - 3)) * 0.005),
                masteryGoal: 2,
                focus: "More items and more pace"
            )
        }
    }

    private func memoryLength(for level: Int) -> Int {
        if level == 1 { return 3 }
        if level <= 4 { return 4 }
        return min(12, level)
    }

    private func speedLength(for level: Int) -> Int {
        if level == 1 { return 3 }
        if level <= 5 { return 4 }
        return min(8, 4 + Int(ceil(Double(level - 5) / 2.0)))
    }

    private func balancedLength(for level: Int) -> Int {
        if level == 1 { return 3 }
        if level <= 4 { return 4 }
        return min(10, level)
    }

    private func memoryExposure(for level: Int) -> Double {
        if level == 1 { return 2.35 }
        if level <= 4 { return 2.15 }
        if level <= 10 { return 1.95 }
        return max(0.92, 1.85 - Double(level - 10) * 0.035)
    }

    private func speedExposure(for level: Int) -> Double {
        if level == 1 { return 2.20 }
        if level <= 4 { return 1.95 }
        if level <= 10 { return 1.72 }
        return max(0.48, 1.62 - Double(level - 10) * 0.045)
    }

    private func balancedExposure(for level: Int) -> Double {
        if level == 1 { return 2.28 }
        if level <= 4 { return 2.05 }
        if level <= 10 { return 1.84 }
        return max(0.56, 1.72 - Double(level - 10) * 0.036)
    }
}

struct RoundPlan: Hashable {
    let level: Int
    let length: Int
    let exposure: Double
    let gap: Double
    let masteryGoal: Int
    let focus: String

    var exposureLabel: String {
        String(format: "%.2fs", exposure)
    }
}

struct FocusSession: Identifiable, Codable, Hashable {
    var id = UUID()
    var date: Date
    var mode: FocusMode
    var pace: FocusPace
    var path: GrowthPath
    var level: Int
    var sequence: [String]
    var answer: [String]
    var isCorrect: Bool
    var score: Int
    var responseTime: Double

    var accuracyLabel: String { isCorrect ? "Perfect" : "\(matchedCount)/\(sequence.count)" }

    var matchedCount: Int {
        zip(sequence, answer).filter { $0 == $1 }.count
    }

    init(
        id: UUID = UUID(),
        date: Date,
        mode: FocusMode,
        pace: FocusPace,
        path: GrowthPath = .balanced,
        level: Int,
        sequence: [String],
        answer: [String],
        isCorrect: Bool,
        score: Int,
        responseTime: Double
    ) {
        self.id = id
        self.date = date
        self.mode = mode
        self.pace = pace
        self.path = path
        self.level = level
        self.sequence = sequence
        self.answer = answer
        self.isCorrect = isCorrect
        self.score = score
        self.responseTime = responseTime
    }

    enum CodingKeys: String, CodingKey {
        case id, date, mode, pace, path, level, sequence, answer, isCorrect, score, responseTime
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.date = try container.decode(Date.self, forKey: .date)
        self.mode = try container.decode(FocusMode.self, forKey: .mode)
        self.pace = try container.decode(FocusPace.self, forKey: .pace)
        self.path = try container.decodeIfPresent(GrowthPath.self, forKey: .path) ?? .balanced
        self.level = try container.decode(Int.self, forKey: .level)
        self.sequence = try container.decode([String].self, forKey: .sequence)
        self.answer = try container.decode([String].self, forKey: .answer)
        self.isCorrect = try container.decode(Bool.self, forKey: .isCorrect)
        self.score = try container.decode(Int.self, forKey: .score)
        self.responseTime = try container.decode(Double.self, forKey: .responseTime)
    }
}

struct FocusStats {
    let sessions: [FocusSession]
    let dailyTarget: Int

    var attempts: Int { sessions.count }
    var wins: Int { sessions.filter(\.isCorrect).count }
    var bestLevel: Int { sessions.map(\.level).max() ?? 1 }
    func bestLevel(for path: GrowthPath) -> Int {
        sessions.filter { $0.path == path }.map(\.level).max() ?? 1
    }
    var totalScore: Int { sessions.reduce(0) { $0 + $1.score } }
    var averageResponse: Double {
        guard !sessions.isEmpty else { return 0 }
        return sessions.reduce(0) { $0 + $1.responseTime } / Double(sessions.count)
    }
    var accuracy: Double {
        guard !sessions.isEmpty else { return 0 }
        return Double(wins) / Double(sessions.count)
    }
    var todayCount: Int {
        sessions.filter { Calendar.current.isDateInToday($0.date) }.count
    }
    var targetProgress: Double {
        guard dailyTarget > 0 else { return 0 }
        return min(1, Double(todayCount) / Double(dailyTarget))
    }

    var currentStreak: Int {
        var streak = 0
        for session in sessions {
            guard session.isCorrect else { break }
            streak += 1
        }
        return streak
    }

    var achievements: [Achievement] {
        Achievement.catalog.map { item in
            var unlocked = false
            switch item.kind {
            case .firstPerfect:
                unlocked = wins >= 1
            case .dailyFive:
                unlocked = todayCount >= 5
            case .memoryLevel:
                unlocked = bestLevel(for: .memory) >= 5
            case .speedLevel:
                unlocked = bestLevel(for: .speed) >= 5
            case .balancedLevel:
                unlocked = bestLevel(for: .balanced) >= 5
            case .streak:
                unlocked = currentStreak >= 3
            }
            return item.withUnlocked(unlocked)
        }
    }
}

struct Achievement: Identifiable, Hashable {
    enum Kind {
        case firstPerfect
        case dailyFive
        case memoryLevel
        case speedLevel
        case balancedLevel
        case streak
    }

    let id: Kind
    let title: String
    let detail: String
    let icon: String
    let isUnlocked: Bool

    var kind: Kind { id }

    func withUnlocked(_ unlocked: Bool) -> Achievement {
        Achievement(id: id, title: title, detail: detail, icon: icon, isUnlocked: unlocked)
    }

    static let catalog: [Achievement] = [
        Achievement(id: .firstPerfect, title: "First Spark", detail: "Complete one perfect recall.", icon: "sparkle", isUnlocked: false),
        Achievement(id: .dailyFive, title: "Daily Focus", detail: "Finish five rounds today.", icon: "calendar.badge.checkmark", isUnlocked: false),
        Achievement(id: .memoryLevel, title: "Memory Builder", detail: "Reach Memory level 5.", icon: "square.stack.3d.up.fill", isUnlocked: false),
        Achievement(id: .speedLevel, title: "Fast Eyes", detail: "Reach Speed level 5.", icon: "speedometer", isUnlocked: false),
        Achievement(id: .balancedLevel, title: "Steady Climb", detail: "Reach Balanced level 5.", icon: "point.3.connected.trianglepath.dotted", isUnlocked: false),
        Achievement(id: .streak, title: "Triple Clean", detail: "Recall three rounds in a row.", icon: "flame.fill", isUnlocked: false)
    ]
}

extension Date {
    var focusShortDate: String {
        formatted(.dateTime.month(.abbreviated).day().hour().minute())
    }
}
