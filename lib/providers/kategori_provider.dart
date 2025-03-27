// lib/providers/kategori_provider.dart
import 'package:flutter/material.dart';
import '../models/kategori_model.dart';

class KategoriProvider with ChangeNotifier {
  final List<Kategori> _kategoriler = [];

  List<Kategori> get kategoriler => _kategoriler;

  List<Kategori> get tumAktifKategoriler => 
      _kategoriler.where((k) => k.aktif).toList();

  List<Kategori> getAnaKategoriler() => 
      tumAktifKategoriler.where((k) => k.ustKategoriId == null).toList();

  List<Kategori> getAltKategoriler(String anaKategoriId) => 
      tumAktifKategoriler.where((k) => k.ustKategoriId == anaKategoriId).toList();

  Kategori? getKategoriById(String? id) {
    if (id == null) return null;
    return _kategoriler.firstWhere((k) => k.id == id);
  }

  void kategoriEkle(String ad, {String? ustKategoriId}) {
    if (ad.isEmpty) throw Exception('Kategori adı boş olamaz');
    
    final yeniKategori = Kategori(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ad: ad,
      ustKategoriId: ustKategoriId,
    );
    
    _kategoriler.add(yeniKategori);
    notifyListeners();
  }

  void kategoriGuncelle({
    required String id,
    required String yeniAd,
    String? ustKategoriId,
    bool? aktif,
  }) {
    final index = _kategoriler.indexWhere((k) => k.id == id);
    if (index == -1) throw Exception('Kategori bulunamadı');
    
    if (ustKategoriId == id) {
      throw Exception('Bir kategori kendisinin üst kategorisi olamaz');
    }

    _kategoriler[index] = Kategori(
      id: id,
      ad: yeniAd,
      ustKategoriId: ustKategoriId,
      aktif: aktif ?? _kategoriler[index].aktif,
    );
    notifyListeners();
  }

  void kategoriSil(String id) {
    final silinecekKategori = getKategoriById(id);
    if (silinecekKategori == null) return;

    final altKategoriler = getAltKategoriler(id);
    if (altKategoriler.isNotEmpty) {
      throw Exception('Bu kategorinin alt kategorileri var, önce onları silmelisiniz');
    }

    kategoriGuncelle(
      id: id,
      yeniAd: silinecekKategori.ad,
      ustKategoriId: silinecekKategori.ustKategoriId,
      aktif: false,
    );
  }
}