import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServiceException implements Exception {
  final String message;
  AuthServiceException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final SupabaseClient _supabase;

  AuthService() : _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> registerAdmin({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await _supabase.auth.signUp(
        email: email.trim(),
        password: password.trim(),
      );

      if (authResponse.user == null) {
        throw AuthServiceException('Auth kaydı başarısız');
      }

      return {
        'user_id': authResponse.user!.id,
        'email': email,
      };
    } on PostgrestException catch (e) {
      throw AuthServiceException('Veritabanı hatası: ${e.message} (Kod: ${e.code})');
    } catch (e) {
      throw AuthServiceException('Kayıt sırasında hata: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> adminGiris({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (response.user == null) {
        throw AuthServiceException('Kullanıcı bulunamadı');
      }

      return {
        'user_id': response.user!.id,
        'email': response.user!.email,
        'access_token': response.session?.accessToken,
      };
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw AuthServiceException('Veritabanı hatası: Kullanıcı kaydı tutarsız');
      }
      throw AuthServiceException('Veritabanı hatası: ${e.message}');
    } catch (e) {
      throw AuthServiceException('Giriş başarısız: ${e.toString()}');
    }
  }

  Future<void> cikisYap() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw AuthServiceException('Çıkış yapılırken hata oluştu: $e');
    }
  }
}