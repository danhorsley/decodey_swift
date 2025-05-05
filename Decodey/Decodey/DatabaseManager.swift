import Foundation
import GRDB

/// Database manager for the Decodey app
class DatabaseManager {
    // Shared instance
    static let shared = DatabaseManager()
    
    // GRDB database queue
    private var dbQueue: DatabaseQueue!
    
    // Private initializer for singleton
    private init() {
        do {
            // Get the document directory
            let fileManager = FileManager.default
            let folderURL = try fileManager.url(for: .documentDirectory,
                                               in: .userDomainMask,
                                               appropriateFor: nil,
                                               create: true)
            
            // Database path
            let dbPath = folderURL.appendingPathComponent("decodey.sqlite").path
            
            // Create the database
            dbQueue = try DatabaseQueue(path: dbPath)
            
            // Create tables
            try setupDatabase()
            
            print("Database initialized at: \(dbPath)")
        } catch {
            print("Database initialization error: \(error)")
        }
    }
    
    // Set up the database schema
    private func setupDatabase() throws {
        try migrator.migrate(dbQueue)
    }
    
    // Database migrations
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        // Initial migration - create tables
        migrator.registerMigration("createTables") { db in
            // Quotes table
            try db.create(table: "quotes") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("text", .text).notNull()
                t.column("author", .text)
                t.column("attribution", .text)
                t.column("difficulty", .text).notNull()
                t.column("is_daily", .boolean).notNull().defaults(to: false)
                t.column("daily_date", .date)
                t.column("is_active", .boolean).notNull().defaults(to: true)
                t.column("times_used", .integer).notNull().defaults(to: 0)
            }
            
            // Games table
            try db.create(table: "games") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("game_id", .text).notNull().unique()
                t.column("user_id", .text)
                t.column("quote_id", .integer).references("quotes")
                t.column("original_text", .text).notNull()
                t.column("encrypted_text", .text).notNull()
                t.column("current_display", .text).notNull()
                t.column("solution", .text).notNull()
                t.column("mapping", .blob).notNull()  // Serialized dictionary
                t.column("reverse_mapping", .blob).notNull()  // Serialized dictionary
                t.column("correctly_guessed", .blob)  // Serialized array
                t.column("mistakes", .integer).notNull().defaults(to: 0)
                t.column("max_mistakes", .integer).notNull().defaults(to: 5)
                t.column("difficulty", .text).notNull()
                t.column("has_won", .boolean).notNull().defaults(to: false)
                t.column("has_lost", .boolean).notNull().defaults(to: false)
                t.column("is_complete", .boolean).notNull().defaults(to: false)
                t.column("score", .integer).defaults(to: 0)
                t.column("time_taken", .integer)  // In seconds
                t.column("created_at", .datetime).notNull()
                t.column("last_updated", .datetime).notNull()
            }
            
            // Statistics table
            try db.create(table: "statistics") { t in
                t.column("user_id", .text).notNull().primaryKey()
                t.column("games_played", .integer).notNull().defaults(to: 0)
                t.column("games_won", .integer).notNull().defaults(to: 0)
                t.column("current_streak", .integer).notNull().defaults(to: 0)
                t.column("best_streak", .integer).notNull().defaults(to: 0)
                t.column("total_score", .integer).notNull().defaults(to: 0)
                t.column("average_mistakes", .double).notNull().defaults(to: 0)
                t.column("average_time", .double).notNull().defaults(to: 0)
                t.column("last_played_date", .date)
            }
        }
        
        // Add seed data migration
        migrator.registerMigration("seedData") { db in
            try self.insertInitialQuotes(db: db)
        }
        
        return migrator
    }
    
    // Insert initial quotes when the database is first created
    private func insertInitialQuotes(db: Database) throws {
        // Sample quotes with different difficulties
        let quotes = [
            // Easy quotes (shorter, common words)
            ["text": "Manners maketh man.", "author": "William Horman", "difficulty": "easy"],
            ["text": "The early bird catches the worm.", "author": "John Ray", "difficulty": "easy"],
            ["text": "Actions speak louder than words.", "author": "Abraham Lincoln", "difficulty": "easy"],
            ["text": "Knowledge is power.", "author": "Francis Bacon", "difficulty": "easy"],
            ["text": "Time waits for no one.", "author": "Geoffrey Chaucer", "difficulty": "easy"],
            
            // Medium quotes (moderate length, some less common words)
            ["text": "Be yourself; everyone else is already taken.", "author": "Oscar Wilde", "difficulty": "medium"],
            ["text": "The only thing we have to fear is fear itself.", "author": "Franklin D. Roosevelt", "difficulty": "medium"],
            ["text": "Life is what happens when you're busy making other plans.", "author": "John Lennon", "difficulty": "medium"],
            ["text": "The journey of a thousand miles begins with a single step.", "author": "Lao Tzu", "difficulty": "medium"],
            ["text": "The unexamined life is not worth living.", "author": "Socrates", "difficulty": "medium"],
            
            // Hard quotes (longer, more complex words or structure)
            ["text": "The measure of intelligence is the ability to change.", "author": "Albert Einstein", "difficulty": "hard"],
            ["text": "It is during our darkest moments that we must focus to see the light.", "author": "Aristotle", "difficulty": "hard"],
            ["text": "Imagination is more important than knowledge.", "author": "Albert Einstein", "difficulty": "hard"],
            ["text": "The future belongs to those who believe in the beauty of their dreams.", "author": "Eleanor Roosevelt", "difficulty": "hard"],
            ["text": "Be the change that you wish to see in the world.", "author": "Mahatma Gandhi", "difficulty": "hard"]
        ]
        
        // Insert each quote
        for quote in quotes {
            try db.execute(
                sql: "INSERT INTO quotes (text, author, difficulty, is_active) VALUES (?, ?, ?, ?)",
                arguments: [quote["text"], quote["author"], quote["difficulty"], true]
            )
        }
    }
}

