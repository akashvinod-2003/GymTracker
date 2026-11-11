{{flutter_js}}
{{flutter_build_config}}

// Capture Flutter build hash to version our PWA Service Worker
try {
  window.__PULSEFIT_BUILD_HASH__ = String({{flutter_service_worker_version}});
} catch (e) {
  window.__PULSEFIT_BUILD_HASH__ = '';
}

_flutter.loader.load();
