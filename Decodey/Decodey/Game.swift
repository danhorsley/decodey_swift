import Foundation

struct Game {
    // Game state
    var encrypted: String
    var solution: String
    var currentDisplay: String
    var selectedLetter: Character?
    var mistakes: Int
    var maxMistakes: Int
    var hasWon: Bool
    var hasLost: Bool
    
    // Game ID for database reference
    var gameId: String?
    
    // Mapping dictionaries
    var mapping: [Character: Character]
    var correctMappings: [Character: Character]
    
    // Hint tracking
    var lastRevealedHint: (encrypted: Character, original: Character)?
    
    // Letter frequency in encrypted text
    var letterFrequency: [Character: Int]
    
    // Guessed mappings (user's input)
    var guessedMappings: [Character: Character]
    
    // Timestamp tracking
    var startTime: Date
    var lastUpdateTime: Date
    
    // Difficulty level
    var difficulty: String
    
    // Initialize with default values for a new game
    init() {
        // Default initialization
        self.encrypted = ""
        self.solution = ""
        self.currentDisplay = ""
        self.selectedLetter = nil
        self.mistakes = 0
        self.maxMistakes = 7
        self.hasWon = false
        self.hasLost = false
        self.gameId = nil
        self.mapping = [:]
        self.correctMappings = [:]
        self.lastRevealedHint = nil
        self.letterFrequency = [:]
        self.guessedMappings = [:]
        self.startTime = Date()
        self.lastUpdateTime = Date()
        self.difficulty = "medium"
        
        // Create a new game with a random quote
        setupNewGame()
    }
    
    // Initialize with a specific quote
    init(quote: String, author: String, difficulty: String = "medium") {
        // Initialize with default values
        self.encrypted = ""
        self.solution = quote.uppercased()
        self.currentDisplay = ""
        self.selectedLetter = nil
        self.mistakes = 0
        self.maxMistakes = difficultyToMaxMistakes(difficulty)
        self.hasWon = false
        self.hasLost = false
        self.gameId = nil
        self.mapping = [:]
        self.correctMappings = [:]
        self.lastRevealedHint = nil
        self.letterFrequency = [:]
        self.guessedMappings = [:]
        self.startTime = Date()
        self.lastUpdateTime = Date()
        self.difficulty = difficulty
        
        // Generate the game
        setupGameWithSolution(solution)
    }
    
    // Initialize from database values
    init(gameId: String, encrypted: String, solution: String, currentDisplay: String,
         mapping: [Character: Character], correctMappings: [Character: Character],
         guessedMappings: [Character: Character], mistakes: Int, maxMistakes: Int,
         hasWon: Bool, hasLost: Bool, difficulty: String, startTime: Date, lastUpdateTime: Date) {
        
        self.gameId = gameId
        self.encrypted = encrypted
        self.solution = solution
        self.currentDisplay = currentDisplay
        self.selectedLetter = nil
        self.mistakes = mistakes
        self.maxMistakes = maxMistakes
        self.hasWon = hasWon
        self.hasLost = hasLost
        self.mapping = mapping
        self.correctMappings = correctMappings
        self.guessedMappings = guessedMappings
        self.lastRevealedHint = nil
        self.startTime = startTime
        self.lastUpdateTime = lastUpdateTime
        self.difficulty = difficulty
        
        // Calculate letter frequency
        var frequency: [Character: Int] = [:]
        for char in encrypted where char.isLetter {
            frequency[char, default: 0] += 1
        }
        self.letterFrequency = frequency
    }
    
    // Convert difficulty level to max mistakes
    private func difficultyToMaxMistakes(_ difficulty: String) -> Int {
        switch difficulty.lowercased() {
        case "easy":
            return 10
        case "hard":
            return 5
        default: // "medium"
            return 7
        }
    }
    
    // Set up a new game with a random quote
    mutating func setupNewGame() {
        do {
            // Get a random quote from the database
            let (quoteText, quoteAuthor, _) = try DatabaseManager.shared.getRandomQuote()
            
            // Set the solution and difficulty
            self.solution = quoteText.uppercased()
            self.difficulty = "medium" // Default difficulty
            self.maxMistakes = difficultyToMaxMistakes(self.difficulty)
            
            // Set up the game
            setupGameWithSolution(solution)
            
        } catch {
            // Fallback to a default quote if database fails
            print("Error loading quote from database: \(error)")
            self.solution = "MANNERS MAKETH MAN."
            setupGameWithSolution(solution)
        }
    }
    
    // Set up game with a given solution
    mutating func setupGameWithSolution(_ solution: String) {
        // Generate a mapping for encryption
        var mapping: [Character: Character] = [:]
        let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let shuffled = alphabet.shuffled()
        
        for i in 0..<alphabet.count {
            mapping[alphabet[i]] = shuffled[i]
        }
        
        // Create reverse mapping (for verification)
        correctMappings = Dictionary(uniqueKeysWithValues: mapping.map { ($1, $0) })
        
        // Encrypt the solution
        encrypted = solution.map { char in
            if char.isLetter {
                return String(mapping[char] ?? char)
            }
            return String(char)
        }.joined()
        
        // Initialize display with blocks
        currentDisplay = solution.map { char in
            if char.isLetter {
                return "█"
            }
            return String(char)
        }.joined()
        
        // Calculate letter frequency
        letterFrequency = [:]
        for char in encrypted where char.isLetter {
            letterFrequency[char, default: 0] += 1
        }
        
        // Reset other game state
        self.mapping = mapping
        self.guessedMappings = [:]
        self.selectedLetter = nil
        self.mistakes = 0
        self.hasWon = false
        self.hasLost = false
        self.startTime = Date()
        self.lastUpdateTime = Date()
    }
    
