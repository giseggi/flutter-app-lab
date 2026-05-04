import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  const SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  bool get isConfigured => true;

  @override
  bool get isSignedIn => _client.auth.currentSession != null;

  @override
  Stream<bool> get sessionChanges =>
      _client.auth.onAuthStateChange.map((event) => event.session != null);

  @override
  Future<void> sendMagicLink(String email) {
    return _client.auth.signInWithOtp(email: email);
  }

  @override
  Future<void> signOut() {
    return _client.auth.signOut();
  }
}

class DisabledAuthRepository implements AuthRepository {
  const DisabledAuthRepository();

  @override
  bool get isConfigured => false;

  @override
  bool get isSignedIn => false;

  @override
  Stream<bool> get sessionChanges => const Stream<bool>.empty();

  @override
  Future<void> sendMagicLink(String email) {
    throw StateError('Supabase is not configured.');
  }

  @override
  Future<void> signOut() async {}
}
