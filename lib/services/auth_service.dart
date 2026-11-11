import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final bool isDemo;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.isDemo = false,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'isDemo': isDemo,
      };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        uid: map['uid'] as String? ?? '',
        email: map['email'] as String? ?? '',
        displayName: map['displayName'] as String? ?? '',
        isDemo: map['isDemo'] as bool? ?? false,
      );
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  FirebaseAuth? _auth;
  bool _isFirebaseAvailable = false;

  final _userController = StreamController<AppUser?>.broadcast();
  Stream<AppUser?> get authStateChanges => _userController.stream;

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  bool get isFirebaseActive => _isFirebaseAvailable;

  Future<void> init() async {
    try {
      _auth = FirebaseAuth.instance;
      _isFirebaseAvailable = true;

      _auth!.authStateChanges().listen((User? fbUser) {
        if (fbUser != null) {
          _currentUser = AppUser(
            uid: fbUser.uid,
            email: fbUser.email ?? '',
            displayName: fbUser.displayName ?? fbUser.email?.split('@').first ?? 'Athlete',
            isDemo: false,
          );
        } else {
          // If we had a demo user logged in, preserve it unless explicitly logged out
          if (_currentUser != null && !_currentUser!.isDemo) {
            _currentUser = null;
          }
        }
        _userController.add(_currentUser);
      });
    } catch (e) {
      debugPrint("Firebase Auth not initialized or operating in offline/demo mode: $e");
      _isFirebaseAvailable = false;
      await _loadLocalUser();
    }
  }

  Future<void> _loadLocalUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loggedIn = prefs.getBool('demo_logged_in') ?? false;
      if (loggedIn) {
        final email = prefs.getString('demo_email') ?? 'athlete@gymtracker.app';
        final username = prefs.getString('demo_username') ?? 'Athlete';
        final uid = prefs.getString('demo_uid') ?? 'local-demo-uid-001';
        _currentUser = AppUser(
          uid: uid,
          email: email,
          displayName: username,
          isDemo: true,
        );
        _userController.add(_currentUser);
      } else {
        _currentUser = null;
        _userController.add(null);
      }
    } catch (e) {
      debugPrint("Error loading local user: $e");
    }
  }

  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();
    if (_isFirebaseAvailable && _auth != null) {
      try {
        final credential = await _auth!.signInWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
        final fbUser = credential.user!;
        final user = AppUser(
          uid: fbUser.uid,
          email: fbUser.email ?? cleanEmail,
          displayName: fbUser.displayName ?? cleanEmail.split('@').first,
          isDemo: false,
        );
        _currentUser = user;
        _userController.add(user);
        return user;
      } on FirebaseAuthException catch (e) {
        debugPrint("FirebaseAuthException: ${e.code} - ${e.message}");
        rethrow;
      } catch (e) {
        debugPrint("Firebase sign-in error, falling back to local session: $e");
      }
    }

    // Local / Offline demo authentication fallback
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('demo_user_${cleanEmail}_pwd');
    if (savedPassword != null && savedPassword != password) {
      throw FirebaseAuthException(
        code: 'wrong-password',
        message: 'Invalid password. Please check your credentials.',
      );
    }

    final username = prefs.getString('demo_user_${cleanEmail}_name') ?? cleanEmail.split('@').first;
    final user = AppUser(
      uid: 'user_${cleanEmail.hashCode.abs()}',
      email: cleanEmail,
      displayName: username.isNotEmpty ? username : 'Athlete',
      isDemo: true,
    );
    await prefs.setBool('demo_logged_in', true);
    await prefs.setString('demo_email', cleanEmail);
    await prefs.setString('demo_username', user.displayName);
    await prefs.setString('demo_uid', user.uid);

    _currentUser = user;
    _userController.add(user);
    return user;
  }

  Future<AppUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    final cleanEmail = email.trim();
    final cleanUsername = username.trim().isEmpty ? cleanEmail.split('@').first : username.trim();

    if (_isFirebaseAvailable && _auth != null) {
      try {
        final credential = await _auth!.createUserWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
        final fbUser = credential.user!;
        await fbUser.updateDisplayName(cleanUsername);

        final user = AppUser(
          uid: fbUser.uid,
          email: fbUser.email ?? cleanEmail,
          displayName: cleanUsername,
          isDemo: false,
        );
        _currentUser = user;
        _userController.add(user);
        return user;
      } on FirebaseAuthException catch (e) {
        debugPrint("FirebaseAuthException: ${e.code} - ${e.message}");
        rethrow;
      } catch (e) {
        debugPrint("Firebase sign-up error, falling back to local storage: $e");
      }
    }

    // Local Demo Signup
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('demo_user_${cleanEmail}_pwd', password);
    await prefs.setString('demo_user_${cleanEmail}_name', cleanUsername);
    await prefs.setBool('demo_logged_in', true);
    await prefs.setString('demo_email', cleanEmail);
    await prefs.setString('demo_username', cleanUsername);
    final uid = 'user_${cleanEmail.hashCode.abs()}';
    await prefs.setString('demo_uid', uid);

    final user = AppUser(
      uid: uid,
      email: cleanEmail,
      displayName: cleanUsername,
      isDemo: true,
    );
    _currentUser = user;
    _userController.add(user);
    return user;
  }

  Future<void> signOut() async {
    if (_isFirebaseAvailable && _auth != null) {
      try {
        await _auth!.signOut();
      } catch (e) {
        debugPrint("Sign out error from Firebase: $e");
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('demo_logged_in', false);

    _currentUser = null;
    _userController.add(null);
  }
}
