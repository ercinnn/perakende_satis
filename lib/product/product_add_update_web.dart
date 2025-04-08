import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';

class UrunEkleGuncelleWeb extends StatefulWidget {
  const UrunEkleGuncelleWeb({super.key});

  @override
  State<UrunEkleGuncelleWeb> createState() => _UrunEkleGuncelleWebState();
}

class _UrunEkleGuncelleWebState extends State<UrunEkleGuncelleWeb> {
  final _formKey = GlobalKey<FormState>();
  final _barkodController = TextEditingController();
  final _urunAdiController = TextEditingController();
  final _stokController = TextEditingController(text: '0');
  String _selectedBirim = 'Adet';

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final supabase = Supabase.instance.client;
      final firmaId = supabase.auth.currentUser?.id ?? '';
      final userEmail = supabase.auth.currentUser?.email ?? '';

      final yeniUrun = Urun(
        barkod: _barkodController.text,
        urunAdi: _urunAdiController.text,
        stok: double.tryParse(_stokController.text) ?? 0,
        birim: _selectedBirim,
        kritikStok: 0,
        alisFiyati: 0,
        karOrani: 0,
        satisFiyati: 0,
        anaKategori: '',
        altKategori: '',
        tedarikci: '',
        tedarikTarihi: '',
        notlar: '',
        firmaId: firmaId,
        firmaAdi: '',
        userEmail: userEmail,
      );

      try {
        final existing = await supabase
            .from('urunler')
            .select()
            .eq('barkod', yeniUrun.barkod)
            .eq('firma_id', firmaId)
            .maybeSingle();

        if (existing != null) {
          throw Exception('Bu barkod zaten kayıtlı!');
        }

        await supabase.from('urunler').insert({
          ...yeniUrun.toMap(),
          'created_at': DateTime.now().toIso8601String(),
        });

        if (!mounted) return;
        Provider.of<UrunProvider>(context, listen: false).urunEkle(yeniUrun);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ürün başarıyla kaydedildi!')),
        );

        _clearFields();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  void _clearFields() {
    _barkodController.clear();
    _urunAdiController.clear();
    _stokController.text = '0';
    _selectedBirim = 'Adet';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Web - Ürün Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _barkodController,
                decoration: const InputDecoration(labelText: 'Barkod*'),
                validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _urunAdiController,
                decoration: const InputDecoration(labelText: 'Ürün Adı*'),
                validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stokController,
                decoration: const InputDecoration(labelText: 'Stok*'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _saveProduct,
                child: const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _barkodController.dispose();
    _urunAdiController.dispose();
    _stokController.dispose();
    super.dispose();
  }
}
