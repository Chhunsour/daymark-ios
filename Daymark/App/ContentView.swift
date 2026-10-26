import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "sun.horizon.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Daymark")
                .font(.headline)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
