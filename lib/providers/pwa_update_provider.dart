import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/pwa_update_bridge.dart';

class PwaUpdateProvider extends ChangeNotifier {
  bool _isUpdateAvailable = false;
  bool _isUpdating = false;
  Timer? _pollingTimer;

  bool get isUpdateAvailable => _isUpdateAvailable;
  bool get isUpdating => _isUpdating;

  PwaUpdateProvider() {
    _init();
  }

  void _init() {
    // 1. Initial check
    _checkAvailability();

    // 2. Set up event listener on Web
    setupWebUpdateListener(() {
      if (!_isUpdateAvailable) {
        _isUpdateAvailable = true;
        notifyListeners();
      }
    });

    // 3. Periodic check every 15 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _checkAvailability();
    });
  }

  void _checkAvailability() {
    final available = isWebUpdateAvailable();
    if (available != _isUpdateAvailable) {
      _isUpdateAvailable = available;
      notifyListeners();
    }
  }

  Future<void> applyUpdate() async {
    if (_isUpdating) return;
    _isUpdating = true;
    notifyListeners();

    // Trigger manual update in service worker and reload
    triggerWebUpdate();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
