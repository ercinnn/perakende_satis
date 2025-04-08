class Urun {
  final String? id;
  final String barkod;
  final String urunAdi;
  final double stok;
  final double kritikStok;
  final String? birim; // ❗️ Artık nullable
  final double alisFiyati;
  final double karOrani;
  final double satisFiyati;
  final String anaKategori;
  final String altKategori;
  final String? tedarikci;
  final String? tedarikTarihi;
  final String? notlar;
  final String firmaId;
  final String firmaAdi;
  final String userEmail;
  final String? stokKodu;

  Urun({
    this.id,
    required this.barkod,
    required this.urunAdi,
    required this.stok,
    required this.kritikStok,
    this.birim, // ❗️ Artık opsiyonel
    required this.alisFiyati,
    required this.karOrani,
    required this.satisFiyati,
    required this.anaKategori,
    required this.altKategori,
    this.tedarikci,
    this.tedarikTarihi,
    this.notlar,
    required this.firmaId,
    required this.firmaAdi,
    required this.userEmail,
    this.stokKodu,
  });

  factory Urun.fromMap(Map<String, dynamic> map) {
    return Urun(
      id: map['id']?.toString(),
      barkod: map['barkod'] ?? '',
      urunAdi: map['urun_adi'] ?? '',
      stok: (map['stok'] ?? 0).toDouble(),
      kritikStok: (map['kritik_stok'] ?? 0).toDouble(),
      birim: map['birim'], // ❗️ Zorunlu değil
      alisFiyati: (map['alis_fiyati'] ?? 0).toDouble(),
      karOrani: (map['kar_orani'] ?? 0).toDouble(),
      satisFiyati: (map['satis_fiyati'] ?? 0).toDouble(),
      anaKategori: map['ana_kategori'] ?? '',
      altKategori: map['alt_kategori'] ?? '',
      tedarikci: map['tedarikci'],
      tedarikTarihi: map['tedarik_tarihi'],
      notlar: map['notlar'],
      firmaId: map['firma_id'] ?? '',
      firmaAdi: map['firma_adi'] ?? '',
      userEmail: map['user_email'] ?? '',
      stokKodu: map['stok_kodu'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'barkod': barkod,
      'urun_adi': urunAdi,
      'stok': stok,
      'kritik_stok': kritikStok,
      'birim': birim,
      'alis_fiyati': alisFiyati,
      'kar_orani': karOrani,
      'satis_fiyati': satisFiyati,
      'ana_kategori': anaKategori,
      'alt_kategori': altKategori,
      'tedarikci': tedarikci,
      'tedarik_tarihi': tedarikTarihi,
      'notlar': notlar,
      'firma_id': firmaId,
      'firma_adi': firmaAdi,
      'user_email': userEmail,
      'stok_kodu': stokKodu,
    };
  }

  Urun copyWith({
    String? id,
    String? barkod,
    String? urunAdi,
    double? stok,
    double? kritikStok,
    String? birim,
    double? alisFiyati,
    double? karOrani,
    double? satisFiyati,
    String? anaKategori,
    String? altKategori,
    String? tedarikci,
    String? tedarikTarihi,
    String? notlar,
    String? firmaId,
    String? firmaAdi,
    String? userEmail,
    String? stokKodu,
  }) {
    return Urun(
      id: id ?? this.id,
      barkod: barkod ?? this.barkod,
      urunAdi: urunAdi ?? this.urunAdi,
      stok: stok ?? this.stok,
      kritikStok: kritikStok ?? this.kritikStok,
      birim: birim ?? this.birim,
      alisFiyati: alisFiyati ?? this.alisFiyati,
      karOrani: karOrani ?? this.karOrani,
      satisFiyati: satisFiyati ?? this.satisFiyati,
      anaKategori: anaKategori ?? this.anaKategori,
      altKategori: altKategori ?? this.altKategori,
      tedarikci: tedarikci ?? this.tedarikci,
      tedarikTarihi: tedarikTarihi ?? this.tedarikTarihi,
      notlar: notlar ?? this.notlar,
      firmaId: firmaId ?? this.firmaId,
      firmaAdi: firmaAdi ?? this.firmaAdi,
      userEmail: userEmail ?? this.userEmail,
      stokKodu: stokKodu ?? this.stokKodu,
    );
  }
}
