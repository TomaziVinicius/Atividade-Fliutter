import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final _supabase = Supabase.instance.client;

  static Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  static Session? get currentSession => _supabase.auth.currentSession;

  static Future<AuthResponse> signIn(String email, String senha) async{
    return await _supabase.auth.signInWithPassword(email: email, password: senha,);
  }

  static Future<AuthResponse> signUp(String email, String senha) async {
    return await _supabase.auth.signUp(email: email, password: senha,);
  }

  static Future<void> signOut() async => await _supabase.auth.signOut();
}