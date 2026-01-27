// Service Worker for EHSO Kursportal PWA
const CACHE_NAME = 'ehso-kursportal-v1';
const OFFLINE_URL = '/offline.html';

// Static assets to cache on install
const STATIC_ASSETS = [
    '/',
    '/offline.html',
    '/icon-192.png',
    '/icon-512.png',
    '/manifest.json'
];

// Install event - cache static assets
self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(CACHE_NAME).then((cache) => {
            console.log('[SW] Caching static assets');
            return cache.addAll(STATIC_ASSETS);
        })
    );
    self.skipWaiting();
});

// Activate event - clean old caches
self.addEventListener('activate', (event) => {
    event.waitUntil(
        caches.keys().then((cacheNames) => {
            return Promise.all(
                cacheNames
                    .filter((name) => name !== CACHE_NAME)
                    .map((name) => caches.delete(name))
            );
        })
    );
    self.clients.claim();
});

// Fetch event - network first, fallback to cache
self.addEventListener('fetch', (event) => {
    const { request } = event;
    const url = new URL(request.url);

    // Skip non-GET requests
    if (request.method !== 'GET') return;

    // Skip API requests and auth
    if (url.pathname.startsWith('/api') ||
        url.pathname.includes('supabase') ||
        url.pathname.includes('auth')) {
        return;
    }

    // Handle lesson pages - cache for offline reading
    if (url.pathname.includes('/learn/')) {
        event.respondWith(
            caches.open(CACHE_NAME).then(async (cache) => {
                try {
                    const networkResponse = await fetch(request);
                    // Cache successful lesson responses
                    if (networkResponse.ok) {
                        cache.put(request, networkResponse.clone());
                    }
                    return networkResponse;
                } catch (error) {
                    // Try cache first
                    const cachedResponse = await cache.match(request);
                    if (cachedResponse) {
                        return cachedResponse;
                    }
                    // Fallback to offline page
                    return cache.match(OFFLINE_URL);
                }
            })
        );
        return;
    }

    // Handle navigation requests
    if (request.mode === 'navigate') {
        event.respondWith(
            fetch(request).catch(() => {
                return caches.match(OFFLINE_URL);
            })
        );
        return;
    }

    // Handle static assets - cache first
    if (url.pathname.match(/\.(js|css|png|jpg|jpeg|svg|woff2?)$/)) {
        event.respondWith(
            caches.match(request).then((cachedResponse) => {
                if (cachedResponse) {
                    return cachedResponse;
                }
                return fetch(request).then((response) => {
                    if (response.ok) {
                        const responseClone = response.clone();
                        caches.open(CACHE_NAME).then((cache) => {
                            cache.put(request, responseClone);
                        });
                    }
                    return response;
                });
            })
        );
        return;
    }
});

// Message handler for manual cache operations
self.addEventListener('message', (event) => {
    if (event.data.type === 'CACHE_LESSON') {
        const { url } = event.data;
        caches.open(CACHE_NAME).then((cache) => {
            fetch(url).then((response) => {
                if (response.ok) {
                    cache.put(url, response);
                    console.log('[SW] Cached lesson:', url);
                }
            });
        });
    }

    if (event.data.type === 'CLEAR_CACHE') {
        caches.delete(CACHE_NAME).then(() => {
            console.log('[SW] Cache cleared');
        });
    }
});
