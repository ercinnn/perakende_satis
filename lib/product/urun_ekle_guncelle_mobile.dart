import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/urun_provider.dart';
import '../models/urun_model.dart';

class UrunEkleGuncelleMobile extends StatefulWidget {
  const UrunEkleGuncelleMobile({super.key});

  @override
  State<UrunEkleGuncelleMobile> createState() => _UrunEkleGuncelleMobileState();
}

class _UrunEkleGuncelleMobileState extends State<UrunEkleGuncelleMobile> {
  final _formKey = GlobalKey<FormState>();
  final _barkodController = TextEditingController();
  final _urunAdiController = TextEditingController();
  final _stokController = TextEditingController();
  final _birimController = TextEditingController(text: 'Adet');
  final _kritikStokController = TextEditingController();
  final _alisFiyatiController = TextEditingController();
  final _karOraniController = TextEditingController();
  final _satisFiyatiController = TextEditingController();
  final _anaKategoriController = TextEditingController();
  final _altKategoriController = TextEditingController();
  final _tedarikciController = TextEditingController();
  final _tedarikTarihiController = TextEditingController();
  final _notlarController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final urun = ModalRoute.of(context)!.settings.arguments as Urun?;
    if (urun != null) {
      _barkodController.text = urun.barkod;
      _urunAdiController.text = urun.urunAdi;
      _stokController.text = urun.stok.toString();
      _birimController.text = urun.birim;
      _kritikStokController.text = urun.kritikStok.toString();
      _alisFiyatiController.text = urun.alisFiyati.toString();
      _karOraniController.text = urun.karOrani.toString();
      _satisFiyatiController.text = urun.satisFiyati.toString();
      _anaKategoriController.text = urun.anaKategori;
      _altKategoriController.text = urun.altKategori;
      _tedarikciController.text = urun.tedarikci;
      _tedarikTarihiController.text = urun.tedarikTarihi;
      _notlarController.text = urun.notlar;
    }
  }

  void _hesaplaSatisFiyati() {
    double alisFiyati = double.tryParse(_alisFiyatiController.text) ?? 0;
    double karOrani = double.tryParse(_karOraniController.text) ?? 0;

    if (alisFiyati > 0 && karOrani > 0) {
      double satisFiyati = alisFiyati * (1 + karOrani / 100);
      _satisFiyatiController.text = satisFiyati.toStringAsFixed(2);
    }
  }

  void _hesaplaKarOrani() {
    double alisFiyati = double.tryParse(_alisFiyatiController.text) ?? 0;
    double satisFiyati = double.tryParse(_satisFiyatiController.text) ?? 0;

    if (alisFiyati > 0 && satisFiyati > 0) {
      double karOrani = ((satisFiyati - alisFiyati) / alisFiyati) * 100;
      _karOraniController.text = karOrani.toStringAsFixed(2);
    }
  }

  void _alanlariTemizle() {
    _barkodController.clear();
    _urunAdiController.clear();
    _stokController.clear();
    _birimController.clear();
    _kritikStokController.clear();
    _alisFiyatiController.clear();
    _karOraniController.clear();
    _satisFiyatiController.clear();
    _anaKategoriController.clear();
    _altKategoriController.clear();
    _tedarikciController.clear();
    _tedarikTarihiController.clear();
    _notlarController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _barkodController,
                decoration: const InputDecoration(
                  labelText: 'Barkod',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _urunAdiController,
                decoration: const InputDecoration(
                  labelText: 'Ürün Adı',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ürün adı boş olamaz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stokController,
                decoration: const InputDecoration(
                  labelText: 'Stok',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Stok boş olamaz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _birimController,
                decoration: const InputDecoration(
                  labelText: 'Birim',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kritikStokController,
                decoration: const InputDecoration(
                  labelText: 'Kritik Stok',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kritik stok boş olamaz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _alisFiyatiController,
                decoration: const InputDecoration(
                  labelText: 'Alış Fiyatı',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _hesaplaSatisFiyati();
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _karOraniController,
                decoration: const InputDecoration(
                  labelText: 'Kar Oranı (%)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _hesaplaSatisFiyati();
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _satisFiyatiController,
                decoration: const InputDecoration(
                  labelText: 'Satış Fiyatı',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _hesaplaKarOrani();
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _anaKategoriController,
                decoration: const InputDecoration(
                  labelText: 'Ana Kategori',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _altKategoriController,
                decoration: const InputDecoration(
                  labelText: 'Alt Kategori',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tedarikciController,
                decoration: const InputDecoration(
                  labelText: 'Tedarikçi',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tedarikTarihiController,
                decoration: const InputDecoration(
                  labelText: 'Tedarik Tarihi (gg.aa.yyyy)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notlarController,
                decoration: const InputDecoration(
                  labelText: 'Notlar',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Urun yeniUrun = Urun(
                      barkod: _barkodController.text,
                      urunAdi: _urunAdiController.text,
                      stok: double.parse(_stokController.text),
                      birim: _birimController.text,
                      kritikStok: double.parse(_kritikStokController.text),
                      alisFiyati: double.parse(_alisFiyatiController.text),
                      karOrani: double.parse(_karOraniController.text),
                      satisFiyati: double.parse(_satisFiyatiController.text),
                      anaKategori: _anaKategoriController.text,
                      altKategori: _altKategoriController.text,
                      tedarikci: _tedarikciController.text,
                      tedarikTarihi: _tedarikTarihiController.text,
                      notlar: _notlarController.text,
                    );

                    final urunProvider = Provider.of<UrunProvider>(context, listen: false);
                    urunProvider.urunEkle(yeniUrun);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ürün başarıyla eklendi!')),
                    );

                    _alanlariTemizle();
                  }
                },
                child: const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}