//
//  ServiceProvider.swift
//  Personal Dictionary
//

import AppKit
import SwiftData

class ServiceProvider: NSObject {
    var modelContext: ModelContext?
    
    @objc func addWordService(_ pboard: NSPasteboard, userData: String, error: AutoreleasingUnsafeMutablePointer<NSString?>) {
        guard let text = pboard.string(forType: .string) else { return }
        let word = String(text.trimmingCharacters(in: .whitespacesAndNewlines).prefix(100))
        guard !word.isEmpty else { return }
        
        DispatchQueue.main.async {
            guard let context = self.modelContext else { return }
            
            let lowered = word.lowercased()
            let existing = (try? context.fetch(FetchDescriptor<WordEntry>())) ?? []
            if existing.contains(where: { $0.word.lowercased() == lowered }) {
                NSApp.requestUserAttention(.informationalRequest)
                return
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                let r = DictionaryService.shared.lookup(word: word)
                DispatchQueue.main.async {
                    let entry = WordEntry(
                        word: word,
                        definition: r?.definition ?? "",
                        example: r?.examples.joined(separator: "\n") ?? "",
                        phonetic: r?.phonetic ?? "",
                        partOfSpeech: r?.partOfSpeech ?? "",
                        synonyms: r?.synonyms.joined(separator: ", ") ?? "",
                        antonyms: r?.antonyms.joined(separator: ", ") ?? "",
                        audioURL: r?.audioURL ?? ""
                    )
                    context.insert(entry)
                    try? context.save()
                    NSApp.requestUserAttention(.informationalRequest)
                }
            }
        }
    }
}
