// lib/models/kategori_model.dart
class Kategori {
  final String id;
  final String ad;
  final String? ustKategoriId;
  bool aktif;

  Kategori({
    required this.id,
    required this.ad,
    this.ustKategoriId,
    this.aktif = true,
  });

  @override
  String toString() {
    return 'Kategori{id: $id, ad: $ad, ustKategoriId: $ustKategoriId, aktif: $aktif}';
  }
}