// MARK: - Game Methods
extension DatabaseManager {
    /// Save a game to the database
    func saveGame(_ game: Game) throws {
        try dbQueue.write { db in
            // Serialize the dictionaries and arrays
            let mappingData = try JSONEncoder().encode(game.mapping)
            let reverseMappingData = try JSONEncoder().encode(game.correctMappings)
            let correctlyGuessedData = try JSONEncoder().encode(game.correctlyGuessed())
            
            // Prepare the game record
            let record: [String: DatabaseValueConvertible?] = [
                "game_id": UUID().uuidString,
                "original_text": game.solution,
                "encrypted_text": game.encrypted,
                "current_display": game.currentDisplay,
                "solution": game.solution,
                "mapping": mappingData,
                "reverse_mapping": reverseMappingData,
                "correctly_guessed": correctlyGuessedData,
                "mistakes": game.mistakes,
                "max_mistakes": game.maxMistakes,
                "difficulty": "medium", // Default to medium, can be parameterized
                "has_won": game.hasWon,
                "has_lost": game.hasLost,
                "is_complete": game.hasWon || game.hasLost,
                "created_at": Date(),
                "last_updated": Date()
            ]
            
            // Insert the record
            try db.execute(
                sql: """
                    INSERT INTO games (
                        game_id, original_text, encrypted_text, current_display, solution,
                        mapping, reverse_mapping, correctly_guessed, mistakes, max_mistakes,
                        difficulty, has_won, has_lost, is_complete, created_at, last_updated
                    ) VALUES (
                        :game_id, :original_text, :encrypted_text, :current_display, :solution,
                        :mapping, :reverse_mapping, :correctly_guessed, :mistakes, :max_mistakes,
                        :difficulty, :has_won, :has_lost, :is_complete, :created_at, :last_updated
                    )
                """,
                arguments: record
            )
        }
    }
    
