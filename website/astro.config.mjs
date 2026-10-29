import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

// Cloudflare Pages Static Hosting (recommended for marketing & documentation sites):
// Zero cold start, global edge CDN caching, free tier friendly.
// To use Cloudflare SSR/Workers functions instead, import cloudflare from '@astrojs/cloudflare'
// and set: adapter: cloudflare({ imageService: 'passthrough' }), output: 'server'.
export default defineConfig({
  output: 'static',
  site: 'https://dictionary.shindeaditya.com',
  integrations: [sitemap()],
  build: {
    format: 'directory',
  },
});
