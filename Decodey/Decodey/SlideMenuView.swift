import SwiftUI

struct SlideMenuView: View {
    @Binding var isOpen: Bool
    @Binding var showAbout: Bool
    @Binding var showSettings: Bool
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
                    VStack(spacing: 0) {
                        // Settings button
                        Button(action: {
                            showSettings = true
                            withAnimation(.easeOut(duration: 0.3)) {
                                isOpen = false
                            }
                        }) {
                            HStack {
                                Image(systemName: "gearshape.fill")
                                    .frame(width: 24, height: 24)
                                
                                Text("Settings")
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
                        
                        Divider()
                            .padding(.horizontal)
                        
                        // About button
                        Button(action: {
                            showAbout = true
                            withAnimation(.easeOut(duration: 0.3)) {
                                isOpen = false
                            }
                        }) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .frame(width: 24, height: 24)
                                
                                Text("About")
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
}

struct SlideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SlideMenuView(
            isOpen: .constant(true),
            showAbout: .constant(false),
            showSettings: .constant(false)
        )
        .preferredColorScheme(.dark)
    }
}//
//  SlideMenuView.swift
//  Decodey
//
//  Created by Daniel Horsley on 06/05/2025.
//

