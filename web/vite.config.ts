import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'
import { defineConfig } from 'vite'
import { fileURLToPath } from 'node:url'

const repositoryRoot = fileURLToPath(new URL('..', import.meta.url))

export default defineConfig({
  plugins: [react(), tailwindcss()],
  server: {
    host: '127.0.0.1',
    fs: { allow: [repositoryRoot] },
    watch: { ignored: ['**/backend/target/**'] },
    proxy: {
      '/api': 'http://127.0.0.1:3001',
    },
  },
})
