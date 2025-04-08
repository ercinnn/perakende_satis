import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category_model.dart';
import '../providers/auth_provider.dart';
import '../providers/category_provider.dart';

class KategoriEkleDialog extends StatefulWidget {
  final Category? kategori;

  const KategoriEkleDialog({super.key, this.kategori});

  @override
  State<KategoriEkleDialog> createState() => _KategoriEkleDialogState();
}

class _KategoriEkleDialogState extends State<KategoriEkleDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _adController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.kategori != null) {
      _adController.text = widget.kategori!.name;
    }
  }

  Future<void> _kategoriEkleVeyaGuncelle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = Provider.of<AuthProvider>(context, listen: false).userId;
      if (userId == null) throw Exception('Kullanıcı bilgisi bulunamadı.');

      final kategoriProvider = Provider.of<CategoryProvider>(context, listen: false);

      final yeniKategori = Category(
        id: widget.kategori?.id ?? '', // Supabase insert sırasında ID otomatik atanabilir
        name: _adController.text.trim(),
      );

      if (widget.kategori == null) {
        await kategoriProvider.addCategory(yeniKategori);
      } else {
        await kategoriProvider.updateCategory(yeniKategori); // Bu fonksiyon CategoryProvider içinde olmalı
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İşlem başarısız: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.kategori == null ? "Kategori Ekle" : "Kategori Güncelle"),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _adController,
          decoration: const InputDecoration(labelText: "Kategori Adı"),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Kategori adı giriniz";
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("İptal"),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _kategoriEkleVeyaGuncelle,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.kategori == null ? "Ekle" : "Güncelle"),
        ),
      ],
    );
  }
}
