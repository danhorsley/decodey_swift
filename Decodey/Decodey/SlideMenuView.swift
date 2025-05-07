import SwiftUI

struct SlideMenuView: View {
    @Binding var isOpen: Bool
    @Binding var showAbout: Bool
    @Binding var showSettings: Bool
    @Binding var showStyleEditor: Bool
    
    @Environment(\.colorScheme) var colorScheme
    
    // Colors based on theme
    var backgroundColor: Color {
        colorScheme == .dark ? Color(white: 0.15) : Color(white: 0.95)
    }
    
    var textColor: Color {
        colorScheme == .dark ? Color.white : Color.black
    }
    
    var body: some View {
        ZStack {
            // Background overlay that closes the menu when tapped
            if isOpen {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.3)) {
                            isOpen = false
                        }
                    }
            }
            
            // The menu itself
            HStack {
                // Menu content
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack {
                        Text("decodey")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.3)) {
                                isOpen = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(textColor.opacity(0.6))
                                .padding(.top)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    
                    // Menu items
                    ScrollView {
                        VStack(spacing: 0) {
                            // Play section
                            menuHeader("Play")
                            
                            menuButton(
                                title: "New Game",
                                icon: "play.fill",
                                action: {
                                    // Start a new game
                                    withAnimation {
                                        isOpen = false
                                    }
                                }
                            )
                            
                            Divider()
                                .padding(.horizontal)
                            
                            // Settings section
                            menuHeader("Settings")
                            
                            menuButton(
                                title: "Game Settings",
                                icon: "gearshape.fill",
                                action: {
                                    showSettings = true
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        isOpen = false
                                    }
                                }
                            )
                            
                            Divider()
                                .padding(.horizontal)
                            
                            // Info section
                            menuHeader("Info")
                            
                            menuButton(
                                title: "Statistics",
                                icon: "chart.bar.fill",
                                action: {
                                    // Open statistics
                                    withAnimation {
                                        isOpen = false
                                    }
                                }
                            )
                            
                            menuButton(
                                title: "About",
                                icon: "info.circle.fill",
                                action: {
                                    showAbout = true
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        isOpen = false
                                    }
                                }
                            )
                            
                            #if DEBUG
                            // Debug section - only shown in debug builds
                            Divider()
                                .padding(.horizontal)
                            
                            menuHeader("Developer")
                            
                            menuButton(
                                title: "Quote Manager",
                                icon: "doc.text.fill",
                                action: {
                                    // Open quote manager
                                    withAnimation {
                                        isOpen = false
                                    }
                                }
                            )
                            #endif
                        }
                    }
                    
                    Spacer()
                    
                    // Footer
                    Text("Version 1.0")
                        .font(.caption)
                        .foregroundColor(textColor.opacity(0.5))
                        .padding()
                    
                }
                .frame(width: 270)
                .background(backgroundColor)
                .offset(x: isOpen ? 0 : -270)
                .animation(.easeInOut(duration: 0.3), value: isOpen)
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
    
    // Helper for section headers
    private func menuHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(textColor.opacity(0.6))
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 8)
    }
    
    // Helper for menu buttons
    private func menuButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .opacity(0.5)
            }
            .padding()
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .foregroundColor(textColor)
    }
}

struct SlideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SlideMenuView(
            isOpen: .constant(true),
            showAbout: .constant(false),
            showSettings: .constant(false),
            showStyleEditor: .constant(false)
        )
        .preferredColorScheme(.dark)
    }
}
