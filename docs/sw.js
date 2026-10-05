/**
 * KKTC Trafik & Radar - Service Worker (sw.js)
 * Offline Caching & PWA Support
 *
 * Strateji: Network-First (önce ağ, çevrimdışıysa önbellek).
 * Eski Cache-First stratejisi siteyi ilk sürümde "donduruyordu"; güncellemeler gelmiyordu.
 * /app/ altındaki Flutter uygulaması kendi service worker'ını yönetir, buraya karışmaz.
 */

const CACHE_NAME = 'kktc-radar-v2.5.0';
const ASSETS_TO_CACHE = [
  './',
  './index.html',
  './style.css',
  './app.js',
  './manifest.json',
  './icons/Icon-192.png',
  './icons/Icon-512.png'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      // Tek bir dosya hata verse bile kurulum başarısız olmasın
      .then((cache) => Promise.allSettled(ASSETS_TO_CACHE.map((url) => cache.add(url))))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key)))
    ).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (event) => {
  const req = event.request;
  if (req.method !== 'GET') return;

  const url = new URL(req.url);

  // Flutter uygulaması (/app/) ve büyük APK dosyası bu SW tarafından yönetilmez
  if (url.origin === self.location.origin &&
      (url.pathname.includes('/app/') || url.pathname.endsWith('.apk'))) {
    return;
  }

  event.respondWith(
    fetch(req)
      .then((res) => {
        if (res && res.status === 200 && res.type === 'basic') {
          const copy = res.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(req, copy));
        }
        return res;
      })
      .catch(() => caches.match(req).then((cached) => cached || caches.match('./index.html')))
  );
});
