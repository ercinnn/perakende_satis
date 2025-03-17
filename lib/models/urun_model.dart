// lib/models/urun_model.dart
class Urun {
  final String barkod;
  final String urunAdi;
  final int stok;
  final double alisFiyati;
  final double karOrani;
  final double satisFiyati;

  Urun({
    required this.barkod,
    required this.urunAdi,
    required this.stok,
    required this.alisFiyati,
    required this.karOrani,
    required this.satisFiyati,
  });
}