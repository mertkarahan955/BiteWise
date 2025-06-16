import 'package:firebase_auth/firebase_auth.dart';

abstract class IFirebaseService {
  User? get currentUser;
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  });
  Future<UserCredential> signIn({
    required String email,
    required String password,
  });
  Future<void> signOut();
  bool isUserLoggedIn();
}
