import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category_model.dart';
import '../providers/category_provider.dart';
import 'category_add_dialog.dart';

class KategoriSayfasi extends StatefulWidget {
  const KategoriSayfasi({super.key});

  @override
  State<KategoriSayfasi> createState() => _KategoriSayfasiState();
}

class _KategoriSayfasiState extends State<KategoriSayfasi> {
  final Set<String> _expandedCategories = {};

  void _toggleExpansion(String kategoriId) {
    setState(() {
      if (_expandedCategories.contains(kategoriId)) {
        _expandedCategories.remove(kategoriId);
      } else {
        _expandedCategories.add(kategoriId);
      }
    });
  }

  void _showKategoriEkleDialog(BuildContext context, {Category? kategori}) {
    showDialog(
      context: context,
      builder: (context) => KategoriEkleDialog(kategori: kategori),
    );
  }

  void _silKategori(BuildContext context, Category kategori) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kategori Sil'),
        content: Text('"${kategori.name}" kategorisini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context); // Önce dialog kapatılır
              _kategoriSilIslemi(kategori); // Sonra async işlem başlatılır
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  Future<void> _kategoriSilIslemi(Category kategori) async {
    try {
      await Provider.of<CategoryProvider>(context, listen: false).deleteCategory(kategori.id);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${kategori.name}" kategorisi silindi')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CategoryProvider>(context);
    final kategoriler = provider.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori Yönetimi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showKategoriEkleDialog(context),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : kategoriler.isEmpty
              ? const Center(child: Text('Hiç kategori bulunamadı.'))
              : ListView.builder(
                  itemCount: kategoriler.length,
                  itemBuilder: (context, index) {
                    final kategori = kategoriler[index];
                    final isExpanded = _expandedCategories.contains(kategori.id);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Column(
                        children: [
                          ListTile(
                            leading: IconButton(
                              icon: Icon(
                                isExpanded ? Icons.expand_less : Icons.expand_more,
                              ),
                              onPressed: () => _toggleExpansion(kategori.id),
                            ),
                            title: Text(
                              kategori.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () =>
                                      _showKategoriEkleDialog(context, kategori: kategori),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _silKategori(context, kategori),
                                ),
                              ],
                            ),
                          ),
                          if (isExpanded)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                'Alt kategori desteği henüz aktif değil.',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
