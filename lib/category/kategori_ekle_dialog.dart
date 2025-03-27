// lib/category/kategori_ekle_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/kategori_provider.dart';
import '../../models/kategori_model.dart'; 

class KategoriEkleDialog extends StatefulWidget {
  final Kategori? duzenlenecekKategori;
  
  const KategoriEkleDialog({
    super.key,
    this.duzenlenecekKategori,
  });

  @override
  State<KategoriEkleDialog> createState() => _KategoriEkleDialogState();
}

class _KategoriEkleDialogState extends State<KategoriEkleDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _adController;
  String? _selectedUstKategoriId;

  @override
  void initState() {
    super.initState();
    _adController = TextEditingController(
      text: widget.duzenlenecekKategori?.ad ?? ''
    );
    _selectedUstKategoriId = widget.duzenlenecekKategori?.ustKategoriId;
  }

  @override
  void dispose() {
    _adController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<KategoriProvider>(context);
    final anaKategoriler = provider.getAnaKategoriler()
      .where((k) => widget.duzenlenecekKategori?.id != k.id)
      .toList();

    return AlertDialog(
      title: Text(widget.duzenlenecekKategori == null 
          ? 'Yeni Kategori Ekle' 
          : 'Kategori Düzenle'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _adController,
                decoration: const InputDecoration(
                  labelText: 'Kategori Adı*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kategori adı boş olamaz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedUstKategoriId,
                decoration: const InputDecoration(
                  labelText: 'Üst Kategori',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Ana Kategori'),
                  ),
                  ...anaKategoriler.map((kategori) {
                    return DropdownMenuItem(
                      value: kategori.id,
                      child: Text(kategori.ad),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedUstKategoriId = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              try {
                if (widget.duzenlenecekKategori == null) {
                  provider.kategoriEkle(
                    _adController.text,
                    ustKategoriId: _selectedUstKategoriId,
                  );
                } else {
                  provider.kategoriGuncelle(
                    id: widget.duzenlenecekKategori!.id,
                    yeniAd: _adController.text,
                    ustKategoriId: _selectedUstKategoriId,
                  );
                }
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            }
          },
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}