# Decodey

A cryptography-based word puzzle game for iOS, iPadOS, and macOS, where players decrypt famous quotes by substituting letters.

## Features

- Substitution cipher puzzles with quotes of varying difficulty
- Satisfaction of breaking the code letter by letter
- Track your statistics and progress over time
- Create and manage your own quotes database
- Supports both light and dark mode
- Matrix-style animation on victory
- Hint system for when you're stuck
- Local SQLite database for persistent storage

## Installation

### Requirements
- iOS 16.0+ / macOS 13.0+
- Xcode 14.0+
- Swift 5.9+

### Steps

1. Clone the repository
```bash
git clone https://github.com/yourusername/Decodey.git
cd Decodey
```

2. Open the project in Xcode
```bash
open Decodey.xcodeproj
```

3. Install dependencies using Swift Package Manager
The project uses GRDB.swift as a dependency, which should be installed automatically when opening the project in Xcode. If not, you can add it manually by going to:

File > Add Packages > Enter the following URL:
```
https://github.com/groue/GRDB.swift.git
```

4. Build and run the project on your desired simulator or device

## How to Play

1. The game presents you with an encrypted quote where each letter has been substituted with another letter.
2. Tap on an encrypted letter to select it.
3. Then tap on a letter from the alphabet to guess the original letter.
4. If your guess is correct, all instances of that encrypted letter will be replaced with your guess.
5. If your guess is incorrect, you'll receive a strike.
6. You can use the hint button if you're stuck, but it will count as a partial mistake.
7. Win by correctly decrypting the entire quote before reaching the maximum number of mistakes.

## Database Management

The app uses SQLite via GRDB for storing:

- Quotes database
- Game progress
- Player statistics

You can manage quotes through the in-app quote manager, accessible from the menu in the top-left corner.

## Customization

You can customize the app by:

- Adding your own quotes via the Quote Manager
- Adjusting difficulty settings
- Toggling between light and dark mode

## Credits

- Original Flask/React app that this Swift version is based on
- GRDB.swift for SQLite database management
- All the famous quotes and their authors//
//  README.md
//  Decodey
//
//  Created by Daniel Horsley on 05/05/2025.
//

