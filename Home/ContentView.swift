import SwiftUI

struct ContentView: View {
    @State private var dataStore = DataStore()

    var body: some View {
        MainTabView()
            .environment(dataStore)
    }
}

#Preview {
    ContentView()
}
