// lib/category/kategori_sayfasi.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/kategori_provider.dart';
import '../../models/kategori_model.dart';
import 'kategori_ekle_dialog.dart';

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

  void _showKategoriEkleDialog(BuildContext context, {Kategori? kategori}) {
    showDialog(
      context: context,
      builder: (context) => KategoriEkleDialog(
        duzenlenecekKategori: kategori,
      ),
    );
  }

  void _silKategori(BuildContext context, Kategori kategori) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kategori Sil'),
        content: Text('"${kategori.ad}" kategorisini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              try {
                Provider.of<KategoriProvider>(context, listen: false)
                    .kategoriSil(kategori.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${kategori.ad}" kategorisi silindi')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<KategoriProvider>(context);
    final anaKategoriler = provider.getAnaKategoriler();

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
      body: ListView.builder(
        itemCount: anaKategoriler.length,
        itemBuilder: (context, index) {
          final anaKategori = anaKategoriler[index];
          final altKategoriler = provider.getAltKategoriler(anaKategori.id);
          final isExpanded = _expandedCategories.contains(anaKategori.id);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: IconButton(
                    icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                    onPressed: () => _toggleExpansion(anaKategori.id),
                  ),
                  title: Text(
                    anaKategori.ad,
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
                        onPressed: () => _showKategoriEkleDialog(
                          context, 
                          kategori: anaKategori,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _silKategori(context, anaKategori),
                      ),
                    ],
                  ),
                ),
                if (isExpanded && altKategoriler.isNotEmpty)
                  ...altKategoriler.map((altKategori) => Padding(
                    padding: const EdgeInsets.only(left: 32.0),
                    child: ListTile(
                      title: Text(altKategori.ad),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showKategoriEkleDialog(
                              context, 
                              kategori: altKategori,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _silKategori(context, altKategori),
                          ),
                        ],
                      ),
                    ),
                  )),
              ],
            ),
          );
        },
      ),
    );
  }
}