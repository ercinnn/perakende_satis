import 'package:supabase/supabase.dart';

class KategoriEslesmeService {
  final SupabaseClient supabase;
  final String firmaId;

  KategoriEslesmeService(this.supabase, this.firmaId);

  Future<List<Map<String, dynamic>>> getKategoriOnerileri(String urunAdi) async {
    final anahtarKelimeler = urunAdi.toLowerCase().split(' ');
    
    final response = await supabase
      .from('kategori_eslesmeleri')
      .select()
      .eq('firma_id', firmaId)
      .in_('anahtar_kelime', anahtarKelimeler)
      .order('kullanilma_sayisi', ascending: false);
    
    return response.data ?? [];
  }

  Future<void> kategoriSeciminiKaydet({
    required String anahtarKelime,
    required String anaKategori,
    required String altKategori,
  }) async {
    // Var olan kaydı güncelle veya yeni oluştur
    await supabase.rpc('kategori_eslesmesi_kaydet', params: {
      'p_firma_id': firmaId,
      'p_anahtar_kelime': anahtarKelime,
      'p_ana_kategori': anaKategori,
      'p_alt_kategori': altKategori,
    });
  }
}