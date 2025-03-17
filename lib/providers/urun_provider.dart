import 'package:flutter/material.dart';
import '../models/urun_model.dart';

class UrunProvider with ChangeNotifier {
  final List<Urun> _urunler = [];

  List<Urun> get urunler => _urunler;

  void urunEkle(Urun yeniUrun) {
    _urunler.add(yeniUrun);
    notifyListeners();
  }
}