    // Select letter for guessing
    mutating func selectLetter(_ letter: Character) {
        // Don't allow selecting already guessed letters
        if correctlyGuessed().contains(letter) {
            selectedLetter = nil
            return
        }
        
        selectedLetter = letter
    }
    
    // Make a guess
    mutating func makeGuess(_ guessedLetter: Character) -> Bool {
        guard let selected = selectedLetter else { return false }
        
        // Check if guess is correct
        let isCorrect = correctMappings[selected] == guessedLetter
        
        if isCorrect {
            // Store the mapping
            guessedMappings[selected] = guessedLetter
            
            // Update the display
            updateDisplay()
            
            // Check if we've won
            checkWinCondition()
        } else {
            // Increment mistakes
            mistakes += 1
            
            // Check if we've lost
            if mistakes >= maxMistakes {
                hasLost = true
            }
        }
        
        // Clear selection after guess
        selectedLetter = nil
        
        // Update last update time
        lastUpdateTime = Date()
        
        // Save the game state to database
        saveGameState()
        
        return isCorrect
    }
    
    // Update the display text based on guessed mappings
    mutating func updateDisplay() {
        var displayChars = Array(currentDisplay)
        
        for i in 0..<encrypted.count {
            let encryptedChar = Array(encrypted)[i]
            
            if let guessedChar = guessedMappings[encryptedChar] {
                displayChars[i] = guessedChar
            }
        }
        
        currentDisplay = String(displayChars)
    }
    
    // Check if all letters have been correctly guessed
    mutating func checkWinCondition() {
        let uniqueEncryptedLetters = Set(encrypted.filter { $0.isLetter })
        let guessedLetters = Set(guessedMappings.keys)
        
        hasWon = uniqueEncryptedLetters == guessedLetters
    }
    
    // Get the set of correctly guessed letters
    func correctlyGuessed() -> [Character] {
        return Array(guessedMappings.keys)
    }
    
    // Get the set of unique encrypted letters
    func uniqueEncryptedLetters() -> [Character] {
        return Array(Set(encrypted.filter { $0.isLetter })).sorted()
    }
    
    // Get a hint by revealing a random letter
    mutating func getHint() -> Bool {
        // Get all unguessed encrypted letters
        let unguessedLetters = Set(encrypted.filter { $0.isLetter && !correctlyGuessed().contains($0) })
        
        // If all letters are guessed, we can't provide a hint
        if unguessedLetters.isEmpty {
            return false
        }
        
        // Pick a random unguessed letter
        if let hintLetter = unguessedLetters.randomElement() {
            // Get the corresponding original letter
            let originalLetter = correctMappings[hintLetter] ?? "?"
            
            // Update the mapping
            guessedMappings[hintLetter] = originalLetter
            
            // Record this hint for animation
            lastRevealedHint = (hintLetter, originalLetter)
            
            // Update display
            updateDisplay()
            
            // Increment mistakes
            mistakes += 1
            
            // Check for win condition
            checkWinCondition()
            
            // Check for loss
            if mistakes >= maxMistakes {
                hasLost = true
            }
            
            // Update last update time
            lastUpdateTime = Date()
            
            // Save the game state to database
            saveGameState()
            
            return true
        }
        
        return false
    }
    
    // Save game state to database
    private func saveGameState() {
        do {
            if let gameId = self.gameId {
                // Update existing game
                try DatabaseManager.shared.updateGame(self, gameId: gameId)
            } else {
                // Save new game
                try DatabaseManager.shared.saveGame(self)
            }
        } catch {
            print("Error saving game state: \(error)")
        }
    }
    
    // Load the most recent game from database
    static func loadSavedGame() -> Game? {
        do {
            return try DatabaseManager.shared.loadLatestGame()
        } catch {
            print("Error loading saved game: \(error)")
            return nil
        }
    }
    
    // Calculate score based on difficulty, mistakes, and time
    func calculateScore() -> Int {
        let timeInSeconds = Int(lastUpdateTime.timeIntervalSince(startTime))
        
        // Base score depends on difficulty
        let baseScore: Int
        switch difficulty.lowercased() {
        case "easy":
            baseScore = 100
        case "hard":
            baseScore = 300
        default: // "medium"
            baseScore = 200
        }
        
        // Penalty for mistakes (more severe at higher difficulties)
        let mistakePenalty: Int
        switch difficulty.lowercased() {
        case "easy":
            mistakePenalty = mistakes * 5
        case "hard":
            mistakePenalty = mistakes * 15
        default: // "medium"
            mistakePenalty = mistakes * 10
        }
        
        // Time bonus/penalty
        let timeScore: Int
        if timeInSeconds < 60 { // Under 1 minute
            timeScore = 50
        } else if timeInSeconds < 180 { // Under 3 minutes
            timeScore = 30
        } else if timeInSeconds < 300 { // Under 5 minutes
            timeScore = 10
        } else if timeInSeconds > 600 { // Over 10 minutes
            timeScore = -20
        } else {
            timeScore = 0
        }
        
        // Calculate total score
        let totalScore = baseScore - mistakePenalty + timeScore
        
        // Ensure score is never negative
        return max(0, totalScore)
    }
}
