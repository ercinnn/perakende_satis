class Urun {
  final String barkod;
  String urunAdi;
  double stok;
  final double alisFiyati;
  final double karOrani;
  double satisFiyati;
  final double kritikStok;
  final String anaKategori;
  final String altKategori;
  final String tedarikci;
  final String tedarikTarihi;
  final String notlar;

  Urun({
    required this.barkod,
    required this.urunAdi,
    required this.stok,
    required this.alisFiyati,
    required this.karOrani,
    required this.satisFiyati,
    required this.kritikStok,
    required this.anaKategori,
    required this.altKategori,
    required this.tedarikci,
    required this.tedarikTarihi,
    required this.notlar,
  });

  Urun copyWith({
    String? urunAdi,
    double? stok,
    double? satisFiyati,
  }) {
    return Urun(
      barkod: barkod,
      urunAdi: urunAdi ?? this.urunAdi,
      stok: stok ?? this.stok,
      alisFiyati: alisFiyati,
      karOrani: karOrani,
      satisFiyati: satisFiyati ?? this.satisFiyati,
      kritikStok: kritikStok,
      anaKategori: anaKategori,
      altKategori: altKategori,
      tedarikci: tedarikci,
      tedarikTarihi: tedarikTarihi,
      notlar: notlar,
    );
  }
}