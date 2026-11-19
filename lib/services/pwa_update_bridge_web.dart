import 'dart:js_interop';
import 'package:web/web.dart' as web;

@JS('__PWA_UPDATE_AVAILABLE__')
external bool? get _pwaUpdateAvailable;

@JS('pwaUpdater.applyUpdate')
external void _applyPwaUpdate();

bool isWebUpdateAvailable() {
  try {
    return _pwaUpdateAvailable == true;
  } catch (_) {
    return false;
  }
}

bool isWebUpdating() => false;

void triggerWebUpdate() {
  try {
    _applyPwaUpdate();
  } catch (_) {
    try {
      web.window.location.reload();
    } catch (_) {}
  }
}

void setupWebUpdateListener(void Function() onUpdateAvailable) {
  try {
    web.window.addEventListener(
      'pwaUpdateAvailable',
      ((web.Event _) {
        onUpdateAvailable();
      }).toJS,
    );
  } catch (_) {}
}
