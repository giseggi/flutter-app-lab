abstract class AuthRepository {
  bool get isConfigured;
  bool get isSignedIn;
  Stream<bool> get sessionChanges;

  Future<void> sendMagicLink(String email);
  Future<void> signOut();
}
