import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  static const _keyName     = 'auth_name';
  static const _keyEmail    = 'auth_email';
  static const _keyPassword = 'auth_password';
  static const _keyLoggedIn = 'auth_logged_in';

  String? _name;
  String? _email;
  bool _loggedIn = false;

  String? get name      => _name;
  String? get email     => _email;
  bool   get isLoggedIn => _loggedIn;

  String get initials {
    if (_name == null || _name!.isEmpty) return '?';
    final parts = _name!.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return _name![0].toUpperCase();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _loggedIn = prefs.getBool(_keyLoggedIn) ?? false;
    _name     = prefs.getString(_keyName);
    _email    = prefs.getString(_keyEmail);
    notifyListeners();
  }

  // Returns null on success, error message on failure
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().isEmpty)     return 'Please enter your name.';
    if (!email.contains('@'))    return 'Enter a valid email address.';
    if (password.length < 6)     return 'Password must be at least 6 characters.';

    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_keyEmail);
    if (existing != null && existing == email.toLowerCase().trim()) {
      return 'An account with this email already exists.';
    }

    await prefs.setString(_keyName,     name.trim());
    await prefs.setString(_keyEmail,    email.toLowerCase().trim());
    await prefs.setString(_keyPassword, _hash(password));
    await prefs.setBool  (_keyLoggedIn, true);

    _name     = name.trim();
    _email    = email.toLowerCase().trim();
    _loggedIn = true;
    notifyListeners();
    return null;
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString(_keyEmail);
    final storedHash  = prefs.getString(_keyPassword);

    if (storedEmail == null || storedHash == null) {
      return 'No account found. Please sign up first.';
    }
    if (storedEmail != email.toLowerCase().trim()) {
      return 'Incorrect email or password.';
    }
    if (storedHash != _hash(password)) {
      return 'Incorrect email or password.';
    }

    await prefs.setBool(_keyLoggedIn, true);
    _name     = prefs.getString(_keyName);
    _email    = storedEmail;
    _loggedIn = true;
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, false);
    _loggedIn = false;
    notifyListeners();
  }

  Future<String?> updateProfile({required String name, required String email}) async {
    if (name.trim().isEmpty)  return 'Name cannot be empty.';
    if (!email.contains('@')) return 'Enter a valid email address.';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName,  name.trim());
    await prefs.setString(_keyEmail, email.toLowerCase().trim());
    _name  = name.trim();
    _email = email.toLowerCase().trim();
    notifyListeners();
    return null;
  }

  // Simple deterministic hash (local-only auth, not security-critical)
  static String _hash(String input) {
    var h = 5381;
    for (final c in input.codeUnits) {
      h = ((h << 5) + h + c) & 0xFFFFFFFF;
    }
    return h.toRadixString(16);
  }
}
