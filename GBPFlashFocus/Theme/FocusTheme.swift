import SwiftUI

enum FocusColor {
    static let deep = Color(red: 0.015, green: 0.210, blue: 0.135)
    static let forest = Color(red: 0.030, green: 0.390, blue: 0.225)
    static let leaf = Color(red: 0.235, green: 0.640, blue: 0.330)
    static let mint = Color(red: 0.710, green: 0.885, blue: 0.455)
    static let gold = Color(red: 0.965, green: 0.830, blue: 0.240)
    static let panel = Color(red: 0.045, green: 0.190, blue: 0.130)
    static let raised = Color(red: 0.070, green: 0.260, blue: 0.175)
    static let white = Color(red: 0.965, green: 0.985, blue: 0.955)
    static let muted = Color(red: 0.720, green: 0.815, blue: 0.710)
    static let danger = Color(red: 0.980, green: 0.330, blue: 0.260)
}

struct FocusBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [FocusColor.mint.opacity(0.75), FocusColor.leaf, FocusColor.forest, FocusColor.deep],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 26) {
                ForEach(0..<7, id: \.self) { index in
                    Capsule()
                        .stroke(FocusColor.mint.opacity(0.10), lineWidth: 1)
                        .frame(height: 34 + CGFloat(index * 8))
                        .rotationEffect(.degrees(-7))
                        .offset(x: CGFloat(index * -8), y: CGFloat(index * -14))
                }
            }
            .offset(y: -260)
            .ignoresSafeArea()

            LinearGradient(colors: [.clear, FocusColor.deep.opacity(0.55)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        }
    }
}

struct FocusCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(FocusColor.panel.opacity(0.88))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(FocusColor.mint.opacity(0.20), lineWidth: 1)
                    )
            )
    }
}

extension View {
    func focusCard() -> some View {
        modifier(FocusCardModifier())
    }
}
