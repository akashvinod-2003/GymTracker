/**
 * PulseFit PWA Automatic Update & Cache Invalidation Manager
 * Ensures users automatically receive newly deployed builds without manually clearing cache.
 */
(function () {
  'use strict';

  if (!('serviceWorker' in navigator)) {
    console.log('[PWA Update] Service workers not supported by this browser.');
    return;
  }

  let isRefreshing = false;
  let initialVersionData = null;
  let initialBundleHash = null;

  // Show a smooth toast notification before refreshing
  function showUpdateNotification(message) {
    if (document.getElementById('pwa-update-toast')) return;

    const toast = document.createElement('div');
    toast.id = 'pwa-update-toast';
    toast.innerHTML = `
      <div style="
        position: fixed;
        bottom: 28px;
        left: 50%;
        transform: translateX(-50%);
        background: #0B1329;
        color: #F8FAFC;
        border: 1px solid #0D9488;
        box-shadow: 0 10px 25px -5px rgba(13, 148, 136, 0.4), 0 8px 10px -6px rgba(0, 0, 0, 0.6);
        padding: 12px 22px;
        border-radius: 9999px;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
        font-size: 13.5px;
        font-weight: 600;
        letter-spacing: 0.3px;
        display: flex;
        align-items: center;
        gap: 10px;
        z-index: 999999;
        animation: pwaSlideUp 0.35s cubic-bezier(0.16, 1, 0.3, 1);
        pointer-events: none;
      ">
        <svg style="width: 18px; height: 18px; color: #14B8A6; animation: pwaSpin 0.9s linear infinite; flex-shrink: 0;" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
        </svg>
        <span>${message || 'New update found! Refreshing PulseFit...'}</span>
      </div>
      <style>
        @keyframes pwaSlideUp {
          from { opacity: 0; transform: translate(-50%, 20px) scale(0.95); }
          to { opacity: 1; transform: translate(-50%, 0) scale(1); }
        }
        @keyframes pwaSpin {
          from { transform: rotate(0deg); }
          to { transform: rotate(360deg); }
        }
      </style>
    `;
    document.body.appendChild(toast);
  }

  // Reload the application cleanly
  async function triggerReload(reason) {
    if (isRefreshing) return;
    isRefreshing = true;
    console.log(`[PWA Update] Auto-refresh triggered: ${reason}`);

    showUpdateNotification('Updating PulseFit to latest version...');

    // Purge browser CacheStorage
    try {
      if ('caches' in window) {
        const keys = await caches.keys();
        await Promise.all(keys.map(k => caches.delete(k)));
      }
    } catch (e) {
      console.warn('[PWA Update] Cache purge error:', e);
    }

    setTimeout(() => {
      window.location.reload();
    }, 450);
  }

  // 1. Unregister deprecated flutter_service_worker.js if present from previous builds
  navigator.serviceWorker.getRegistrations().then((registrations) => {
    for (const reg of registrations) {
      const scriptURL = (reg.active && reg.active.scriptURL) ||
                        (reg.waiting && reg.waiting.scriptURL) ||
                        (reg.installing && reg.installing.scriptURL) || '';
      if (scriptURL.includes('flutter_service_worker.js')) {
        console.log('[PWA Update] Unregistering obsolete Flutter service worker:', scriptURL);
        reg.unregister();
      }
    }
  });

  // 2. Controller change event: when a new SW takes over, reload the app!
  navigator.serviceWorker.addEventListener('controllerchange', () => {
    triggerReload('New Service Worker activated (controllerchange)');
  });

  // 3. Register our custom PWA Service Worker
  let swRegistration = null;

  function registerServiceWorker() {
    const buildHash = window.__PULSEFIT_BUILD_HASH__ || '';
    const swPath = 'sw.js' + (buildHash ? '?v=' + encodeURIComponent(buildHash) : '');

    navigator.serviceWorker
      .register(swPath, { updateViaCache: 'none' })
      .then((reg) => {
        swRegistration = reg;
        console.log('[PWA Update] Service worker registered successfully. Scope:', reg.scope);

        // Immediate update check on startup
        reg.update();

        // Listen for updates found
        reg.addEventListener('updatefound', () => {
          const installingWorker = reg.installing;
          if (!installingWorker) return;

          installingWorker.addEventListener('statechange', () => {
            if (installingWorker.state === 'installed') {
              if (navigator.serviceWorker.controller) {
                // An older version is currently controlling, and a new one just installed
                console.log('[PWA Update] New service worker installed! Activating immediately...');
                installingWorker.postMessage({ type: 'SKIP_WAITING' });
                triggerReload('New service worker installed');
              }
            }
          });
        });

        // Periodic update check every 3 minutes
        setInterval(() => {
          reg.update();
        }, 3 * 60 * 1000);

        // Check for updates when tab gains focus or user returns to app
        window.addEventListener('focus', () => {
          reg.update();
          checkServerDeployment();
        });

        document.addEventListener('visibilitychange', () => {
          if (document.visibilityState === 'visible') {
            reg.update();
            checkServerDeployment();
          }
        });
      })
      .catch((err) => {
        console.warn('[PWA Update] Service worker registration error:', err);
      });
  }

  // 4. Server-Side Deployment Polling (Checks version.json and main.dart.js ETag)
  // Ensures that even if the SW itself didn't change, recompiled Flutter builds are caught immediately!
  async function checkServerDeployment() {
    try {
      // Check 1: version.json
      const vRes = await fetch('version.json?_t=' + Date.now(), { cache: 'no-store' });
      if (vRes.ok) {
        const vData = await vRes.json();
        const vKey = `${vData.version}+${vData.build_number}`;
        if (!initialVersionData) {
          initialVersionData = vKey;
        } else if (initialVersionData !== vKey) {
          console.log(`[PWA Update] Version changed on server: ${initialVersionData} -> ${vKey}`);
          triggerReload('version.json updated');
          return;
        }
      }

      // Check 2: main.dart.js ETag or Last-Modified
      const headRes = await fetch('main.dart.js?_t=' + Date.now(), { method: 'HEAD', cache: 'no-store' });
      if (headRes.ok) {
        const etag = headRes.headers.get('ETag') ||
                     headRes.headers.get('Last-Modified') ||
                     headRes.headers.get('Content-Length');
        if (etag) {
          if (!initialBundleHash) {
            initialBundleHash = etag;
          } else if (initialBundleHash !== etag) {
            console.log('[PWA Update] main.dart.js changed on server! Old:', initialBundleHash, 'New:', etag);
            triggerReload('main.dart.js bundle updated');
            return;
          }
        }
      }
    } catch (e) {
      // Offline or network error - ignored
    }
  }

  // Start server check: initial after 3 seconds, then every 90 seconds
  setTimeout(checkServerDeployment, 3000);
  setInterval(checkServerDeployment, 90 * 1000);

  // Expose global debug API
  window.pwaUpdater = {
    checkForUpdate: () => {
      if (swRegistration) swRegistration.update();
      checkServerDeployment();
    },
    forceReload: () => triggerReload('Manual trigger'),
    clearCacheAndReload: async () => {
      if (window.caches) {
        const keys = await caches.keys();
        await Promise.all(keys.map(k => caches.delete(k)));
      }
      window.location.reload();
    }
  };

  // Run registration when page loads
  if (document.readyState === 'complete') {
    registerServiceWorker();
  } else {
    window.addEventListener('load', registerServiceWorker);
  }
})();
