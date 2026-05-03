//
//  DictionaryService.swift
//  Personal Dictionary
//

import Foundation
import CoreServices

class DictionaryService {
    static let shared = DictionaryService()
    
    struct LookupResult {
        var definition: String
        var examples: [String]
        var phonetic: String
        var partOfSpeech: String
        var synonyms: [String]
        var antonyms: [String]
        var audioURL: String
    }
    
    func lookup(word: String) -> LookupResult? {
        let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return nil }
        
        let systemResult = lookupSystem(word: trimmed)
        let apiResult = lookupAPI(word: trimmed)
        let thesaurus = lookupThesaurus(word: trimmed)
        
        // Build base result from system + dictionary API
        var base: LookupResult
        if let sys = systemResult, let api = apiResult {
            let sysDefClean = sys.definition.trimmingCharacters(in: .whitespacesAndNewlines)
            let sysDefUsable = !sysDefClean.isEmpty
                && sysDefClean.count > 10
                && !sysDefClean.hasPrefix("[")
                && !sysDefClean.contains("•")
            base = LookupResult(
                definition: sysDefUsable ? sys.definition : api.definition,
                examples: mergeExamples(sys.examples, api.examples),
                phonetic: sys.phonetic.isEmpty ? api.phonetic : sys.phonetic,
                partOfSpeech: sys.partOfSpeech.isEmpty ? api.partOfSpeech : sys.partOfSpeech,
                synonyms: api.synonyms,
                antonyms: api.antonyms,
                audioURL: api.audioURL
            )
        } else if let api = apiResult {
            base = api
        } else if let sys = systemResult {
            base = sys
        } else {
            return nil
        }
        
        // Enrich with Datamuse thesaurus (many more synonyms/antonyms)
        if let thes = thesaurus {
            var allSyns = base.synonyms
            for s in thes.synonyms where !allSyns.contains(where: { $0.lowercased() == s.lowercased() }) {
                allSyns.append(s)
            }
            base.synonyms = Array(allSyns.prefix(20))
            
            var allAnts = base.antonyms
            for a in thes.antonyms where !allAnts.contains(where: { $0.lowercased() == a.lowercased() }) {
                allAnts.append(a)
            }
            base.antonyms = Array(allAnts.prefix(20))
        }
        
