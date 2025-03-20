import 'package:flutter/material.dart';
import '../models/urun_model.dart';

class UrunProvider with ChangeNotifier {
  final List<Urun> _urunler = [];

  List<Urun> get urunler => _urunler;

  void urunEkle(Urun yeniUrun) {
    if (_urunler.any((urun) => urun.barkod == yeniUrun.barkod)) {
      throw Exception('Bu barkodla kayıtlı ürün zaten var!');
    }
    _urunler.add(yeniUrun);
    notifyListeners();
  }

  void urunleriEkle(List<Urun> yeniUrunler) {
    for (var yeniUrun in yeniUrunler) {
      if (!_urunler.any((urun) => urun.barkod == yeniUrun.barkod)) {
        _urunler.add(yeniUrun);
      }
    }
    notifyListeners();
  }

  void urunSil(String barkod) {
    _urunler.removeWhere((urun) => urun.barkod == barkod);
    notifyListeners();
  }

  void urunGuncelle(Urun guncellenenUrun) {
    final index = _urunler.indexWhere((urun) => urun.barkod == guncellenenUrun.barkod);
    if (index != -1) {
      _urunler[index] = guncellenenUrun;
      notifyListeners();
    }
  }

  Urun? barkodlaUrunBul(String barkod) {
    try {
      return _urunler.firstWhere((urun) => urun.barkod == barkod);
    } catch (e) {
      return null;
    }
  }

  List<Urun> stokDurumunaGoreFiltrele(int minStok) {
    return _urunler.where((urun) => urun.stok >= minStok).toList();
  }
}