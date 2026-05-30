import SwiftUI

#if canImport(UIKit)
public struct AnalyticsLaunchPanel: View {
    public let configuration: AnalyticsConfiguration
    @AppStorage("settings.language") private var preferredLanguage = "en"
    @State private var isLoading = false
    @State private var statusMessage: String?
    @State private var presentedDestination: AnalyticsPresentedDestination?

    public init(configuration: AnalyticsConfiguration) {
        self.configuration = configuration
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Analytics Check", systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline)
                .foregroundStyle(AnalyticsTheme.accent)

            Text("Sends the launch analytics check and continues with the server-provided destination when available.")
                .font(.subheadline)
                .foregroundStyle(AnalyticsTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                Task { await loadDestination() }
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .tint(AnalyticsTheme.navy)
                    }
                    Text(isLoading ? "Checking..." : "Check and open")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(AnalyticsTheme.accent)
            .foregroundStyle(AnalyticsTheme.navy)
            .disabled(isLoading)

            if let statusMessage {
                Text(statusMessage)
                    .font(.footnote)
                    .foregroundStyle(AnalyticsTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AnalyticsTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .fullScreenCover(item: $presentedDestination) { destination in
            NavigationView {
                AnalyticsBrowserScreen(configuration: destination.configuration)
            }
            .navigationViewStyle(.stack)
        }
        .analyticsKeepsAudioAlive()
    }

    @MainActor
    private func loadDestination() async {
        isLoading = true
        statusMessage = nil
        defer { isLoading = false }

        do {
            let client = AnalyticsRequestClient(configuration: configuration)
            let decision = try await client.loadDecision(preferredLanguage: preferredLanguage)

            guard decision.enabled else {
                statusMessage = "Server returned false. Continuing with the local app."
                return
            }

            guard let url = decision.url else {
                statusMessage = "Server returned true but did not include a URL."
                return
            }

            presentedDestination = AnalyticsPresentedDestination(
                configuration: configuration.resolvedDestination(url)
            )
        } catch {
            statusMessage = error.localizedDescription
        }
    }
}

public struct AnalyticsPresentedDestination: Identifiable {
    public let id = UUID()
    public let configuration: AnalyticsConfiguration

    public init(configuration: AnalyticsConfiguration) {
        self.configuration = configuration
    }
}
#endif
