import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            PetListView()
                .tabItem { Label("Os meus pets", systemImage: "pawprint.fill") }

            AlertsView()
                .tabItem { Label("Alertas", systemImage: "bell.fill") }
        }
    }
}
