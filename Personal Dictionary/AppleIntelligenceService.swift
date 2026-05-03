//
//  AppleIntelligenceService.swift
//  Personal Dictionary
//

import Foundation
import FoundationModels

@available(macOS 26.0, iOS 26.0, *)
class AppleIntelligenceService {
    static let shared = AppleIntelligenceService()
    
    var isAvailable: Bool {
        SystemLanguageModel.default.isAvailable
    }
    
    func generateInsights(word: String, definition: String, partOfSpeech: String) async throws -> String {
        guard isAvailable else {
            throw AIError.notAvailable
        }
        
        let session = LanguageModelSession()
        
        let prompt = """
        You are a vocabulary learning assistant. For the word "\(word)" \
        (\(partOfSpeech.isEmpty ? "" : partOfSpeech + ", ")meaning: \(definition.isEmpty ? "unknown" : definition)):

        Provide exactly 4 sections in this format:

        💡 Simple Explanation: Explain this word in one clear, simple sentence that anyone can understand.

        ✍️ Memorable Sentence: Write one vivid, creative example sentence using "\(word)" that paints a picture and helps remember the meaning.

        🧠 Memory Trick: Give a clever mnemonic, word association, or memory technique to remember what "\(word)" means.

        📝 Usage Tip: In one sentence, explain when and how to use this word (formal/informal, written/spoken context).
        """
        
        let response = try await session.respond(to: prompt)
        return response.content
    }
    
    enum AIError: LocalizedError {
        case notAvailable
        
        var errorDescription: String? {
            switch self {
            case .notAvailable:
                return "Apple Intelligence is not available on this device. Requires Apple Silicon Mac with macOS 26."
            }
        }
    }
}
