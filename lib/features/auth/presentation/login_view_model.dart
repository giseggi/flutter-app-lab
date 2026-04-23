import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/local_storage.dart';
import '../data/auth_api.dart';
import '../data/auth_repository_impl.dart';
import '../domain/auth_repository.dart';
import 'login_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = AuthApi(dioClient);
  final storage = LocalStorage();
  return AuthRepositoryImpl(api, storage);
});

final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, LoginState>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      return LoginViewModel(repository);
    });

class LoginViewModel extends StateNotifier<LoginState> {
  LoginViewModel(this._authRepository) : super(const LoginState());

  final AuthRepository _authRepository;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final session = await _authRepository.login(
        email: email,
        password: password,
      );
      state = state.copyWith(isLoading: false, token: session.token);
    } on DioException catch (e) {
      final message =
          e.response?.data is Map<String, dynamic>
              ? (e.response?.data['error'] as String? ?? '로그인 요청 실패')
              : '로그인 요청 실패';
      state = state.copyWith(isLoading: false, errorMessage: message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
