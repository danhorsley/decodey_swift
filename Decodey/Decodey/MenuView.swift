import SwiftUI

struct MenuView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var showAbout: Bool
    let onNewGame: () -> Void
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: {
                        dismiss()
                        onNewGame()
                    }) {
                        Label("New Game", systemImage: "play.fill")
                    }
                    
                    NavigationLink(destination: StatisticsView()) {
                        Label("Statistics", systemImage: "chart.bar.fill")
                    }
                    
                    NavigationLink(destination: QuoteManagerView()) {
                        Label("Quote Manager", systemImage: "doc.text")
                    }
                } header: {
                    Text("Game")
                }
                
                Section {
                    Button(action: {
                        dismiss()
                        showAbout = true
                    }) {
                        Label("About", systemImage: "info.circle")
                    }
                } header: {
                    Text("Info")
                }
            }
            #if os(iOS)
            .listStyle(InsetGroupedListStyle())
            #else
            .listStyle(SidebarListStyle())
            #endif
            .navigationTitle("Menu")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
