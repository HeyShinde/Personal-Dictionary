# 🌐 Personal Dictionary — Official Website

The official product website and documentation for **Personal Dictionary**, built with **Astro 7** and designed for seamless deployment on **Cloudflare Pages**.

## ✨ Features
- **Astro 7 Framework**: Ultra-fast, zero-JS by default, instant loading static generation.
- **Interactive macOS Tahoe Simulator**:
  - Live interactive vocabulary viewer with 6 preloaded entries
  - Real-time client-side search filtering (`⌘K` shortcut)
  - Native Web Speech audio pronunciation playback with animated sound wave
  - Dynamic favorite toggle (`★` / `☆`)
  - Interactive synonyms tag chips
- **Apple Sequoia / Tahoe Glassmorphic Design**:
  - Deep space black theme with luminous ambient gradient lighting
  - Responsive Bento grid showcasing all features
  - Spotlight on-device Apple Intelligence architecture
- **Ready for Cloudflare**:
  - Fully static edge delivery (`dist/`)
  - Pre-configured `wrangler.jsonc`
  - Zero server cold start and infinite edge CDN caching

---

## 🚀 Getting Started

### Prerequisites
- Node.js `v20+` or `v24+`
- npm `v10+`

### Installation
```bash
cd website
npm install
```

### Local Development
```bash
npm run dev
```
Visit `http://localhost:4321` in your browser.

### Build Production Bundle
```bash
npm run build
```
The compiled, optimized static assets will be output to the `dist/` directory.

### Preview Production Build
```bash
npm run preview
```

---

## ☁️ Deploying to Cloudflare Pages

### Option 1: Cloudflare Pages Git Integration (Recommended)
1. Go to the [Cloudflare Dashboard](https://dash.cloudflare.com/) → **Workers & Pages**.
2. Click **Create Application** → **Pages** → **Connect to Git**.
3. Select your repository `HeyShinde/Personal-Dictionary`.
4. Configure build settings:
   - **Framework preset**: `Astro`
   - **Build command**: `npm run build`
   - **Build output directory**: `dist`
   - **Root directory**: `website`
5. Click **Save and Deploy**. Cloudflare will automatically build and deploy the site globally on every git push!

### Option 2: Direct CLI Deployment via Wrangler
You can deploy directly to Cloudflare Pages using Wrangler:
```bash
cd website
# Build the website
npm run build

# Deploy dist folder to Cloudflare Pages
npx wrangler pages deploy dist --project-name=personal-dictionary
```

### Option 3: Cloudflare Pages with SSR / Workers (Optional)
If you wish to enable dynamic server-side rendering on Cloudflare Workers, uncomment `@astrojs/cloudflare` in `astro.config.mjs`:
```javascript
import { defineConfig } from 'astro/config';
import cloudflare from '@astrojs/cloudflare';

export default defineConfig({
  output: 'server',
  adapter: cloudflare({
    imageService: 'passthrough',
  }),
});
```

---

## 🛠 Project Structure
```
website/
├── public/                 # Static assets (icons, favicons, DMG references)
│   ├── app-icon.png
│   ├── favicon.ico
│   ├── icon.png
│   └── apple-icon.png
├── src/
│   ├── components/         # Reusable Astro components
│   │   ├── Navbar.astro
│   │   ├── Hero.astro
│   │   ├── AppSimulator.astro     # Interactive macOS app simulator
│   │   ├── FeaturesBento.astro    # Bento grid of core capabilities
│   │   ├── AppleIntelligence.astro# On-device AI deep dive
│   │   ├── TechStack.astro        # Swift 6, SwiftUI architecture
│   │   ├── InstallGuide.astro     # Download and DMG installation steps
│   │   ├── Footer.astro
│   │   └── Seo.astro              # OpenGraph, Twitter Cards, SEO
│   ├── layouts/
│   │   └── Layout.astro    # Global HTML wrapper and ambient background
│   ├── styles/
│   │   └── global.css      # Design tokens, keyframes, typography
│   └── pages/
│       └── index.astro     # Main landing page
├── astro.config.mjs        # Astro configuration
├── wrangler.jsonc          # Cloudflare Pages / Wrangler configuration
└── package.json
```