    /// Update an existing game in the database
    func updateGame(_ game: Game, gameId: String) throws {
        try dbQueue.write { db in
            // Serialize the dictionaries and arrays
            let mappingData = try JSONEncoder().encode(game.mapping)
            let reverseMappingData = try JSONEncoder().encode(game.correctMappings)
            let correctlyGuessedData = try JSONEncoder().encode(game.correctlyGuessed())
            
            // Prepare the game record
            let record: [String: DatabaseValueConvertible?] = [
                "current_display": game.currentDisplay,
                "mapping": mappingData,
                "reverse_mapping": reverseMappingData,
                "correctly_guessed": correctlyGuessedData,
                "mistakes": game.mistakes,
                "has_won": game.hasWon,
                "has_lost": game.hasLost,
                "is_complete": game.hasWon || game.hasLost,
                "last_updated": Date()
            ]
            
            // Update the record
            try db.execute(
                sql: """
                    UPDATE games SET
                        current_display = :current_display,
                        mapping = :mapping,
                        reverse_mapping = :reverse_mapping,
                        correctly_guessed = :correctly_guessed,
                        mistakes = :mistakes,
                        has_won = :has_won,
                        has_lost = :has_lost,
                        is_complete = :is_complete,
                        last_updated = :last_updated
                    WHERE game_id = ?
                """,
                arguments: StatementArguments(record).appending(gameId)
            )
        }
    }
    
    /// Load the most recent unfinished game, if any
    func loadLatestGame() throws -> Game? {
        try dbQueue.read { db in
            // Query for the most recent unfinished game
            let row = try Row.fetchOne(db, sql: """
                SELECT * FROM games 
                WHERE is_complete = 0
                ORDER BY created_at DESC
                LIMIT 1
            """)
            
            // Return nil if no game found
            guard let row = row else { return nil }
            
            // Get the mappings from the binary data
            let mappingData = row["mapping"] as! Data
            let reverseMappingData = row["reverse_mapping"] as! Data
            let correctlyGuessedData = row["correctly_guessed"] as! Data
            
            // Decode the mappings
            let mapping = try JSONDecoder().decode([Character: Character].self, from: mappingData)
            let reverseMapping = try JSONDecoder().decode([Character: Character].self, from: reverseMappingData)
            let correctlyGuessed = try JSONDecoder().decode([Character].self, from: correctlyGuessedData)
            
            // Create a new game with the loaded data
            // Note: This is a simplified approach - you'd need to modify your Game struct
            // to support initialization from database data
            var game = Game()
            
            // Update the game with loaded data
            game.solution = row["solution"] as! String
            game.encrypted = row["encrypted_text"] as! String
            game.currentDisplay = row["current_display"] as! String
            game.mistakes = row["mistakes"] as! Int
            game.maxMistakes = row["max_mistakes"] as! Int
            game.hasWon = row["has_won"] as! Bool
            game.hasLost = row["has_lost"] as! Bool
            
            // Return the loaded game
            return game
        }
    }
    
