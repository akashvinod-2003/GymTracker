/**
 * PulseFit PWA Manual Update Manager
 * Detects newly deployed application versions and notifies the app without auto-reloading.
 * The application is only updated and refreshed when the user explicitly triggers "Update App".
 */
(function () {
  'use strict';

  if (!('serviceWorker' in navigator)) {
    console.log('[PWA Update] Service workers not supported by this browser.');
    return;
  }

  let swRegistration = null;
  let waitingWorker = null;
  let updateAvailable = false;
  let isUpdating = false;
  let initialVersionData = null;
  let initialBundleHash = null;

  window.__PWA_UPDATE_AVAILABLE__ = false;

  function markUpdateAvailable(reason, worker) {
    if (updateAvailable) return;
    updateAvailable = true;
    window.__PWA_UPDATE_AVAILABLE__ = true;
    if (worker) {
      waitingWorker = worker;
    }

    console.log(`[PWA Update] Update available detected (${reason}). Waiting for user confirmation.`);
    try {
      window.dispatchEvent(new CustomEvent('pwaUpdateAvailable', {
        detail: { reason: reason }
      }));
    } catch (e) {
      console.warn('[PWA Update] Failed to dispatch update event:', e);
    }
  }

  // Applies the pending update manually upon user request
  async function applyUpdate() {
    if (isUpdating) return;
    isUpdating = true;
    console.log('[PWA Update] Manual update initiated by user...');

    // Prevent reload loops (allow at most 1 reload per 10 seconds)
    try {
      const lastReload = parseInt(sessionStorage.getItem('pwa_last_update_ts') || '0', 10);
      if (Date.now() - lastReload < 10000) {
        console.warn('[PWA Update] Throttling rapid reload requests.');
        window.location.reload();
        return;
      }
      sessionStorage.setItem('pwa_last_update_ts', String(Date.now()));
    } catch (_) {}

    // 1. Activate waiting service worker
    try {
      if (waitingWorker) {
        waitingWorker.postMessage({ type: 'SKIP_WAITING' });
      } else if (swRegistration && swRegistration.waiting) {
        swRegistration.waiting.postMessage({ type: 'SKIP_WAITING' });
      }
    } catch (e) {
      console.warn('[PWA Update] Error sending SKIP_WAITING to service worker:', e);
    }

    // 2. Clear browser CacheStorage to ensure fresh bundles
    try {
      if ('caches' in window) {
        const keys = await caches.keys();
        await Promise.all(keys.map(k => caches.delete(k)));
      }
    } catch (e) {
      console.warn('[PWA Update] Cache deletion error:', e);
    }

    // 3. Smooth page refresh
    setTimeout(() => {
      window.location.reload();
    }, 350);
  }

  // Unregister deprecated flutter_service_worker.js if present
  navigator.serviceWorker.getRegistrations().then((registrations) => {
    for (const reg of registrations) {
      const scriptURL = (reg.active && reg.active.scriptURL) ||
                        (reg.waiting && reg.waiting.scriptURL) ||
                        (reg.installing && reg.installing.scriptURL) || '';
      if (scriptURL.includes('flutter_service_worker.js')) {
        reg.unregister();
      }
    }
  });

  // Register our custom PWA Service Worker
  function registerServiceWorker() {
    const buildHash = window.__PULSEFIT_BUILD_HASH__ || '';
    const swPath = 'sw.js' + (buildHash ? '?v=' + encodeURIComponent(buildHash) : '');

    navigator.serviceWorker
      .register(swPath, { updateViaCache: 'none' })
      .then((reg) => {
        swRegistration = reg;
        console.log('[PWA Update] Service worker registered. Scope:', reg.scope);

        // Check if a worker is already waiting in background
        if (reg.waiting) {
          markUpdateAvailable('Existing waiting worker found', reg.waiting);
        }

        // Check for updates
        reg.update().catch(() => {});

        // Listen for new worker installed
        reg.addEventListener('updatefound', () => {
          const installingWorker = reg.installing;
          if (!installingWorker) return;

          installingWorker.addEventListener('statechange', () => {
            if (installingWorker.state === 'installed' && navigator.serviceWorker.controller) {
              markUpdateAvailable('New service worker installed in background', installingWorker);
            }
          });
        });

        // Periodic background update check every 5 minutes
        setInterval(() => {
          reg.update().catch(() => {});
        }, 5 * 60 * 1000);

        // Check when tab regains visibility
        document.addEventListener('visibilitychange', () => {
          if (document.visibilityState === 'visible') {
            reg.update().catch(() => {});
            checkServerDeployment();
          }
        });
      })
      .catch((err) => {
        console.warn('[PWA Update] Service worker registration error:', err);
      });
  }

  // Server-Side Deployment Check (Checks version.json and main.dart bundle)
  async function checkServerDeployment() {
    if (updateAvailable) return;
    try {
      // Check 1: version.json
      const vRes = await fetch('version.json?_t=' + Date.now(), { cache: 'no-store' });
      if (vRes.ok) {
        const vData = await vRes.json();
        const vKey = `${vData.version}+${vData.build_number}`;
        if (!initialVersionData) {
          initialVersionData = vKey;
        } else if (initialVersionData !== vKey) {
          markUpdateAvailable(`version.json updated (${initialVersionData} -> ${vKey})`, null);
          return;
        }
      }

      // Check 2: main.dart bundle HEAD check
      const headRes = await fetch('main.dart.js?_t=' + Date.now(), { method: 'HEAD', cache: 'no-store' });
      if (headRes.ok) {
        const etag = headRes.headers.get('ETag') ||
                     headRes.headers.get('Last-Modified') ||
                     headRes.headers.get('Content-Length');
        if (etag) {
          if (!initialBundleHash) {
            initialBundleHash = etag;
          } else if (initialBundleHash !== etag) {
            markUpdateAvailable('main bundle changed on server', null);
            return;
          }
        }
      }
    } catch (_) {
      // Offline - ignored
    }
  }

  // Periodic server check: initial after 4s, then every 2 minutes
  setTimeout(checkServerDeployment, 4000);
  setInterval(checkServerDeployment, 120 * 1000);

  // Global API exposed to Flutter Web
  window.pwaUpdater = {
    isUpdateAvailable: () => updateAvailable || !!window.__PWA_UPDATE_AVAILABLE__,
    isUpdating: () => isUpdating,
    applyUpdate: applyUpdate,
    checkForUpdate: () => {
      if (swRegistration) swRegistration.update().catch(() => {});
      checkServerDeployment();
    }
  };

  if (document.readyState === 'complete') {
    registerServiceWorker();
  } else {
    window.addEventListener('load', registerServiceWorker);
  }
})();
