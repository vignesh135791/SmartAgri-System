import 'package:flutter/foundation.dart';

import '../services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._apiClient);

  final ApiClient _apiClient;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isAuthenticated => _apiClient.isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _run(() => _apiClient.login(email: email, password: password));
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _run(() => _apiClient.register(
          name: name,
          email: email,
          password: password,
        ));
  }

  void logout() {
    _apiClient.clearAccessToken();
    notifyListeners();
  }

  Future<void> _run(Future<String> Function() operation) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await operation();
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
