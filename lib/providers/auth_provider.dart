import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  User? _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Kullanıcı bilgileri
  String? get userId => _user?.id;
  String? get userEmail => _user?.email;
  User? get currentUser => _user;

  // Kullanıcı admin mi?
  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  AuthProvider() {
    _user = _supabase.auth.currentUser;

    // Oturum dinlemesi
    _supabase.auth.onAuthStateChange.listen((event) {
      _user = _supabase.auth.currentUser;
      notifyListeners();
    });
  }

  /// Admin kontrolü
  Future<bool> checkIfAdmin(String email) async {
    final result = await _supabase
        .from('admins')
        .select()
        .eq('email', email)
        .maybeSingle();
    return result != null;
  }

  /// Giriş yap + admin kontrolü + yönlendirme
  Future<void> signIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _user = response.user;

      if (_user != null) {
        _isAdmin = await checkIfAdmin(email);

        if (context.mounted) {
          if (_isAdmin) {
            Navigator.pushReplacementNamed(context, '/admin_dashboard');
          } else {
            Navigator.pushReplacementNamed(context, '/personel_dashboard');
          }
        }
      }
    } on AuthException catch (e) {
      throw Exception('Giriş başarısız: ${e.message}');
    } catch (e) {
      throw Exception('Bilinmeyen hata: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// login() kısa adı
  Future<void> login(String email, String password, BuildContext context) =>
      signIn(email: email, password: password, context: context);

  /// Çıkış yap
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _user = null;
      _isAdmin = false;
      notifyListeners();
    } catch (e) {
      throw Exception('Çıkış yapılamadı: $e');
    }
  }

  /// logout() kısa adı
  Future<void> logout() => signOut();
}
