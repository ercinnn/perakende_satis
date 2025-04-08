import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class UrunProvider with ChangeNotifier {
  final SupabaseClient supabaseClient;
  List<Urun> urunler = [];
  bool isLoading = false;

  UrunProvider({required this.supabaseClient});

  Future<void> loadUrunler() async {
    isLoading = true;
    notifyListeners();

    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı girişi yapılmamış');

      final adminResponse = await supabaseClient
          .from('adminler')
          .select('firma_id')
          .eq('id', userId)
          .single();

      final firmaId = adminResponse['firma_id'] as String?;
      if (firmaId == null) throw Exception('Firma bilgisi bulunamadı');

      final response = await supabaseClient
          .from('urunler')
          .select()
          .eq('firma_id', firmaId);

      urunler = (response as List)
          .map((item) => Urun.fromMap(item))
          .toList();
    } catch (e) {
      debugPrint('\u00dc\u00fcr\u00fcnler y\u00fcklenirken hata: \$e');
      throw Exception('\u00dc\u00fcr\u00fcnler y\u00fcklenemedi: \${e.toString()}');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> urunEkle(Urun urun) async {
    try {
      await supabaseClient.from('urunler').insert(urun.toMap());
      await loadUrunler();
    } catch (e) {
      debugPrint('\u00dc\u00fcr\u00fcn eklenirken hata: \$e');
      throw Exception('\u00dc\u00fcr\u00fcn eklenemedi: \${e.toString()}');
    }
  }

  Future<void> urunGuncelle(Urun urun) async {
    try {
      await supabaseClient
          .from('urunler')
          .update(urun.toMap())
          .eq('id', urun.id!);
      await loadUrunler();
    } catch (e) {
      debugPrint('\u00dc\u00fcr\u00fcn g\u00fcncellenirken hata: \$e');
      throw Exception('\u00dc\u00fcr\u00fcn g\u00fcncellenemedi: \${e.toString()}');
    }
  }

  Future<void> urunSil(String id) async {
    try {
      await supabaseClient.from('urunler').delete().eq('id', id);
      await loadUrunler();
    } catch (e) {
      debugPrint('\u00dc\u00fcr\u00fcn silinirken hata: \$e');
      throw Exception('\u00dc\u00fcr\u00fcn silinemedi: \${e.toString()}');
    }
  }

  Future<Urun?> barkodlaUrunBul(String barkod) async {
    try {
      final response = await supabaseClient
          .from('urunler')
          .select()
          .eq('barkod', barkod)
          .eq('firma_id', supabaseClient.auth.currentUser!.id)
          .maybeSingle();

      if (response != null) {
        return Urun.fromMap(response);
      }
      return null;
    } catch (e) {
      debugPrint('Barkodla \u00fcr\u00fcn bulunurken hata: \$e');
      return null;
    }
  }

  Future<void> urunFiyatGuncelle(String barkod, double yeniFiyat) async {
    try {
      await supabaseClient
          .from('urunler')
          .update({'satis_fiyati': yeniFiyat})
          .eq('barkod', barkod)
          .eq('firma_id', supabaseClient.auth.currentUser!.id);

      final index = urunler.indexWhere((u) => u.barkod == barkod);
      if (index != -1) {
        urunler[index] = urunler[index].copyWith(satisFiyati: yeniFiyat);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('\u00dc\u00fcr\u00fcn fiyat\u0131 g\u00fcncellenirken hata: \$e');
      throw Exception('Fiyat g\u00fcncellenemedi: \${e.toString()}');
    }
  }

  Future<void> stokGuncelle(String barkod, double yeniStok) async {
    try {
      await supabaseClient
          .from('urunler')
          .update({'stok': yeniStok})
          .eq('barkod', barkod)
          .eq('firma_id', supabaseClient.auth.currentUser!.id);

      final index = urunler.indexWhere((u) => u.barkod == barkod);
      if (index != -1) {
        urunler[index] = urunler[index].copyWith(stok: yeniStok);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Stok g\u00fcncellenirken hata: \$e');
      throw Exception('Stok g\u00fcncellenemedi: \${e.toString()}');
    }
  }

  Future<void> urunleriEkle(List<Urun> urunListesi) async {
    try {
      await supabaseClient.from('urunler').upsert(
        urunListesi.map((u) => u.toMap()).toList(),
        onConflict: 'barkod,firma_id',
      );
      await loadUrunler();
    } catch (e) {
      debugPrint('Toplu \u00fcr\u00fcn eklenirken hata: \$e');
      throw Exception('\u00dc\u00fcr\u00fcnler eklenemedi: \${e.toString()}');
    }
  }
}