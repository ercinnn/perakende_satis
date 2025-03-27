import 'package:supabase/supabase.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class AuthService {
  final SupabaseClient supabase;

  AuthService(this.supabase);

  Future<Map<String, dynamic>> adminGiris(String email, String sifre) async {
    try {
      // 1. Email ile admin kontrolü
      final adminResponse = await supabase
          .from('adminler')
          .select('id, firma_id')
          .eq('email', email)
          .single();

      // 2. Şifre doğrulama
      final authResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: sifre,
      );

      if (authResponse.user == null) {
        throw AuthException('Geçersiz şifre');
      }

      return {
        'firma_id': adminResponse.data['firma_id'],
        'user_id': adminResponse.data['id'],
      };
    } on PostgrestException catch (e) {
      throw AuthException('Admin bulunamadı');
    } catch (e) {
      throw AuthException('Giriş başarısız');
    }
  }

  Future<Map<String, dynamic>> personelGiris(
    String email, 
    String personelKodu, 
    String sifre,
  ) async {
    try {
      // 1. Email ile firma bul
      final firmaResponse = await supabase
          .from('adminler')
          .select('firma_id')
          .eq('email', email)
          .single();

      // 2. Personel giriş kontrolü
      final personelResponse = await supabase.rpc('personel_giris_kontrol', params: {
        'p_firma_id': firmaResponse.data['firma_id'],
        'p_personel_kodu': personelKodu,
        'p_sifre': sifre,
      });

      return {
        'firma_id': firmaResponse.data['firma_id'],
        'user_id': personelResponse.data['personel_id'],
      };
    } on PostgrestException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException('Personel girişi başarısız');
    }
  }
}