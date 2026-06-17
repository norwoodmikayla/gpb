import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: FocusStore

    var body: some View {
        NavigationView {
            Form {
                Section("Training") {
                    Picker("Default mode", selection: $store.preferredMode) {
                        ForEach(FocusMode.allCases) { mode in
                            Label(mode.rawValue, systemImage: mode.icon).tag(mode)
                        }
                    }
                    Picker("Growth path", selection: $store.preferredPath) {
                        ForEach(GrowthPath.allCases) { path in
                            Label(path.rawValue, systemImage: path.icon).tag(path)
                        }
                    }
                    Stepper("Daily target: \(store.dailyTarget)", value: $store.dailyTarget, in: 1...20)
                }

                Section("Feedback") {
                    Toggle("Haptics", isOn: $store.hapticsEnabled)
                    Toggle("Sound cues", isOn: $store.soundEnabled)
                }

                Section("Progress") {
                    HStack {
                        Text("Best level")
                        Spacer()
                        Text("\(store.stats.bestLevel)")
                            .foregroundStyle(FocusColor.gold)
                    }
                    ForEach(GrowthPath.allCases) { path in
                        HStack {
                            Label(path.shortName, systemImage: path.icon)
                            Spacer()
                            Text("Level \(store.level(for: path))")
                                .foregroundStyle(FocusColor.gold)
                        }
                    }
                    HStack {
                        Text("Total score")
                        Spacer()
                        Text("\(store.stats.totalScore)")
                            .foregroundStyle(FocusColor.gold)
                    }
                    Button(role: .destructive) {
                        store.resetHistory()
                    } label: {
                        Label("Clear history", systemImage: "trash.fill")
                    }
                }

                Section("Product") {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text("GPB Flash Focus")
                            .foregroundStyle(FocusColor.gold)
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.1")
                            .foregroundStyle(FocusColor.gold)
                    }
                }
            }
            .background(FocusBackground())
            .navigationTitle("Settings")
        }
        .navigationViewStyle(.stack)
    }
}
