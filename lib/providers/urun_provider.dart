import 'package:flutter/material.dart';
import '../models/urun_model.dart';

class UrunProvider with ChangeNotifier {
  final List<Urun> _urunler = [];

  // Ürün listesini dışarıya açık hale getir
  List<Urun> get urunler => _urunler;

  // 🔹 TEK ÜRÜN EKLEME
  void urunEkle(Urun yeniUrun) {
    try {
      if (_urunler.any((urun) => urun.barkod == yeniUrun.barkod)) {
        throw Exception('Bu barkodla kayıtlı bir ürün zaten var!');
      }
      _urunler.add(yeniUrun);
      notifyListeners();
    } catch (e) {
      throw Exception('Ürün eklenirken hata oluştu: $e');
    }
  }

  // 🔹 ÇOKLU ÜRÜN EKLEME (Excel için)
  void urunleriEkle(List<Urun> yeniUrunler) {
    try {
      for (var yeniUrun in yeniUrunler) {
        if (_urunler.any((urun) => urun.barkod == yeniUrun.barkod)) {
          continue; // Aynı barkod varsa ekleme, devam et
        }
        _urunler.add(yeniUrun);
      }
      notifyListeners();
    } catch (e) {
      throw Exception('Ürünler eklenirken hata oluştu: $e');
    }
  }

  // 🔹 ÜRÜN SİLME
  void urunSil(String barkod) {
    try {
      _urunler.removeWhere((urun) => urun.barkod == barkod);
      notifyListeners();
    } catch (e) {
      throw Exception('Ürün silinirken hata oluştu: $e');
    }
  }

  // 🔹 ÜRÜN GÜNCELLEME
  void urunGuncelle(Urun guncellenenUrun) {
    try {
      final index = _urunler.indexWhere((urun) => urun.barkod == guncellenenUrun.barkod);
      if (index == -1) {
        throw Exception('Güncellenecek ürün bulunamadı!');
      }
      _urunler[index] = guncellenenUrun;
      notifyListeners();
    } catch (e) {
      throw Exception('Ürün güncellenirken hata oluştu: $e');
    }
  }

  // 🔹 BARKODLA ÜRÜN BULMA
  Urun? barkodlaUrunBul(String barkod) {
    try {
      return _urunler.firstWhere(
        (urun) => urun.barkod == barkod,
        orElse: () => throw Exception('Ürün bulunamadı!'),
      );
    } catch (e) {
      throw Exception('Ürün bulunurken hata oluştu: $e');
    }
  }

  // 🔹 STOK DURUMUNA GÖRE FİLTRELEME
  List<Urun> stokDurumunaGoreFiltrele(int minStok) {
    try {
      return _urunler.where((urun) => urun.stok >= minStok).toList();
    } catch (e) {
      throw Exception('Filtreleme sırasında hata oluştu: $e');
    }
  }
}