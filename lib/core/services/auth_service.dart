import 'dart:async';
import 'app_state.dart';
import 'persistence_service.dart';

class HSUser {
  final String uid;
  final String email;
  final String? displayName;

  HSUser({required this.uid, required this.email, this.displayName});
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final PersistenceService _persistence = PersistenceService();
  final AppState _appState = AppState();

  HSUser? _currentUser;
  HSUser? get currentUser => _currentUser;

  final _authController = StreamController<HSUser?>.broadcast();
  Stream<HSUser?> get authStateChanges => _authController.stream;

  Future<void> signIn(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // For demo/mock: Always succeed if email is valid
    if (email.contains('@')) {
      _currentUser = HSUser(
        uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: _appState.myName,
      );
      await _persistence.saveObject('auth_user', {'uid': _currentUser!.uid, 'email': _currentUser!.email});
      _authController.add(_currentUser);
    } else {
      throw Exception('Geçersiz e-posta adresi.');
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    await Future.delayed(const Duration(seconds: 2));
    await _appState.setMyName(name);
    await signIn(email, password);
  }

  Future<void> signOut() async {
    _currentUser = null;
    await _persistence.saveObject('auth_user', null);
    _authController.add(null);
  }

  Future<void> checkAuth() async {
    final saved = await _persistence.getObject('auth_user');
    if (saved != null) {
      _currentUser = HSUser(
        uid: saved['uid'],
        email: saved['email'],
        displayName: _appState.myName,
      );
      _authController.add(_currentUser);
    } else {
      _authController.add(null);
    }
  }
}
