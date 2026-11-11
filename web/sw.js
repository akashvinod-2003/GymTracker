/* PulseFit PWA Service Worker - Automatic Cache Busting & Updates */
const CACHE_VERSION = 'pulsefit-v5-perfect';
const CACHE_NAME = `pulsefit-cache-${CACHE_VERSION}`;

// Pre-cached assets for instant offline PWA access
const PRECACHE_ASSETS = [
  '/',
  '/index.html',
  '/manifest.json',
  '/manifest-dark.json',
  '/manifest-light.json',
  '/favicon.png',
  '/favicon_dark.png',
  '/favicon_light.png',
  '/icons/icon-dark-192.png',
  '/icons/icon-dark-512.png',
  '/icons/icon-light-192.png',
  '/icons/icon-light-512.png',
  '/icons/icon-maskable-dark-192.png',
  '/icons/icon-maskable-dark-512.png',
  '/icons/icon-maskable-light-192.png',
  '/icons/icon-maskable-light-512.png',
  '/icons/apple-touch-icon-dark.png',
  '/icons/apple-touch-icon-light.png',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
  '/icons/Icon-maskable-192.png',
  '/icons/Icon-maskable-512.png'
];

// Install: Immediately skip waiting so new service worker activates without closing tabs
self.addEventListener('install', (event) => {
  console.log('[PulseFit SW] Install event triggered. Skipping waiting...');
  self.skipWaiting();
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(PRECACHE_ASSETS).catch((err) => {
        console.warn('[PulseFit SW] Precache warning:', err);
      });
    })
  );
});

// Activate: Purge old cache versions and claim all open clients immediately
self.addEventListener('activate', (event) => {
  console.log('[PulseFit SW] Activate event triggered. Claiming clients...');
  event.waitUntil(
    (async () => {
      const cacheNames = await caches.keys();
      await Promise.all(
        cacheNames.map((name) => {
          if (name !== CACHE_NAME) {
            console.log('[PulseFit SW] Deleting obsolete cache:', name);
            return caches.delete(name);
          }
        })
      );
      // Immediately take control of all active clients/tabs
      await self.clients.claim();
      console.log('[PulseFit SW] Service worker active and control claimed.');
    })()
  );
});

// Messages: Support remote skipWaiting or cache purging from app
self.addEventListener('message', (event) => {
  if (!event.data) return;
  if (event.data.type === 'SKIP_WAITING') {
    console.log('[PulseFit SW] Received SKIP_WAITING signal');
    self.skipWaiting();
  } else if (event.data.type === 'CLEAR_CACHE') {
    console.log('[PulseFit SW] Received CLEAR_CACHE signal');
    event.waitUntil(
      caches.keys().then((keys) => Promise.all(keys.map((k) => caches.delete(k))))
    );
  }
});

// Fetch: Smart caching strategy
// 1. Never cache external APIs (Firebase, Google Fonts API, etc.)
// 2. Never cache sw.js or version.json
// 3. Network-First for HTML navigation and JS bundles (always fresh when online, fallback offline)
// 4. Stale-While-Revalidate for static media/fonts
self.addEventListener('fetch', (event) => {
  const request = event.request;
  const url = new URL(request.url);

  // Only handle GET requests from our own origin
  if (request.method !== 'GET' || url.origin !== self.location.origin) {
    return;
  }

  const pathname = url.pathname;

  // 1. Always bypass cache for version.json, sw.js, and legacy worker
  if (pathname.endsWith('version.json') || pathname.endsWith('sw.js') || pathname.includes('flutter_service_worker')) {
    event.respondWith(fetch(request, { cache: 'no-store' }));
    return;
  }

  // 2. HTML / Navigation requests: Network-First with Cache fallback
  if (request.mode === 'navigate' || pathname.endsWith('.html') || pathname === '/') {
    event.respondWith(
      fetch(request)
        .then((response) => {
          if (response && response.status === 200) {
            const clone = response.clone();
            caches.open(CACHE_NAME).then((cache) => cache.put(request, clone));
          }
          return response;
        })
        .catch(async () => {
          const cached = await caches.match(request);
          if (cached) return cached;
          return caches.match('/index.html');
        })
    );
    return;
  }

  // 3. Flutter Core Bundles (main.dart.js, flutter_bootstrap.js, flutter.js):
  // Network-First with Cache fallback so updates load immediately
  if (pathname.endsWith('main.dart.js') || pathname.endsWith('flutter_bootstrap.js') || pathname.endsWith('flutter.js')) {
    event.respondWith(
      fetch(request)
        .then((response) => {
          if (response && response.status === 200) {
            const clone = response.clone();
            caches.open(CACHE_NAME).then((cache) => cache.put(request, clone));
          }
          return response;
        })
        .catch(() => caches.match(request))
    );
    return;
  }

  // 4. Static assets (canvaskit, icons, images, fonts):
  // Stale-While-Revalidate (instant load from cache + background revalidation)
  event.respondWith(
    caches.match(request).then((cachedResponse) => {
      const fetchPromise = fetch(request)
        .then((networkResponse) => {
          if (networkResponse && networkResponse.status === 200) {
            const clone = networkResponse.clone();
            caches.open(CACHE_NAME).then((cache) => cache.put(request, clone));
          }
          return networkResponse;
        })
        .catch(() => cachedResponse);

      return cachedResponse || fetchPromise;
    })
  );
});
