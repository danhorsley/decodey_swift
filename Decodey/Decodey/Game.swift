import Foundation

struct Game {
    // The encrypted quote
    let encrypted: String
    
    // The solution (for verification)
    let solution: String
    
    // The current display state (blocks or revealed letters)
    var currentDisplay: String
    
    // Mapping from encrypted to guessed letters
    var guessedMappings: [Character: Character] = [:]
    
    // Selected encrypted letter for guessing
    var selectedLetter: Character?
    
    // Track number of mistakes
    var mistakes: Int = 0
    var maxMistakes: Int = 7
    
    // Correct mappings (established at initialization)
    let correctMappings: [Character: Character]
    
    // Game state
    var hasWon: Bool = false
    var hasLost: Bool = false
    
    // For implementing hints
    var lastRevealedHint: (encrypted: Character, original: Character)?
    
    // Original letters to choose from
    let originalLetters: [Character] = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    
    // Letter frequency in encrypted text
    var letterFrequency: [Character: Int] = [:]
    
    // Initialize with a predefined quote
    init() {
        // Sample quote
        solution = "BELIEVE THAT LIFE IS WORTH LIVING AND YOUR BELIEF WILL HELP CREATE THE FACT."
        
        // Generate a mapping for encryption
        var mapping: [Character: Character] = [:]
        let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        var shuffled = alphabet.shuffled()
        
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
        for char in encrypted where char.isLetter {
            letterFrequency[char, default: 0] += 1
        }
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
            
            return true
        }
        
        return false
    }
}
