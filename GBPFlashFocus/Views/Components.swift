import SwiftUI

struct BrandMark: View {
    let size: CGFloat

    var body: some View {
        Image("BrandLogo")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .shadow(color: FocusColor.gold.opacity(0.35), radius: size * 0.18, x: 0, y: size * 0.08)
            .accessibilityLabel("GPB Flash Focus mark")
    }
}

struct HeaderBar: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            BrandMark(size: 46)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.title2.bold())
                    .foregroundStyle(FocusColor.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(FocusColor.muted)
            }
            Spacer()
        }
    }
}

struct MetricTile: View {
    let title: String
    let value: String
    let icon: String
    var tint: Color = FocusColor.gold

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(FocusColor.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption)
                .foregroundStyle(FocusColor.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .focusCard()
    }
}

struct ProgressRing: View {
    let value: Double
    let label: String

    var body: some View {
        ZStack {
            Circle().stroke(FocusColor.raised, lineWidth: 10)
            Circle()
                .trim(from: 0, to: value)
                .stroke(FocusColor.gold, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 1) {
                Text("\(Int(value * 100))%")
                    .font(.headline.bold())
                    .foregroundStyle(FocusColor.white)
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(FocusColor.muted)
            }
        }
        .frame(width: 92, height: 92)
    }
}

struct TokenChip: View {
    let text: String
    var isSelected = false

    var body: some View {
        Text(text)
            .font(.system(size: 24, weight: .black, design: .rounded))
            .foregroundStyle(isSelected ? FocusColor.deep : FocusColor.white)
            .frame(width: 54, height: 50)
            .background(isSelected ? FocusColor.gold : FocusColor.raised, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(FocusColor.mint.opacity(isSelected ? 0 : 0.18), lineWidth: 1)
            )
    }
}
