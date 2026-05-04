import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../data/supabase_auth_repository.dart';
import '../domain/auth_repository.dart';
import '../domain/company_email_validator.dart';

final companyEmailValidatorProvider = Provider<CompanyEmailValidator>(
  (_) => const CompanyEmailValidator(),
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return const DisabledAuthRepository();
  return SupabaseAuthRepository(client);
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthUiState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final validator = ref.watch(companyEmailValidatorProvider);
  return AuthController(repository, validator)..start();
});

class AuthUiState {
  const AuthUiState({
    required this.isConfigured,
    required this.isAuthenticated,
    this.isLoading = false,
    this.sentToEmail,
    this.errorMessage,
  });

  final bool isConfigured;
  final bool isAuthenticated;
  final bool isLoading;
  final String? sentToEmail;
  final String? errorMessage;

  AuthUiState copyWith({
    bool? isConfigured,
    bool? isAuthenticated,
    bool? isLoading,
    String? sentToEmail,
    String? errorMessage,
    bool clearSentEmail = false,
    bool clearError = false,
  }) {
    return AuthUiState(
      isConfigured: isConfigured ?? this.isConfigured,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      sentToEmail: clearSentEmail ? null : (sentToEmail ?? this.sentToEmail),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthController extends StateNotifier<AuthUiState> {
  AuthController(AuthRepository repository, this._validator)
      : _repository = repository,
        super(
          AuthUiState(
            isConfigured: repository.isConfigured,
            isAuthenticated: repository.isSignedIn,
          ),
        );

  final AuthRepository _repository;
  final CompanyEmailValidator _validator;
  StreamSubscription<bool>? _subscription;

  void start() {
    _subscription = _repository.sessionChanges.listen((isSignedIn) {
      state = state.copyWith(isAuthenticated: isSignedIn);
    });
  }

  Future<void> sendMagicLink(String email) async {
    final validation = _validator.validate(email);
    if (!validation.isValid) {
      state = state.copyWith(
        errorMessage: validation.errorMessage,
        clearSentEmail: true,
      );
      return;
    }

    if (!_repository.isConfigured) {
      state = state.copyWith(
        errorMessage: 'Supabase設定を追加してください',
        clearSentEmail: true,
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.sendMagicLink(email.trim().toLowerCase());
      state = state.copyWith(
        isLoading: false,
        sentToEmail: email.trim().toLowerCase(),
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '認証メールを送信できませんでした',
      );
    }
  }

  Future<void> signOut() => _repository.signOut();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
