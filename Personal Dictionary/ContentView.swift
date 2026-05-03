//
//  ContentView.swift
//  Personal Dictionary
//

import SwiftUI
import SwiftData
import AVFoundation

// MARK: - Theme
struct AppTheme {
    static let accent = Color(red: 0.45, green: 0.56, blue: 1.0)
    static let accentGlow = Color(red: 0.45, green: 0.56, blue: 1.0).opacity(0.3)
    static let cardBg = Color(red: 0.11, green: 0.11, blue: 0.14)
    static let surfaceBg = Color(red: 0.08, green: 0.08, blue: 0.10)
    static let subtleText = Color(white: 0.45)
    static let bodyText = Color(white: 0.85)
    static let gold = Color(red: 1.0, green: 0.78, blue: 0.28)
    static let green = Color(red: 0.35, green: 0.85, blue: 0.55)
    static let pink = Color(red: 0.95, green: 0.45, blue: 0.65)
}

// MARK: - Main View
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WordEntry.timestamp, order: .reverse) private var words: [WordEntry]
    
    @State private var searchText = ""
    @State private var selectedWord: WordEntry?
    @State private var isAddingNewWord = false
    @State private var sidebarWidth: CGFloat = 260
    @State private var selectedCategory: String = "All"
    @State private var sortOrder: SortOrder = .newest
    
    enum SortOrder: String, CaseIterable {
        case newest = "Newest"
        case oldest = "Oldest"
        case alphabetical = "A → Z"
        case reverseAlpha = "Z → A"
    }
    
    var filteredWords: [WordEntry] {
        var result = words
        
        // Category / Favorites filter
        if selectedCategory == "★ Favorites" {
            result = result.filter { $0.isFavorite }
        } else if selectedCategory != "All" {
            result = result.filter { $0.category == selectedCategory }
        }
        
        // Search filter
        if !searchText.isEmpty {
            result = result.filter { $0.word.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Sort
        switch sortOrder {
        case .newest: result.sort { $0.timestamp > $1.timestamp }
        case .oldest: result.sort { $0.timestamp < $1.timestamp }
        case .alphabetical: result.sort { $0.word.lowercased() < $1.word.lowercased() }
        case .reverseAlpha: result.sort { $0.word.lowercased() > $1.word.lowercased() }
        }
        
        return result
    }
    
    private var usedCategories: [String] {
        let cats = Set(words.map { $0.category })
        var list = ["All"]
        if words.contains(where: { $0.isFavorite }) {
            list.append("★ Favorites")
        }
        list.append(contentsOf: WordCategories.all.filter { cats.contains($0) })
        return list
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack(spacing: 0) {
                sidebarHeader
                searchBar
                wordList
            }
            .frame(width: sidebarWidth)
            .background(AppTheme.surfaceBg)
            
            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 1)
            
            // Detail
            if let word = selectedWord {
                WordDetailView(wordEntry: word)
            } else {
                emptyState
            }
        }
        .background(Color(red: 0.06, green: 0.06, blue: 0.08))
        .sheet(isPresented: $isAddingNewWord) {
            AddWordView(isPresented: $isAddingNewWord)
        }
    }
    
    // MARK: - Sidebar Header
    private var sidebarHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("My Dictionary")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("\(words.count) words")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.subtleText)
            }
            Spacer()
            Button(action: { isAddingNewWord = true }) {
                ZStack {
                    Circle()
                        .fill(AppTheme.accent)
                        .frame(width: 30, height: 30)
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)
            .shadow(color: AppTheme.accentGlow, radius: 8, y: 2)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.subtleText)
                TextField("Search words...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.06))
            )
            
            // Filter row: category + sort
            HStack(spacing: 6) {
                // Category filter
                Menu {
                    ForEach(usedCategories, id: \.self) { cat in
                        Button(action: { selectedCategory = cat }) {
                            HStack {
                                if cat == "★ Favorites" {
                                    Image(systemName: "star.fill")
                                } else if cat != "All" {
                                    Image(systemName: WordCategories.icon(for: cat))
                                }
                                Text(cat)
                                if selectedCategory == cat {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    let filterIcon: String = {
                        if selectedCategory == "All" { return "line.3.horizontal.decrease" }
                        if selectedCategory == "★ Favorites" { return "star.fill" }
                        return WordCategories.icon(for: selectedCategory)
                    }()
                    let filterColor: Color = {
                        if selectedCategory == "All" { return AppTheme.subtleText }
                        if selectedCategory == "★ Favorites" { return AppTheme.gold }
                        return WordCategories.color(for: selectedCategory)
                    }()
                    HStack(spacing: 4) {
                        Image(systemName: filterIcon)
                            .font(.system(size: 9, weight: .semibold))
                        Text(selectedCategory)
                            .font(.system(size: 10, weight: .semibold))
                            .lineLimit(1)
                    }
                    .foregroundColor(filterColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.06))
                    )
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
                
                // Sort
                Menu {
                    ForEach(SortOrder.allCases, id: \.self) { order in
                        Button(action: { sortOrder = order }) {
                            HStack {
                                Text(order.rawValue)
                                if sortOrder == order {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 9, weight: .semibold))
                        Text(sortOrder.rawValue)
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(AppTheme.subtleText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.06))
                    )
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
                
                Spacer()
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }
    
    // MARK: - Word List
    private var wordList: some View {
        ScrollView {
            LazyVStack(spacing: 4) {
                ForEach(filteredWords) { entry in
                    WordRow(entry: entry, isSelected: selectedWord?.id == entry.id)
                        .onTapGesture { withAnimation(.easeInOut(duration: 0.2)) { selectedWord = entry } }
                        .contextMenu {
                            Button(role: .destructive) {
                                if selectedWord?.id == entry.id { selectedWord = nil }
                                modelContext.delete(entry)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {
                                entry.isFavorite.toggle()
                            } label: {
                                Label(entry.isFavorite ? "Unfavorite" : "Favorite", systemImage: entry.isFavorite ? "star.slash" : "star")
                            }
                        }
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 16)
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(AppTheme.accent.opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: "text.book.closed")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(
                        LinearGradient(colors: [AppTheme.accent, AppTheme.pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }
            VStack(spacing: 8) {
                Text("Your Personal Lexicon")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Select a word or tap + to add one")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.subtleText)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Word Row
struct WordRow: View {
    let entry: WordEntry
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Color bar
            RoundedRectangle(cornerRadius: 2)
                .fill(posColor)
                .frame(width: 3, height: 36)
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(entry.word)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    if entry.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                            .foregroundColor(AppTheme.gold)
                    }
                }
                if !entry.partOfSpeech.isEmpty {
                    Text(entry.partOfSpeech.lowercased())
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(posColor)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? AppTheme.accent.opacity(0.15) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? AppTheme.accent.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
    
    private var posColor: Color {
        switch entry.partOfSpeech.lowercased() {
        case "noun": return AppTheme.accent
        case "verb": return AppTheme.green
        case "adjective": return AppTheme.pink
        case "adverb": return AppTheme.gold
        default: return AppTheme.subtleText
        }
    }
}

// MARK: - Word Detail View
struct WordDetailView: View {
    @Bindable var wordEntry: WordEntry
    @State private var isLookingUp = false
    @State private var isPlayingAudio = false
    @State private var isGeneratingAI = false
    @State private var aiError: String?
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header Card
                headerCard
                    .padding(.bottom, 24)
                
                // Definitions Card
                sectionCard(title: "Definitions", icon: "text.alignleft", color: AppTheme.accent) {
                    let defs = wordEntry.definition.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                    if defs.isEmpty {
                        Text("No definition yet. Tap refresh to fetch.")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.subtleText)
                            .italic()
                    } else if defs.count == 1 {
                        Text(defs[0])
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.bodyText)
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(Array(defs.enumerated()), id: \.offset) { idx, def in
                                HStack(alignment: .top, spacing: 10) {
                                    Text("\(idx + 1)")
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                        .foregroundColor(AppTheme.accent)
                                        .frame(width: 18, height: 18)
                                        .background(
                                            Circle().fill(AppTheme.accent.opacity(0.15))
                                        )
                                    Text(def)
                                        .font(.system(size: 14))
                                        .foregroundColor(AppTheme.bodyText)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 16)
                
                // Examples Card
                sectionCard(title: "Usage Examples", icon: "quote.opening", color: AppTheme.green) {
                    let examples = wordEntry.example.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                    if examples.isEmpty {
                        Text("No examples yet. Tap refresh to fetch.")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.subtleText)
                            .italic()
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(Array(examples.enumerated()), id: \.offset) { idx, ex in
                                HStack(alignment: .top, spacing: 10) {
                                    Text("\(idx + 1)")
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                        .foregroundColor(AppTheme.green)
                                        .frame(width: 18, height: 18)
                                        .background(
                                            Circle().fill(AppTheme.green.opacity(0.15))
                                        )
                                    Text(ex)
                                        .font(.system(size: 14, design: .serif))
                                        .italic()
                                        .foregroundColor(AppTheme.bodyText)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 16)
                
                // Synonyms Card
                if !wordEntry.synonyms.isEmpty {
                    sectionCard(title: "Synonyms", icon: "arrow.triangle.branch", color: AppTheme.accent) {
                        FlowLayout(spacing: 6) {
                            ForEach(wordEntry.synonyms.components(separatedBy: ", ").filter { !$0.isEmpty }, id: \.self) { syn in
                                Text(syn)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(AppTheme.accent)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(AppTheme.accent.opacity(0.12))
                                    )
                            }
                        }
                    }
                    .padding(.bottom, 16)
                }
                
                // Antonyms Card
                if !wordEntry.antonyms.isEmpty {
                    sectionCard(title: "Antonyms", icon: "arrow.left.arrow.right", color: AppTheme.pink) {
                        FlowLayout(spacing: 6) {
                            ForEach(wordEntry.antonyms.components(separatedBy: ", ").filter { !$0.isEmpty }, id: \.self) { ant in
                                Text(ant)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(AppTheme.pink)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(AppTheme.pink.opacity(0.12))
                                    )
                            }
                        }
                    }
                    .padding(.bottom, 16)
                }
                
                // Apple Intelligence Card
                if #available(macOS 26.0, *) {
                    aiInsightsCard
                        .padding(.bottom, 16)
                }
                
                // Category Card
                sectionCard(title: "Category", icon: "tag", color: AppTheme.gold) {
                    CategoryPicker(selected: $wordEntry.category)
                }
                
                Spacer(minLength: 40)
            }
            .padding(36)
        }
        .background(Color(red: 0.06, green: 0.06, blue: 0.08))
    }
    
    // MARK: - Header Card
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(wordEntry.word)
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 12) {
                        if !wordEntry.phonetic.isEmpty {
                            Text(wordEntry.phonetic)
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(AppTheme.subtleText)
                        }
                        if !wordEntry.audioURL.isEmpty {
                            Button(action: playAudio) {
                                Image(systemName: isPlayingAudio ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(AppTheme.accent)
                                    .padding(6)
                                    .background(Circle().fill(AppTheme.accent.opacity(0.15)))
                            }
                            .buttonStyle(.plain)
                        }
                        if !wordEntry.partOfSpeech.isEmpty {
                            Text(wordEntry.partOfSpeech.lowercased())
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(posColor)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule().fill(posColor.opacity(0.15))
                                )
                        }
                    }
                }
                Spacer()
                
                // Favorite toggle
                Button(action: { withAnimation { wordEntry.isFavorite.toggle() } }) {
                    Image(systemName: wordEntry.isFavorite ? "star.fill" : "star")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(wordEntry.isFavorite ? AppTheme.gold : AppTheme.subtleText)
                        .frame(width: 34, height: 34)
                        .background(
                            Circle().fill(wordEntry.isFavorite ? AppTheme.gold.opacity(0.15) : Color.white.opacity(0.06))
                        )
                }
                .buttonStyle(.plain)
                
                // Open in macOS Dictionary.app
                Button(action: openInDictionary) {
                    HStack(spacing: 6) {
                        Image(systemName: "book.pages")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Dictionary")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(colors: [AppTheme.accent, AppTheme.pink],
                                             startPoint: .leading, endPoint: .trailing)
                            )
                    )
                    .shadow(color: AppTheme.accentGlow, radius: 8, y: 2)
                }
                .buttonStyle(.plain)
                
                // Refresh definition from system dictionary
                Button(action: refreshFromSystem) {
                    Group {
                        if isLookingUp {
                            ProgressView()
                                .scaleEffect(0.55)
                                .tint(AppTheme.subtleText)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 11, weight: .semibold))
                        }
                    }
                    .foregroundColor(AppTheme.subtleText)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(Color.white.opacity(0.06)))
                }
                .buttonStyle(.plain)
                .disabled(isLookingUp)
                .help("Refresh definition from system dictionary")
            }
            
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.system(size: 10))
                Text(wordEntry.timestamp, format: .dateTime.day().month(.wide).year())
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(AppTheme.subtleText)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Section Card
    private func sectionCard<Content: View>(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(color)
            }
            content()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppTheme.cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.04), lineWidth: 1)
                )
        )
    }
    
    private var posColor: Color {
        switch wordEntry.partOfSpeech.lowercased() {
        case "noun": return AppTheme.accent
        case "verb": return AppTheme.green
        case "adjective": return AppTheme.pink
        case "adverb": return AppTheme.gold
        default: return AppTheme.subtleText
        }
    }
    
    private func openInDictionary() {
        let encoded = wordEntry.word.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? wordEntry.word
        if let url = URL(string: "dict://\(encoded)") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func refreshFromSystem() {
        isLookingUp = true
        DispatchQueue.global(qos: .userInitiated).async {
            let result = DictionaryService.shared.lookup(word: wordEntry.word)
            DispatchQueue.main.async {
                if let result = result {
                    wordEntry.definition = result.definition
                    if !result.examples.isEmpty {
                        wordEntry.example = result.examples.joined(separator: "\n")
                    }
                    if !result.phonetic.isEmpty { wordEntry.phonetic = result.phonetic }
                    if !result.partOfSpeech.isEmpty { wordEntry.partOfSpeech = result.partOfSpeech }
                    if !result.synonyms.isEmpty { wordEntry.synonyms = result.synonyms.joined(separator: ", ") }
                    if !result.antonyms.isEmpty { wordEntry.antonyms = result.antonyms.joined(separator: ", ") }
                    if !result.audioURL.isEmpty { wordEntry.audioURL = result.audioURL }
                }
                isLookingUp = false
            }
        }
    }
    
    private func playAudio() {
        guard let url = URL(string: wordEntry.audioURL) else { return }
        isPlayingAudio = true
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                DispatchQueue.main.async { isPlayingAudio = false }
                return
            }
            DispatchQueue.main.async {
                do {
                    audioPlayer = try AVAudioPlayer(data: data)
                    audioPlayer?.play()
                    // Reset icon after audio duration
                    DispatchQueue.main.asyncAfter(deadline: .now() + (audioPlayer?.duration ?? 1.0)) {
                        isPlayingAudio = false
                    }
                } catch {
                    isPlayingAudio = false
                }
            }
        }.resume()
    }
    
    // MARK: - Apple Intelligence
    private static let aiPurple = Color(red: 0.56, green: 0.35, blue: 0.97)
    
    @available(macOS 26.0, *)
    private var aiInsightsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "apple.intelligence")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(colors: [Self.aiPurple, AppTheme.pink, AppTheme.accent],
                                     startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                Text("Apple Intelligence")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [Self.aiPurple, AppTheme.pink],
                                     startPoint: .leading, endPoint: .trailing)
                    )
                Spacer()
                
                if !wordEntry.aiNotes.isEmpty {
                    Button(action: { generateAIInsights() }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(AppTheme.subtleText)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            if isGeneratingAI {
                HStack(spacing: 10) {
                    ProgressView()
                        .scaleEffect(0.7)
                        .tint(Self.aiPurple)
                    Text("Thinking...")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(AppTheme.subtleText)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 16)
            } else if let error = aiError {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.pink)
                    .padding(.vertical, 4)
            } else if wordEntry.aiNotes.isEmpty {
                Button(action: { generateAIInsights() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                        Text("Generate Learning Insights")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(colors: [Self.aiPurple, AppTheme.pink],
                                             startPoint: .leading, endPoint: .trailing)
                            )
                    )
                    .shadow(color: Self.aiPurple.opacity(0.3), radius: 8, y: 2)
                }
                .buttonStyle(.plain)
            } else {
                // Display AI notes with formatting
                let sections = wordEntry.aiNotes.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(sections, id: \.self) { section in
                        Text(section)
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.bodyText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppTheme.cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            LinearGradient(colors: [Self.aiPurple.opacity(0.2), AppTheme.pink.opacity(0.1)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1
                        )
                )
        )
    }
    
    private func generateAIInsights() {
        guard #available(macOS 26.0, *) else { return }
        isGeneratingAI = true
        aiError = nil
        
        Task {
            do {
                let result = try await AppleIntelligenceService.shared.generateInsights(
                    word: wordEntry.word,
                    definition: wordEntry.definition.components(separatedBy: "\n").first ?? wordEntry.definition,
                    partOfSpeech: wordEntry.partOfSpeech
                )
                await MainActor.run {
                    wordEntry.aiNotes = result
                    isGeneratingAI = false
                }
            } catch {
                await MainActor.run {
                    aiError = error.localizedDescription
                    isGeneratingAI = false
                }
            }
        }
    }
}

