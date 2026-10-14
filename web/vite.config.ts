import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'
import { defineConfig } from 'vite'
import { fileURLToPath } from 'node:url'

const repositoryRoot = fileURLToPath(new URL('..', import.meta.url))

export default defineConfig({
  plugins: [react(), tailwindcss()],
  optimizeDeps: {
    include: [
      'react-syntax-highlighter/dist/esm/prism-light',
      'react-syntax-highlighter/dist/esm/styles/prism/one-dark',
      ...['solidity', 'typescript', 'javascript', 'python', 'json', 'toml', 'bash', 'markdown'].map(
        (language) => `react-syntax-highlighter/dist/esm/languages/prism/${language}`,
      ),
    ],
  },
  server: {
    host: '127.0.0.1',
    fs: { allow: [repositoryRoot] },
    watch: { ignored: ['**/backend/target/**'] },
    proxy: {
      '/api': 'http://127.0.0.1:3001',
    },
  },
})
