class LoginState {
  const LoginState({
    this.isLoading = false,
    this.errorMessage,
    this.token,
  });

  final bool isLoading;
  final String? errorMessage;
  final String? token;

  LoginState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? token,
    bool clearError = false,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      token: token ?? this.token,
    );
  }
}
