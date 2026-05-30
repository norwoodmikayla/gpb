import Foundation

enum SampleData {
    static let sessions: [FocusSession] = [
        FocusSession(date: Date(timeIntervalSinceNow: -3600), mode: .digits, pace: .calm, path: .memory, level: 2, sequence: ["4", "8", "1"], answer: ["4", "8", "1"], isCorrect: true, score: 232, responseTime: 4.4),
        FocusSession(date: Date(timeIntervalSinceNow: -7400), mode: .mixed, pace: .calm, path: .balanced, level: 1, sequence: ["2", "★", "6"], answer: ["2", "★", "1"], isCorrect: false, score: 118, responseTime: 5.2),
        FocusSession(date: Date(timeIntervalSinceNow: -86400), mode: .shapes, pace: .calm, path: .speed, level: 2, sequence: ["▲", "■", "★"], answer: ["▲", "■", "★"], isCorrect: true, score: 224, responseTime: 3.7)
    ]
}
