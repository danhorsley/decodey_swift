import SwiftUI

struct StatisticsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var stats: [String: Any]?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    // User ID - in a real app, this would come from authentication
    private let userId = "local_user"
    
    // Colors
    @Environment(\.colorScheme) var colorScheme
    var primaryColor: Color {
        colorScheme == .dark ?
            Color(red: 76/255, green: 201/255, blue: 240/255) :
            Color(red: 0/255, green: 66/255, blue: 170/255)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if isLoading {
                        ProgressView("Loading statistics...")
                            .padding(.top, 50)
                    } else if let error = errorMessage {
                        errorView(message: error)
                    } else if let stats = stats {
                        // Header
                        HStack {
                            VStack(alignment: .leading) {
                                Text("DECODEY")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text("Player Statistics")
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Top stats
                        overviewStatsView(stats: stats)
                        
                        // Win/Loss chart
                        winLossChartView(stats: stats)
                        
                        // Detailed stats
                        detailedStatsView(stats: stats)
                    } else {
                        noStatsView()
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("Statistics")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadStatistics()
            }
        }
    }
    
    // Overview of key stats
    private func overviewStatsView(stats: [String: Any]) -> some View {
        HStack(spacing: 0) {
            // Games played
            statCard(
                title: "Games",
                value: "\(stats["games_played"] as? Int ?? 0)",
                icon: "gamecontroller.fill"
            )
            
            // Win percentage
            statCard(
                title: "Win Rate",
                value: "\(Int(stats["win_percentage"] as? Double ?? 0))%",
                icon: "percent"
            )
            
            // Current streak
            statCard(
                title: "Streak",
                value: "\(stats["current_streak"] as? Int ?? 0)",
                icon: "flame.fill",
                highlightColor: .orange
            )
        }
        .padding(.horizontal)
    }
    
    // Single stat card
    private func statCard(title: String, value: String, icon: String, highlightColor: Color? = nil) -> some View {
        let color = highlightColor ?? primaryColor
        
        return VStack {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption)
            }
            
            HStack {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(colorScheme == .dark ? Color(white: 0.15) : Color(white: 0.95))
        .cornerRadius(12)
    }
    
    // Win/Loss chart
    private func winLossChartView(stats: [String: Any]) -> some View {
        let gamesPlayed = stats["games_played"] as? Int ?? 0
        let gamesWon = stats["games_won"] as? Int ?? 0
        let gamesLost = gamesPlayed - gamesWon
        
        // Don't show if no games played
        guard gamesPlayed > 0 else { return EmptyView().eraseToAnyView() }
        
        let winPercentage = Double(gamesWon) / Double(gamesPlayed)
        
        // Get screen width using GeometryReader instead of UIScreen
        return GeometryReader { geometry in
            VStack(alignment: .leading) {
                Text("Win / Loss Record")
                    .font(.headline)
                    .padding(.horizontal)
                
                HStack(spacing: 0) {
                    // Win portion
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.green)
                        .frame(width: max(CGFloat(winPercentage) * (geometry.size.width - 40), 0))
                        .frame(height: 30)
                    
                    // Loss portion
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.red)
                        .frame(width: max(CGFloat(1 - winPercentage) * (geometry.size.width - 40), 0))
                        .frame(height: 30)
                }
                .padding(.horizontal)
                
                HStack {
                    Text("Won: \(gamesWon)")
                        .font(.caption)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(4)
                    
                    Text("Lost: \(gamesLost)")
                        .font(.caption)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(4)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .frame(height: 100) // Fixed height for GeometryReader
        .eraseToAnyView()
    }
    
    // Detailed stats grid
    private func detailedStatsView(stats: [String: Any]) -> some View {
        VStack(alignment: .leading) {
            Text("Detailed Statistics")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                // Best streak
                detailRow(
                    title: "Best Streak",
                    value: "\(stats["best_streak"] as? Int ?? 0)",
                    icon: "trophy.fill",
                    color: .yellow
                )
                
                // Total score
                detailRow(
                    title: "Total Score",
                    value: "\(stats["total_score"] as? Int ?? 0)",
                    icon: "sum",
                    color: primaryColor
                )
                
                // Average mistakes
                detailRow(
                    title: "Avg. Mistakes",
                    value: String(format: "%.1f", stats["average_mistakes"] as? Double ?? 0),
                    icon: "xmark.circle",
                    color: .red
                )
                
                // Average time
                detailRow(
                    title: "Avg. Time",
                    value: formatTime(stats["average_time"] as? Double ?? 0),
                    icon: "clock.fill",
                    color: .blue
                )
                
                // Average score
                detailRow(
                    title: "Avg. Score",
                    value: "\(stats["average_score"] as? Int ?? 0)",
                    icon: "star.fill",
                    color: .orange
                )
                
                // Last played
                if let lastPlayed = stats["last_played_date"] as? Date {
                    detailRow(
                        title: "Last Played",
                        value: formatDate(lastPlayed),
                        icon: "calendar",
                        color: .gray
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    // Detail row for statistics grid
    private func detailRow(title: String, value: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.headline)
            }
            
            Spacer()
        }
        .padding()
        .background(colorScheme == .dark ? Color(white: 0.15) : Color(white: 0.95))
        .cornerRadius(8)
    }
    
    // Error view
    private func errorView(message: String) -> some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
                .padding()
            
            Text("Error Loading Statistics")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Try Again") {
                loadStatistics()
            }
            .padding()
            .background(primaryColor)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
    
    // No stats view
    private func noStatsView() -> some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .padding()
            
            Text("No Statistics Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Complete your first game to start tracking statistics.")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding()
        }
        .padding(40)
    }
    
    // Load statistics from database
    private func loadStatistics() {
        isLoading = true
        errorMessage = nil
        
        // Use a background thread for database operations
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let loadedStats = try DatabaseManager.shared.getStatistics(userId: userId)
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    stats = loadedStats
                    isLoading = false
                }
            } catch {
                // Handle error on main thread
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
    
    // Format time in seconds to MM:SS
    private func formatTime(_ seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // Format date to readable string
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        
        return formatter.string(from: date)
    }
}

// Helper to erase type for conditionals
extension View {
    func eraseToAnyView() -> AnyView {
        return AnyView(self)
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
    }
}