    /// Update statistics after a game finishes
    func updateStatistics(userId: String, gameWon: Bool, mistakes: Int, timeTaken: Int, score: Int) throws {
        try dbQueue.write { db in
            // Get the current date
            let today = Date()
            
            // Check if the user already has statistics
            let hasStats = try Row.fetchOne(db, sql: "SELECT COUNT(*) FROM statistics WHERE user_id = ?", arguments: [userId])?[0] as? Int ?? 0 > 0
            
            if hasStats {
                // Update existing statistics
                try db.execute(
                    sql: """
                        UPDATE statistics SET
                            games_played = games_played + 1,
                            games_won = games_won + ?,
                            current_streak = CASE WHEN ? THEN current_streak + 1 ELSE 0 END,
                            best_streak = CASE WHEN ? AND current_streak + 1 > best_streak THEN current_streak + 1 ELSE best_streak END,
                            total_score = total_score + ?,
                            average_mistakes = (average_mistakes * games_played + ?) / (games_played + 1),
                            average_time = (average_time * games_played + ?) / (games_played + 1),
                            last_played_date = ?
                        WHERE user_id = ?
                    """,
                    arguments: [
                        gameWon ? 1 : 0,
                        gameWon,
                        gameWon,
                        score,
                        mistakes,
                        timeTaken,
                        today,
                        userId
                    ]
                )
            } else {
                // Create new statistics record
                try db.execute(
                    sql: """
                        INSERT INTO statistics (
                            user_id, games_played, games_won, current_streak, best_streak,
                            total_score, average_mistakes, average_time, last_played_date
                        ) VALUES (?, 1, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    arguments: [
                        userId,
                        gameWon ? 1 : 0,
                        gameWon ? 1 : 0,
                        gameWon ? 1 : 0,
                        score,
                        Double(mistakes),
                        Double(timeTaken),
                        today
                    ]
                )
            }
        }
    }
}

// MARK: - Quote Methods
extension DatabaseManager {
    /// Get a random quote with optional difficulty filter
    func getRandomQuote(difficulty: String? = nil) throws -> (text: String, author: String, attribution: String?) {
        try dbQueue.read { db in
            // Build the query
            var sql = "SELECT * FROM quotes WHERE is_active = 1"
            var arguments: StatementArguments = []
            
            // Add difficulty filter if specified
            if let difficulty = difficulty {
                sql += " AND difficulty = ?"
                arguments = [difficulty]
            }
            
            // Add random order and limit
            sql += " ORDER BY RANDOM() LIMIT 1"
            
            // Execute the query
            guard let row = try Row.fetchOne(db, sql: sql, arguments: arguments) else {
                throw NSError(domain: "DatabaseManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "No quotes found"])
            }
            
            // Extract the quote data
            let text = row["text"] as! String
            let author = row["author"] as? String ?? "Unknown"
            let attribution = row["attribution"] as? String
            
            return (text, author, attribution)
        }
    }
    
    /// Add a new quote to the database
    func addQuote(text: String, author: String, attribution: String? = nil, difficulty: String) throws {
        try dbQueue.write { db in
            try db.execute(
                sql: "INSERT INTO quotes (text, author, attribution, difficulty, is_active) VALUES (?, ?, ?, ?, ?)",
                arguments: [text, author, attribution, difficulty, true]
            )
        }
    }
    
    /// Get all quotes
    func getAllQuotes() throws -> [(id: Int, text: String, author: String, difficulty: String)] {
        try dbQueue.read { db in
            var quotes: [(id: Int, text: String, author: String, difficulty: String)] = []
            
            let rows = try Row.fetchAll(db, sql: "SELECT id, text, author, difficulty FROM quotes ORDER BY difficulty, text")
            
            for row in rows {
                let id = row["id"] as! Int
                let text = row["text"] as! String
                let author = row["author"] as? String ?? "Unknown"
                let difficulty = row["difficulty"] as! String
                
                quotes.append((id: id, text: text, author: author, difficulty: difficulty))
            }
            
            return quotes
        }
    }
}

// MARK: - Statistics Methods
extension DatabaseManager {
    /// Get user statistics
    func getStatistics(userId: String) throws -> [String: Any]? {
        try dbQueue.read { db in
            guard let row = try Row.fetchOne(db, sql: "SELECT * FROM statistics WHERE user_id = ?", arguments: [userId]) else {
                return nil
            }
            
            return [
                "games_played": row["games_played"] as! Int,
                "games_won": row["games_won"] as! Int,
                "win_percentage": calculatePercentage(row["games_won"] as! Int, outOf: row["games_played"] as! Int),
                "current_streak": row["current_streak"] as! Int,
                "best_streak": row["best_streak"] as! Int,
                "total_score": row["total_score"] as! Int,
                "average_score": (row["games_played"] as! Int) > 0 ? (row["total_score"] as! Int) / (row["games_played"] as! Int) : 0,
                "average_mistakes": row["average_mistakes"] as! Double,
                "average_time": row["average_time"] as! Double,
                "last_played_date": row["last_played_date"] as? Date
            ]
        }
    }
    
    /// Calculate percentage helper
    private func calculatePercentage(_ value: Int, outOf total: Int) -> Double {
        guard total > 0 else { return 0.0 }
        return Double(value) / Double(total) * 100.0
    }
}//
//  DatabaseManager.swift
//  Decodey
//
//  Created by Daniel Horsley on 05/05/2025.
//

