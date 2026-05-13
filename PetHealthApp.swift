import SwiftUI
import SwiftData

@main
struct PetHealthApp: App {
    init() {
        NotificationManager.shared.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Pet.self, HealthRecord.self])
    }
}
