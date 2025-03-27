class Urun {
  final String barkod;
  final String urunAdi;
  final double stok;
  final double kritikStok;
  final String birim; // Artık required değil
  final String? stokKodu;
  final double alisFiyati;
  final double karOrani;
  final double satisFiyati;
  final String anaKategori;
  final String altKategori;
  final String tedarikci;
  final String tedarikTarihi;
  final String notlar;

  Urun({
    required this.barkod,
    required this.urunAdi,
    required this.stok,
    required this.kritikStok,
    this.birim = 'Adet', // Varsayılan değer atandı, artık required değil
    this.stokKodu,
    required this.alisFiyati,
    required this.karOrani,
    required this.satisFiyati,
    required this.anaKategori,
    required this.altKategori,
    required this.tedarikci,
    required this.tedarikTarihi,
    required this.notlar,
  });

  // copyWith metodu da güncellenmeli (varsa)
  Urun copyWith({
    String? barkod,
    String? urunAdi,
    double? stok,
    double? kritikStok,
    String? birim,
    String? stokKodu,
    double? alisFiyati,
    double? karOrani,
    double? satisFiyati,
    String? anaKategori,
    String? altKategori,
    String? tedarikci,
    String? tedarikTarihi,
    String? notlar,
  }) {
    return Urun(
      barkod: barkod ?? this.barkod,
      urunAdi: urunAdi ?? this.urunAdi,
      stok: stok ?? this.stok,
      kritikStok: kritikStok ?? this.kritikStok,
      birim: birim ?? this.birim, // Güncellendi
      stokKodu: stokKodu ?? this.stokKodu,
      alisFiyati: alisFiyati ?? this.alisFiyati,
      karOrani: karOrani ?? this.karOrani,
      satisFiyati: satisFiyati ?? this.satisFiyati,
      anaKategori: anaKategori ?? this.anaKategori,
      altKategori: altKategori ?? this.altKategori,
      tedarikci: tedarikci ?? this.tedarikci,
      tedarikTarihi: tedarikTarihi ?? this.tedarikTarihi,
      notlar: notlar ?? this.notlar,
    );
  }
}