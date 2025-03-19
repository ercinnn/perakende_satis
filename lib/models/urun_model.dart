class Urun {
  final String barkod;
  final String urunAdi;
  int stok; // final olmaktan çıkarıldı
  final double alisFiyati;
  final double karOrani;
  final double satisFiyati;
  final int kritikStok;
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

  // copyWith metodu ekleniyor
  Urun copyWith({
    int? stok,
  }) {
    return Urun(
      barkod: barkod,
      urunAdi: urunAdi,
      stok: stok ?? this.stok,
      alisFiyati: alisFiyati,
      karOrani: karOrani,
      satisFiyati: satisFiyati,
      kritikStok: kritikStok,
      anaKategori: anaKategori,
      altKategori: altKategori,
      tedarikci: tedarikci,
      tedarikTarihi: tedarikTarihi,
      notlar: notlar,
    );
  }
}