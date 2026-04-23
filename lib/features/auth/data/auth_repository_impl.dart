import '../../../core/storage/local_storage.dart';
import '../domain/auth_repository.dart';
import '../domain/models/user_session.dart';
import 'auth_api.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._authApi, this._localStorage);

  final AuthApi _authApi;
  final LocalStorage _localStorage;

  @override
  Future<UserSession> login({
    required String email,
    required String password,
  }) async {
    final token = await _authApi.login(email: email, password: password);
    await _localStorage.saveToken(token);
    return UserSession(token: token);
  }
}
