# 📖 Personal Dictionary

A beautiful, AI-powered macOS dictionary app to build your personal vocabulary. Select any word, look it up instantly, and store it with rich definitions, examples, synonyms, antonyms, and audio pronunciation — all in one place.

![macOS](https://img.shields.io/badge/macOS-26+-blue?style=flat-square&logo=apple)
![Swift](https://img.shields.io/badge/Swift-6-orange?style=flat-square&logo=swift)
![SwiftUI](https://img.shields.io/badge/SwiftUI-✓-blue?style=flat-square)
![Apple Intelligence](https://img.shields.io/badge/Apple%20Intelligence-✓-purple?style=flat-square)

## ✨ Features

### 📚 Dictionary & Lookup
- **System Dictionary Integration** — Leverages macOS built-in dictionary via `DCSCopyTextDefinition`
- **Free Dictionary API Fallback** — Automatic fallback when system dictionary has no entry
- **Multiple Definitions** — Shows up to 5 definitions across all parts of speech (noun, verb, adjective...)
- **Open in Dictionary.app** — One-click to view the full entry in macOS Dictionary

### 🔊 Rich Word Data
- **Audio Pronunciation** — Play MP3 pronunciation from online sources
- **3 Usage Examples** — Merged from system dictionary + API
- **Synonyms & Antonyms** — Powered by Datamuse API (up to 20 each)
- **Phonetic Transcription** — IPA notation displayed alongside each word

### 🍎 Apple Intelligence
- **On-Device AI Insights** — Powered by Foundation Models framework
- **Simple Explanation** — Plain-English definition anyone can understand
- **Memorable Sentence** — A vivid example to help retention
- **Memory Trick** — Mnemonic or word association
- **Usage Tip** — Formal/informal context guidance
- Requires Apple Silicon Mac with macOS 26 and Apple Intelligence enabled

### 🎨 Premium UI
- Dark-mode-first design with glassmorphism cards
- Blue-to-pink gradient accent system
- Smooth animations and micro-interactions
- Custom `FlowLayout` for synonym/antonym tag chips
- Responsive split-view with resizable sidebar

### 📋 Organization
- **12 Categories** — General, Science, Technology, Literature, Medicine, Philosophy, Business, Art, Music, Law, History, Daily Life
- **Chip-based Category Picker** — Stylish grid with unique icons and colors
- **Favorites** — Star any word for quick access
- **Sort & Filter** — By date, alphabetical, category, or favorites
- **Duplicate Detection** — Warns before adding an existing word

### ⚡ Quick Add
- **Menu Bar Icon** — Persistent 📚 icon in the macOS menu bar
- **Clipboard Auto-Paste** — Copy any word, click the icon, press Enter
- **System Services** — Right-click → Services → Add to Personal Dictionary
- **Auto-Lookup** — Automatically fetches definition, examples, synonyms on add

## 🛠 Tech Stack

| Component | Technology |
|---|---|
| UI | SwiftUI |
| Data | SwiftData |
| System Dictionary | CoreServices (`DCSCopyTextDefinition`) |
| Dictionary API | [dictionaryapi.dev](https://dictionaryapi.dev) (free, no key) |
| Thesaurus API | [Datamuse](https://www.datamuse.com/api/) (free, no key) |
| AI | Foundation Models (Apple Intelligence) |
| Audio | AVFoundation |

## 📦 Installation

### Requirements
- macOS 26 (Tahoe) or later
- Xcode 26+
- Apple Silicon Mac (for Apple Intelligence features)

### Build from Source
```bash
git clone https://github.com/AjinkyaShinde03/Personal-Dictionary.git
cd Personal-Dictionary
open "Personal Dictionary.xcodeproj"
# Press Cmd+R to build and run
```

### System Service Setup
1. Build and run the app
2. Move to `/Applications` folder for best results
3. The "Add to Personal Dictionary" service will appear in right-click → Services
4. If not visible, run `pkill pboard` and restart

## 📸 Screenshots

*Coming soon*

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

## 🤝 Contributing

Pull requests welcome! Feel free to open issues for bugs or feature requests.
