//
//  QuickAddMenuView.swift
//  Personal Dictionary
//

import SwiftUI
import SwiftData

struct QuickAddMenuView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var existingWords: [WordEntry]
    
    @State private var word = ""
    @State private var status: Status = .idle
    @State private var resultMessage = ""
    
    enum Status {
        case idle, loading, success, error, duplicate
    }
    
    var body: some View {
        VStack(spacing: 14) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.accent)
                Text("Quick Add")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                
                // Paste from clipboard
                Button(action: pasteFromClipboard) {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.on.clipboard")
                            .font(.system(size: 10))
                        Text("Paste")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(AppTheme.subtleText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.white.opacity(0.08)))
                }
                .buttonStyle(.plain)
            }
            
            // Word Input
            HStack(spacing: 8) {
                TextField("Type or paste a word...", text: $word)
                    .textFieldStyle(.plain)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .onSubmit { addWord() }
                
                if status == .loading {
                    ProgressView()
                        .scaleEffect(0.6)
                        .tint(AppTheme.accent)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(statusBorderColor, lineWidth: 1)
                    )
            )
            
            // Status Message
            if !resultMessage.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: statusIcon)
                        .font(.system(size: 10, weight: .semibold))
                    Text(resultMessage)
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(statusColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Add Button
            Button(action: addWord) {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 13))
                    Text("Add to Dictionary")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: word.trimmingCharacters(in: .whitespaces).isEmpty
                                    ? [Color.gray.opacity(0.2), Color.gray.opacity(0.2)]
                                    : [AppTheme.accent, AppTheme.pink],
                                startPoint: .leading, endPoint: .trailing)
                        )
                )
            }
            .buttonStyle(.plain)
            .disabled(word.trimmingCharacters(in: .whitespaces).isEmpty || status == .loading)
            
            // Tip
            Text("💡 Copy any word → click menu bar icon → Enter")
                .font(.system(size: 9))
                .foregroundColor(AppTheme.subtleText)
        }
        .padding(16)
        .frame(width: 300)
        .background(AppTheme.surfaceBg)
        .onAppear {
            // Auto-paste from clipboard on appear
            pasteFromClipboard()
        }
    }
    
    private var statusBorderColor: Color {
        switch status {
        case .success: return AppTheme.green.opacity(0.4)
        case .error: return AppTheme.pink.opacity(0.4)
        case .duplicate: return AppTheme.gold.opacity(0.4)
        default: return Color.white.opacity(0.06)
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .success: return AppTheme.green
        case .error: return AppTheme.pink
        case .duplicate: return AppTheme.gold
        default: return AppTheme.subtleText
        }
    }
    
    private var statusIcon: String {
        switch status {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .duplicate: return "exclamationmark.triangle.fill"
        default: return "info.circle"
        }
    }
    
    private func pasteFromClipboard() {
        if let clipboard = NSPasteboard.general.string(forType: .string) {
            let cleaned = clipboard.trimmingCharacters(in: .whitespacesAndNewlines)
            // Only paste if it looks like a word (not a paragraph)
            if !cleaned.isEmpty && cleaned.count <= 50 && !cleaned.contains("\n") {
                word = cleaned
                status = .idle
                resultMessage = ""
            }
        }
    }
    
    private func addWord() {
        let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // Check for duplicates
        if existingWords.contains(where: { $0.word.lowercased() == trimmed.lowercased() }) {
            status = .duplicate
            resultMessage = "\"\(trimmed)\" is already in your dictionary"
            return
        }
        
        status = .loading
        resultMessage = "Looking up \"\(trimmed)\"..."
        
        DispatchQueue.global(qos: .userInitiated).async {
            let result = DictionaryService.shared.lookup(word: trimmed)
            DispatchQueue.main.async {
                let entry = WordEntry(
                    word: trimmed,
                    definition: result?.definition ?? "",
                    example: result?.examples.joined(separator: "\n") ?? "",
                    phonetic: result?.phonetic ?? "",
                    partOfSpeech: result?.partOfSpeech ?? "",
                    synonyms: result?.synonyms.joined(separator: ", ") ?? "",
                    antonyms: result?.antonyms.joined(separator: ", ") ?? "",
                    audioURL: result?.audioURL ?? ""
                )
                modelContext.insert(entry)
                try? modelContext.save()
                
                status = .success
                resultMessage = "✓ Added \"\(trimmed)\" with definition"
                word = ""
                
                // Reset after a moment
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    if status == .success {
                        status = .idle
                        resultMessage = ""
                    }
                }
            }
        }
    }
}