        return base
    }
    
    private func mergeExamples(_ a: [String], _ b: [String]) -> [String] {
        var result = a
        for ex in b {
            if !result.contains(where: { $0.lowercased() == ex.lowercased() }) {
                result.append(ex)
            }
            if result.count >= 3 { break }
        }
        return result
    }
    
    // MARK: - System Dictionary
    private func lookupSystem(word: String) -> LookupResult? {
        let nsWord = word as NSString
        let range = CFRangeMake(0, nsWord.length)
        guard let ref = DCSCopyTextDefinition(nil, nsWord as CFString, range) else { return nil }
        let raw = ref.takeRetainedValue() as String
        guard !raw.isEmpty else { return nil }
        
        var mainText = raw
        for marker in ["DERIVATIVES", "ORIGIN", "PHRASES", "USAGE"] {
            if let r = mainText.range(of: marker) {
                mainText = String(mainText[mainText.startIndex..<r.lowerBound])
            }
        }
        mainText = mainText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Extract phonetic between the FIRST TWO pipes only
        // (later pipes in the text are example/usage separators, not phonetic delimiters)
        var phonetic = ""
        let pipes = mainText.allIndices(of: "|")
        if pipes.count >= 2 {
            let candidate = String(mainText[mainText.index(after: pipes[0])..<pipes[1]])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            // Phonetics are short (< 60 chars) and don't contain full sentences
            if candidate.count < 60 && !candidate.contains(".") {
                phonetic = candidate
            }
        }
        
        // Text after the SECOND pipe (not the last!) contains POS + definition
        var afterPipes = mainText
        if pipes.count >= 2 {
            afterPipes = String(mainText[mainText.index(after: pipes[1])...])
                .trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let first = pipes.first {
            afterPipes = String(mainText[mainText.index(after: first)...])
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        var partOfSpeech = ""
        let posWords = ["adjective","noun","verb","adverb","pronoun","preposition","conjunction","interjection","exclamation","determiner"]
        let firstWord = afterPipes.components(separatedBy: .whitespaces).first?.lowercased() ?? ""
        if posWords.contains(firstWord) {
            partOfSpeech = firstWord
            if let r = afterPipes.range(of: firstWord, options: .caseInsensitive) {
                afterPipes = String(afterPipes[r.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        var definition = afterPipes
        var examples: [String] = []
        if let colonRange = afterPipes.range(of: ": ") {
            definition = String(afterPipes[afterPipes.startIndex..<colonRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
            let afterColon = String(afterPipes[colonRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            if let dot = afterColon.range(of: ".") {
                let ex = String(afterColon[afterColon.startIndex...dot.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
                if ex.count > 3 { examples.append(ex) }
            } else if afterColon.count > 3 {
                examples.append(afterColon)
            }
        }
        definition = definition.trimmingCharacters(in: CharacterSet(charactersIn: ".,;")).trimmingCharacters(in: .whitespacesAndNewlines)
        if definition.isEmpty { definition = afterPipes }
        
        return LookupResult(definition: definition, examples: examples, phonetic: phonetic,
                           partOfSpeech: partOfSpeech.capitalized, synonyms: [], antonyms: [], audioURL: "")
    }
    
    // MARK: - Free Dictionary API
    private func lookupAPI(word: String) -> LookupResult? {
        guard let encoded = word.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en/\(encoded)") else { return nil }
        
        let sem = DispatchSemaphore(value: 0)
        var result: LookupResult?
        URLSession.shared.dataTask(with: url) { data, _, error in
            defer { sem.signal() }
            guard let data = data, error == nil else { return }
            result = self.parseAPI(data)
        }.resume()
        sem.wait()
        return result
    }
    
    private func parseAPI(_ data: Data) -> LookupResult? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
              let entry = json.first else { return nil }
        
        var definitions: [String] = []
        var phonetic = "", partOfSpeech = "", audioURL = ""
        var examples: [String] = [], synonyms: [String] = [], antonyms: [String] = []
        
        // Phonetic & Audio
        if let ph = entry["phonetic"] as? String { phonetic = ph }
        if let phonetics = entry["phonetics"] as? [[String: Any]] {
            for p in phonetics {
                if phonetic.isEmpty, let t = p["text"] as? String, !t.isEmpty { phonetic = t }
                if audioURL.isEmpty, let a = p["audio"] as? String, !a.isEmpty { audioURL = a }
            }
        }
        
        // Meanings — collect definitions from ALL parts of speech
        if let meanings = entry["meanings"] as? [[String: Any]] {
            for meaning in meanings {
                let pos = (meaning["partOfSpeech"] as? String) ?? ""
                if partOfSpeech.isEmpty && !pos.isEmpty { partOfSpeech = pos }
                
                // Synonyms & antonyms at meaning level
                if let syns = meaning["synonyms"] as? [String] { synonyms.append(contentsOf: syns) }
                if let ants = meaning["antonyms"] as? [String] { antonyms.append(contentsOf: ants) }
                
                if let defs = meaning["definitions"] as? [[String: Any]] {
                    for def in defs {
                        if definitions.count < 5, let d = def["definition"] as? String, !d.isEmpty {
                            // Prefix with POS if there are multiple parts of speech
                            let prefix = (meanings.count > 1 && !pos.isEmpty) ? "(\(pos)) " : ""
                            definitions.append(prefix + d)
                        }
                        if examples.count < 3, let ex = def["example"] as? String, !ex.isEmpty {
                            examples.append(ex)
                        }
                        if let syns = def["synonyms"] as? [String] { synonyms.append(contentsOf: syns) }
                        if let ants = def["antonyms"] as? [String] { antonyms.append(contentsOf: ants) }
                    }
                }
            }
        }
        
        guard !definitions.isEmpty else { return nil }
        
        synonyms = Array(Set(synonyms)).sorted().prefix(8).map { $0 }
        antonyms = Array(Set(antonyms)).sorted().prefix(8).map { $0 }
        
        return LookupResult(definition: definitions.joined(separator: "\n"), examples: examples, phonetic: phonetic,
                           partOfSpeech: partOfSpeech.capitalized, synonyms: synonyms, antonyms: antonyms, audioURL: audioURL)
    }
    
    // MARK: - Datamuse Thesaurus API (rich synonyms/antonyms)
    private struct ThesaurusResult {
        var synonyms: [String]
        var antonyms: [String]
    }
    
    private func lookupThesaurus(word: String) -> ThesaurusResult? {
        guard let encoded = word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
        
        var synonyms: [String] = []
        var antonyms: [String] = []
        
        let group = DispatchGroup()
        
        // Fetch synonyms
        group.enter()
        if let url = URL(string: "https://api.datamuse.com/words?rel_syn=\(encoded)&max=20") {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                defer { group.leave() }
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { return }
                synonyms = json.compactMap { $0["word"] as? String }
            }.resume()
        } else { group.leave() }
        
        // Fetch antonyms
        group.enter()
        if let url = URL(string: "https://api.datamuse.com/words?rel_ant=\(encoded)&max=20") {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                defer { group.leave() }
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { return }
                antonyms = json.compactMap { $0["word"] as? String }
            }.resume()
        } else { group.leave() }
        
        group.wait()
        
        if synonyms.isEmpty && antonyms.isEmpty { return nil }
        return ThesaurusResult(synonyms: synonyms, antonyms: antonyms)
    }
}

private extension String {
    func allIndices(of char: Character) -> [String.Index] {
        var result: [String.Index] = []
        var start = startIndex
        while start < endIndex {
            if let r = self[start...].range(of: String(char)) {
                result.append(r.lowerBound)
                start = index(after: r.lowerBound)
            } else { break }
        }
        return result
    }
}
