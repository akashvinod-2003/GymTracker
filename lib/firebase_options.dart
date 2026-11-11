// File configured for gymtrack-2026 Firebase Project.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD4Rd84KPXctsMd2yGszywmjAL8upMpwhc',
    appId: '1:435374150985:web:15fa34196d73248730f698',
    messagingSenderId: '435374150985',
    projectId: 'gymtrack-2026',
    authDomain: 'gymtrack-2026.firebaseapp.com',
    storageBucket: 'gymtrack-2026.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD4Rd84KPXctsMd2yGszywmjAL8upMpwhc',
    appId: '1:435374150985:web:15fa34196d73248730f698',
    messagingSenderId: '435374150985',
    projectId: 'gymtrack-2026',
    storageBucket: 'gymtrack-2026.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD4Rd84KPXctsMd2yGszywmjAL8upMpwhc',
    appId: '1:435374150985:web:15fa34196d73248730f698',
    messagingSenderId: '435374150985',
    projectId: 'gymtrack-2026',
    storageBucket: 'gymtrack-2026.firebasestorage.app',
    iosBundleId: 'com.gymtracker.gymTracker',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD4Rd84KPXctsMd2yGszywmjAL8upMpwhc',
    appId: '1:435374150985:web:15fa34196d73248730f698',
    messagingSenderId: '435374150985',
    projectId: 'gymtrack-2026',
    storageBucket: 'gymtrack-2026.firebasestorage.app',
    iosBundleId: 'com.gymtracker.gymTracker',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD4Rd84KPXctsMd2yGszywmjAL8upMpwhc',
    appId: '1:435374150985:web:15fa34196d73248730f698',
    messagingSenderId: '435374150985',
    projectId: 'gymtrack-2026',
    authDomain: 'gymtrack-2026.firebaseapp.com',
    storageBucket: 'gymtrack-2026.firebasestorage.app',
  );
}
