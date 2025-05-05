import SwiftUI

struct QuoteManagerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var quotes: [(id: Int, text: String, author: String, difficulty: String)] = []
    @State private var showingAddQuote = false
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    @State private var newQuoteText = ""
    @State private var newQuoteAuthor = ""
    @State private var newQuoteDifficulty = "medium"
    
    let difficulties = ["easy", "medium", "hard"]
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading quotes...")
                } else if let error = errorMessage {
                    VStack {
                        Text("Error loading quotes")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding()
                        
                        Button("Try Again") {
                            loadQuotes()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(difficulties, id: \.self) { difficulty in
                            Section(header: Text(difficulty.capitalized)) {
                                ForEach(quotes.filter { $0.difficulty == difficulty }, id: \.id) { quote in
                                    VStack(alignment: .leading) {
                                        Text(quote.text)
                                            .font(.headline)
                                        
                                        if !quote.author.isEmpty {
                                            Text("— \(quote.author)")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Quote Manager")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingAddQuote = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddQuote) {
                addQuoteView
            }
            .onAppear {
                loadQuotes()
            }
        }
    }
    
    // View for adding a new quote
    var addQuoteView: some View {
        NavigationView {
            Form {
                Section(header: Text("Quote Details")) {
                    TextEditor(text: $newQuoteText)
                        .frame(minHeight: 100)
                    
                    TextField("Author", text: $newQuoteAuthor)
                    
                    Picker("Difficulty", selection: $newQuoteDifficulty) {
                        Text("Easy").tag("easy")
                        Text("Medium").tag("medium")
                        Text("Hard").tag("hard")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section {
                    Button("Add Quote") {
                        addQuote()
                        showingAddQuote = false
                    }
                    .disabled(newQuoteText.isEmpty)
                }
            }
            .navigationTitle("Add Quote")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingAddQuote = false
                    }
                }
            }
        }
    }
    
    // Load quotes from database
    private func loadQuotes() {
        isLoading = true
        errorMessage = nil
        
        // Use a background thread for database operations
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let loadedQuotes = try DatabaseManager.shared.getAllQuotes()
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    quotes = loadedQuotes
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
    
    // Add a new quote to the database
    private func addQuote() {
        guard !newQuoteText.isEmpty else { return }
        
        // Use a background thread for database operations
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try DatabaseManager.shared.addQuote(
                    text: newQuoteText,
                    author: newQuoteAuthor,
                    difficulty: newQuoteDifficulty
                )
                
                // Reset form and reload quotes on main thread
                DispatchQueue.main.async {
                    newQuoteText = ""
                    newQuoteAuthor = ""
                    newQuoteDifficulty = "medium"
                    loadQuotes()
                }
            } catch {
                print("Error adding quote: \(error)")
                // Could add error handling UI here
            }
        }
    }
}

struct QuoteManagerView_Previews: PreviewProvider {
    static var previews: some View {
        QuoteManagerView()
    }
}
