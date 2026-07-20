// ═══════════════════════════════════════════════════════════════
// StockOps — Service Worker
// ═══════════════════════════════════════════════════════════════
//
// Estratégia: Network-first com fallback de cache para o app shell.
// Recursos do Firebase NÃO são cacheados (sempre buscam dados frescos).
//
// Ao mudar APP_VERSION, todos os clientes invalidam o cache antigo.
//
// ═══════════════════════════════════════════════════════════════

const APP_VERSION = 'stockops-v2.7.0';
const APP_SHELL = [
  './',
  './index.html',
  './manifest.json',
  './css/theme.css?v=20260720',
  './css/components.css?v=20260720',
  './css/pages.css?v=20260720'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(APP_VERSION).then((cache) => cache.addAll(APP_SHELL))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter(k => k !== APP_VERSION).map(k => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);

  // Não interceptar Firebase (deixa o SDK lidar com offline persistence)
  if (url.hostname.includes('firebase') || url.hostname.includes('firestore') || url.hostname.includes('googleapis')) {
    return;
  }

  // Apenas GET é cacheável
  if (event.request.method !== 'GET') return;

  event.respondWith(
    fetch(event.request)
      .then((response) => {
        // Cacheia respostas válidas do app shell e CDNs (jspdf, fonts)
        if (response && response.status === 200 && (response.type === 'basic' || response.type === 'cors')) {
          const clone = response.clone();
          caches.open(APP_VERSION).then((cache) => cache.put(event.request, clone));
        }
        return response;
      })
      .catch(() => caches.match(event.request).then((cached) => cached || caches.match('./index.html')))
  );
});