// MARK: - Category Constants & Picker
struct WordCategories {
    static let all = [
        "General", "Science", "Technology", "Literature",
        "Medicine", "Philosophy", "Business", "Art",
        "Music", "Law", "History", "Daily Life"
    ]
    
    static func icon(for category: String) -> String {
        switch category {
        case "Science": return "atom"
        case "Technology": return "cpu"
        case "Literature": return "book"
        case "Medicine": return "cross.case"
        case "Philosophy": return "brain.head.profile"
        case "Business": return "briefcase"
        case "Art": return "paintpalette"
        case "Music": return "music.note"
        case "Law": return "building.columns"
        case "History": return "clock.arrow.circlepath"
        case "Daily Life": return "cup.and.saucer"
        default: return "folder"
        }
    }
    
    static func color(for category: String) -> Color {
        switch category {
        case "Science": return AppTheme.green
        case "Technology": return AppTheme.accent
        case "Literature": return AppTheme.pink
        case "Medicine": return Color(red: 0.9, green: 0.35, blue: 0.35)
        case "Philosophy": return Color(red: 0.7, green: 0.5, blue: 0.9)
        case "Business": return AppTheme.gold
        case "Art": return Color(red: 0.95, green: 0.55, blue: 0.35)
        case "Music": return Color(red: 0.4, green: 0.8, blue: 0.85)
        case "Law": return Color(red: 0.6, green: 0.65, blue: 0.75)
        case "History": return Color(red: 0.75, green: 0.6, blue: 0.45)
        case "Daily Life": return Color(red: 0.55, green: 0.78, blue: 0.55)
        default: return AppTheme.subtleText
        }
    }
}

