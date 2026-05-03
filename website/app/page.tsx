const GITHUB_REPO = "HeyShinde/Personal-Dictionary";
const RELEASE_TAG = "v1.0.0";
const DOWNLOAD_URL = `https://github.com/${GITHUB_REPO}/releases/download/${RELEASE_TAG}/Personal-Dictionary-v1.0.zip`;
const GITHUB_URL = `https://github.com/${GITHUB_REPO}`;
const RELEASE_URL = `https://github.com/${GITHUB_REPO}/releases/tag/${RELEASE_TAG}`;

export default function Home() {
  return (
    <>
      <div className="hero-bg" />

      {/* Navigation */}
      <nav className="nav">
        <a href="/" className="nav-brand">
          <img src="/app-icon.png" alt="Personal Dictionary" />
          <span>Personal Dictionary</span>
        </a>
        <div className="nav-links">
          <a href="#features" className="nav-link">Features</a>
          <a href="#ai" className="nav-link">Apple Intelligence</a>
          <a href={GITHUB_URL} className="nav-link" target="_blank" rel="noopener">GitHub</a>
          <a href={DOWNLOAD_URL} className="nav-cta">Download Free</a>
        </div>
      </nav>

      {/* Hero */}
      <section className="hero">
        <div className="hero-badge">
          <span className="dot" />
          v1.0 — Now Available for macOS
        </div>

        <h1>
          Your Words,<br />
          <span className="gradient-text">Your Dictionary.</span>
        </h1>

        <p className="hero-subtitle">
          A beautiful, AI-powered macOS app to build your personal vocabulary.
          Rich definitions, audio pronunciation, thesaurus, and Apple Intelligence insights — all offline.
        </p>

        <div className="hero-actions">
          <a href={DOWNLOAD_URL} className="btn-primary">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4" />
              <polyline points="7 10 12 15 17 10" />
              <line x1="12" y1="15" x2="12" y2="3" />
            </svg>
            Download for macOS
          </a>
          <a href={GITHUB_URL} className="btn-secondary" target="_blank" rel="noopener">
            <svg viewBox="0 0 24 24" fill="currentColor" width="20" height="20">
              <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
            </svg>
            View Source
          </a>
        </div>

        <p className="hero-meta">
          macOS 26+ <span>•</span> Apple Silicon <span>•</span> Free & Open Source <span>•</span> 3.4 MB
        </p>

        {/* App Preview */}
        <div className="hero-preview">
          <div className="preview-window">
            <div className="preview-titlebar">
              <div className="preview-dot red" />
              <div className="preview-dot yellow" />
              <div className="preview-dot green" />
              <span>Personal Dictionary</span>
              <div style={{ width: 36 }} />
            </div>
            <div className="preview-body">
              <div className="preview-sidebar">
                <h3>My Dictionary</h3>
                <div className="count">42 words</div>
                <div className="preview-search">🔍 Search words...</div>
                <div className="preview-word active">
                  <div className="word-name">venture</div>
                  <div className="word-pos">noun</div>
                </div>
                <div className="preview-word">
                  <div className="word-name">ephemeral</div>
                  <div className="word-pos">adjective</div>
                </div>
                <div className="preview-word">
                  <div className="word-name">serendipity</div>
                  <div className="word-pos">noun</div>
                </div>
                <div className="preview-word">
                  <div className="word-name">eloquent</div>
                  <div className="word-pos">adjective</div>
                </div>
              </div>
              <div className="preview-detail">
                <h2>venture</h2>
                <div className="phonetic">ˈven(t)SHər &nbsp; 🔊 &nbsp; <span style={{ background: 'rgba(0,184,148,0.15)', color: '#00b894', padding: '2px 10px', borderRadius: 100, fontSize: 11, fontWeight: 600 }}>noun</span></div>
                <div className="date">📅 3 May 2026</div>

                <div className="preview-card">
                  <h4 className="def">📝 Definitions</h4>
                  <p>1. a risky or daring journey or undertaking<br/>2. a business enterprise involving considerable risk<br/>3. dare to do something dangerous or unpleasant</p>
                </div>

                <div className="preview-card">
                  <h4 className="syn">🔤 Synonyms</h4>
                  <div className="preview-tags">
                    {['enterprise', 'undertaking', 'project', 'endeavor', 'gamble', 'exploit', 'adventure'].map(s => (
                      <span key={s} className="preview-tag">{s}</span>
                    ))}
                  </div>
                </div>

                <div className="preview-card">
                  <h4 className="ai">✨ Apple Intelligence</h4>
                  <p style={{ fontSize: 12 }}>💡 Think of a venture like jumping into something exciting but uncertain — like starting a lemonade stand without knowing if anyone will buy.</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Features */}
      <section className="features" id="features">
        <div className="section-label">Features</div>
        <h2 className="section-title">Everything you need<br />to master new words.</h2>
        <p className="section-desc">
          Three data sources, one beautiful interface. No subscriptions, no accounts, no internet required for core features.
        </p>

        <div className="features-grid">
          <div className="feature-card">
            <div className="feature-icon" style={{ background: 'rgba(108,92,231,0.12)' }}>📚</div>
            <h3>Dual-Source Definitions</h3>
            <p>System Dictionary + Free Dictionary API. Up to 5 definitions per word across all parts of speech with automatic merging.</p>
          </div>
          <div className="feature-card">
            <div className="feature-icon" style={{ background: 'rgba(116,185,255,0.12)' }}>🔤</div>
            <h3>Rich Thesaurus</h3>
            <p>20+ synonyms and antonyms per word via Datamuse API. Displayed as beautiful flow-layout tag chips.</p>
          </div>
          <div className="feature-card">
            <div className="feature-icon" style={{ background: 'rgba(0,184,148,0.12)' }}>🔊</div>
            <h3>Audio Pronunciation</h3>
            <p>One-click audio playback with IPA phonetic notation. Hear exactly how every word is pronounced.</p>
          </div>
          <div className="feature-card">
            <div className="feature-icon" style={{ background: 'rgba(232,67,147,0.12)' }}>⚡</div>
            <h3>Menu Bar Quick Add</h3>
            <p>Copy any word anywhere, click the menu bar icon, press Enter. Your word is looked up and saved instantly.</p>
          </div>
          <div className="feature-card">
            <div className="feature-icon" style={{ background: 'rgba(253,203,110,0.12)' }}>🏷️</div>
            <h3>Categories & Favorites</h3>
            <p>12 built-in categories with custom icons. Sort by date, alphabetical, or filter by favorites.</p>
          </div>
          <div className="feature-card">
            <div className="feature-icon" style={{ background: 'rgba(108,92,231,0.12)' }}>📖</div>
            <h3>Native Dictionary.app</h3>
            <p>One-click to open any word in macOS Dictionary with the full, beautifully formatted system entry.</p>
          </div>
        </div>
      </section>

      {/* Apple Intelligence Section */}
      <section className="ai-section" id="ai">
        <div className="ai-container">
          <h2>Powered by <span className="gradient-text">Apple Intelligence</span></h2>
          <p>On-device AI generates personalized learning insights for every word in your dictionary. Completely private, no cloud required.</p>
          <div className="ai-features">
            <div className="ai-feature">
              <span className="emoji">💡</span>
              <div>
                <h4>Simple Explanation</h4>
                <p>Plain-English definition anyone can understand</p>
              </div>
            </div>
            <div className="ai-feature">
              <span className="emoji">✍️</span>
              <div>
                <h4>Memorable Sentence</h4>
                <p>A vivid example crafted to help you remember</p>
              </div>
            </div>
            <div className="ai-feature">
              <span className="emoji">🧠</span>
              <div>
                <h4>Memory Trick</h4>
                <p>Mnemonic or word association for retention</p>
              </div>
            </div>
            <div className="ai-feature">
              <span className="emoji">📝</span>
              <div>
                <h4>Usage Tip</h4>
                <p>When and how to use the word in context</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="cta">
        <h2>Start building your<br /><span style={{ background: 'linear-gradient(135deg, #6c5ce7, #e84393)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>vocabulary today.</span></h2>
        <p>Free, open source, and built for Mac.</p>
        <div className="hero-actions" style={{ justifyContent: 'center' }}>
          <a href={DOWNLOAD_URL} className="btn-primary">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" width="20" height="20">
              <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4" />
              <polyline points="7 10 12 15 17 10" />
              <line x1="12" y1="15" x2="12" y2="3" />
            </svg>
            Download v1.0.0
          </a>
          <a href={RELEASE_URL} className="btn-secondary" target="_blank" rel="noopener">
            View Release Notes
          </a>
        </div>
        <p className="hero-meta" style={{ marginTop: 16 }}>
          macOS 26+ <span>•</span> Apple Silicon <span>•</span> MIT License
        </p>
      </section>

      {/* Footer */}
      <footer className="footer">
        <p>© 2026 Personal Dictionary. Built with ❤️ by Ajinkya Shinde.</p>
        <div className="footer-links">
          <a href={GITHUB_URL} target="_blank" rel="noopener">GitHub</a>
          <a href={RELEASE_URL} target="_blank" rel="noopener">Releases</a>
          <a href={`${GITHUB_URL}/issues`} target="_blank" rel="noopener">Report Bug</a>
        </div>
      </footer>
    </>
  );
}
