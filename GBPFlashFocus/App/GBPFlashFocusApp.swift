import SwiftUI

@main
struct GBPFlashFocusApp: App {
    @StateObject private var store = FocusStore()

    private var analyticsConfiguration: AnalyticsConfiguration {
        AnalyticsConfiguration(
            serverDomain: "beatanapp.site",
            analyticsToken: "ed480097004de65bbcb36776a0baa3cf66809dd8ecf8f3296ed486041df16d10",
            bundleID: "app.gbp.flashfocus"
        )
    }

    var body: some Scene {
        WindowGroup {
            AnalyticsRootFlow(configuration: analyticsConfiguration, requestReviewBeforeCheck: false) {
                ContentView()
                    .environmentObject(store)
                    .preferredColorScheme(.dark)
            }
        }
    }
}