struct CategoryPicker: View {
    @Binding var selected: String
    
    private let columns = [GridItem(.adaptive(minimum: 90), spacing: 8)]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(WordCategories.all, id: \.self) { cat in
                let isActive = selected == cat
                let catColor = WordCategories.color(for: cat)
                
                Button(action: { withAnimation(.easeInOut(duration: 0.15)) { selected = cat } }) {
                    HStack(spacing: 5) {
                        Image(systemName: WordCategories.icon(for: cat))
                            .font(.system(size: 9, weight: .semibold))
                        Text(cat)
                            .font(.system(size: 10, weight: .semibold))
                            .lineLimit(1)
                    }
                    .foregroundColor(isActive ? .white : catColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isActive ? catColor.opacity(0.8) : catColor.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isActive ? catColor : Color.clear, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Add Word View
struct AddWordView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    
    @Query private var existingWords: [WordEntry]
    
    @State private var word = ""
    @State private var definition = ""
    @State private var example = ""
    @State private var category = "General"
    @State private var isSearching = false
    @State private var lookupDone = false
    @State private var showDuplicateWarning = false
    @FocusState private var isWordFocused: Bool
    
    private var isDuplicate: Bool {
        let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return existingWords.contains { $0.word.lowercased() == trimmed }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            ZStack {
                LinearGradient(
                    colors: [AppTheme.accent.opacity(0.15), AppTheme.pink.opacity(0.08), Color.clear],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .frame(height: 80)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Add New Word")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("Build your vocabulary")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.subtleText)
                    }
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.subtleText)
                            .padding(8)
                            .background(Circle().fill(Color.white.opacity(0.08)))
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.escape, modifiers: [])
                }
                .padding(.horizontal, 24)
            }
            
            ScrollView {
                VStack(spacing: 20) {
                    // Word Input Card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Label("WORD", systemImage: "textformat")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(AppTheme.accent)
                            Spacer()
                            if isDuplicate && !word.isEmpty {
                                HStack(spacing: 4) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 9))
                                    Text("Already exists")
                                        .font(.system(size: 10, weight: .semibold))
                                }
                                .foregroundColor(AppTheme.gold)
                            }
                        }
                        
                        HStack(spacing: 12) {
                            TextField("Type a word...", text: $word)
                                .textFieldStyle(.plain)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .focused($isWordFocused)
                            
                            if isSearching {
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .tint(AppTheme.accent)
                            } else if !word.isEmpty {
                                Button(action: autoLookup) {
                                    HStack(spacing: 5) {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 11))
                                        Text("Auto Fill")
                                            .font(.system(size: 11, weight: .bold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(
                                        Capsule().fill(
                                            LinearGradient(colors: [AppTheme.accent, AppTheme.pink],
                                                         startPoint: .leading, endPoint: .trailing)
                                        )
                                    )
                                    .shadow(color: AppTheme.accentGlow, radius: 6, y: 2)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(AppTheme.cardBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(AppTheme.accent.opacity(lookupDone ? 0.3 : 0.08), lineWidth: 1)
                            )
                    )
                    
                    // Definition Card
                    VStack(alignment: .leading, spacing: 10) {
                        Label("DEFINITION", systemImage: "text.alignleft")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.accent)
                        
                        TextEditor(text: $definition)
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.bodyText)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 70, maxHeight: 100)
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(AppTheme.cardBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.04), lineWidth: 1)
                            )
                    )
                    
                    // Example Card
                    VStack(alignment: .leading, spacing: 10) {
                        Label("EXAMPLE", systemImage: "quote.opening")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.green)
                        
                        TextEditor(text: $example)
                            .font(.system(size: 14, design: .serif))
                            .italic()
                            .foregroundColor(AppTheme.bodyText)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 50, maxHeight: 80)
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(AppTheme.cardBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.04), lineWidth: 1)
                            )
                    )
                    
                    // Category Card
                    VStack(alignment: .leading, spacing: 10) {
                        Label("CATEGORY", systemImage: "tag")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.gold)
                        
                        CategoryPicker(selected: $category)
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(AppTheme.cardBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.04), lineWidth: 1)
                            )
                    )
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            
            // Add Button
            Button(action: {
                if isDuplicate {
                    showDuplicateWarning = true
                } else {
                    addWord()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: isDuplicate ? "exclamationmark.triangle.fill" : "plus.circle.fill")
                        .font(.system(size: 16))
                    Text(isDuplicate ? "Word Already Exists" : "Add to Dictionary")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                    ? [Color.gray.opacity(0.2), Color.gray.opacity(0.2)]
                                    : isDuplicate
                                        ? [AppTheme.gold.opacity(0.7), AppTheme.gold.opacity(0.5)]
                                        : [AppTheme.accent, AppTheme.pink],
                                startPoint: .leading, endPoint: .trailing)
                        )
                )
                .shadow(color: word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .clear : AppTheme.accentGlow, radius: 14, y: 4)
            }
            .buttonStyle(.plain)
            .disabled(word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            .alert("Duplicate Word", isPresented: $showDuplicateWarning) {
                Button("Add Anyway", role: .destructive) { addWord() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("\"\(word)\" is already in your dictionary. Add it again?")
            }
        }
        .frame(width: 460, height: 620)
        .background(AppTheme.surfaceBg)
        .onAppear { isWordFocused = true }
    }
    
    private func addWord() {
        let cleanWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanWord.isEmpty else { return }
        let newEntry = WordEntry(
            word: cleanWord,
            definition: definition.trimmingCharacters(in: .whitespacesAndNewlines),
            example: example.trimmingCharacters(in: .whitespacesAndNewlines),
            category: category
        )
        modelContext.insert(newEntry)
        isPresented = false
    }
    
    private func autoLookup() {
        guard !word.isEmpty else { return }
        isSearching = true
        lookupDone = false
        DispatchQueue.global(qos: .userInitiated).async {
            let result = DictionaryService.shared.lookup(word: word)
            DispatchQueue.main.async {
                if let r = result {
                    definition = r.definition
                    if !r.examples.isEmpty {
                        example = r.examples.joined(separator: "\n")
                    }
                    withAnimation { lookupDone = true }
                }
                isSearching = false
            }
        }
    }
}

// MARK: - Flow Layout (for tags)
struct FlowLayout: Layout {
    var spacing: CGFloat = 6
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        
        return CGSize(width: maxWidth, height: y + rowHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
