import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';

class UrunEkleGuncelleMobile extends StatefulWidget {
  const UrunEkleGuncelleMobile({super.key});

  @override
  State<UrunEkleGuncelleMobile> createState() => _UrunEkleGuncelleMobileState();
}

class _UrunEkleGuncelleMobileState extends State<UrunEkleGuncelleMobile> {
  final _formKey = GlobalKey<FormState>();
  final _barkodController = TextEditingController();
  final _urunAdiController = TextEditingController();
  final _stokController = TextEditingController(text: '0');

  String _selectedBirim = 'Adet';
  final List<String> _birimler = ['Adet', 'Kilo', 'Metre', 'Litre', 'Paket'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mobil - Ürün Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
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
              DropdownButtonFormField<String>(
                value: _selectedBirim,
                items: _birimler.map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedBirim = value!),
                decoration: const InputDecoration(labelText: 'Birim*'),
              ),
              const SizedBox(height: 20),
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

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final yeniUrun = Urun(
        barkod: _barkodController.text,
        urunAdi: _urunAdiController.text,
        stok: double.tryParse(_stokController.text) ?? 0,
        birim: _selectedBirim,
        // Diğer alanları istersen null/default verilerle doldur
        kritikStok: 0,
        alisFiyati: 0,
        karOrani: 0,
        satisFiyati: 0,
        anaKategori: '',
        altKategori: '',
        tedarikci: '',
        tedarikTarihi: '',
        notlar: '',
        firmaId: '',
        firmaAdi: '',
        userEmail: '',
      );

      Provider.of<UrunProvider>(context, listen: false).urunEkle(yeniUrun);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ürün kaydedildi')),
      );

      _clearFields();
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
  void dispose() {
    _barkodController.dispose();
    _urunAdiController.dispose();
    _stokController.dispose();
    super.dispose();
  }
}
