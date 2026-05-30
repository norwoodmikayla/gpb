import SwiftUI

#if canImport(UIKit)
import UIKit

private struct AnalyticsAudioActivationModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                AnalyticsBrowserRuntime.activateGameAudio()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                AnalyticsBrowserRuntime.activateGameAudio()
            }
    }
}

extension View {
    func analyticsKeepsAudioAlive() -> some View {
        modifier(AnalyticsAudioActivationModifier())
    }
}
#endif
