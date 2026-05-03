//
//  WordEntry.swift
//  Personal Dictionary
//

import Foundation
import SwiftData

@Model
final class WordEntry {
    var word: String
    var definition: String
    var example: String
    var phonetic: String
    var partOfSpeech: String
    var timestamp: Date
    var category: String
    var isFavorite: Bool
    var synonyms: String      // comma-separated
    var antonyms: String      // comma-separated
    var audioURL: String      // pronunciation audio URL
    var aiNotes: String       // Apple Intelligence generated insights
    
    init(
        word: String,
        definition: String = "",
        example: String = "",
        phonetic: String = "",
        partOfSpeech: String = "",
        category: String = "General",
        isFavorite: Bool = false,
        synonyms: String = "",
        antonyms: String = "",
        audioURL: String = "",
        aiNotes: String = ""
    ) {
        self.word = word
        self.definition = definition
        self.example = example
        self.phonetic = phonetic
        self.partOfSpeech = partOfSpeech
        self.timestamp = Date()
        self.category = category
        self.isFavorite = isFavorite
        self.synonyms = synonyms
        self.antonyms = antonyms
        self.audioURL = audioURL
        self.aiNotes = aiNotes
    }
}
