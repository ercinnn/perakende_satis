import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/urun_provider.dart';
import '../models/urun_model.dart';
import 'package:barcode_scan2/barcode_scan2.dart';

class UrunEkleGuncelle extends StatefulWidget {
  const UrunEkleGuncelle({super.key});

  @override
  UrunEkleGuncelleState createState() => UrunEkleGuncelleState();
}

class UrunEkleGuncelleState extends State<UrunEkleGuncelle> {
  final _formKey = GlobalKey<FormState>();
  final _barkodController = TextEditingController();
  final _urunAdiController = TextEditingController();
  final _stokController = TextEditingController();
  final _alisFiyatiController = TextEditingController();
  final _karOraniController = TextEditingController();
  final _satisFiyatiController = TextEditingController();
  final _kritikStokController = TextEditingController(); // Yeni alan
  final _anaKategoriController = TextEditingController(); // Yeni alan
  final _altKategoriController = TextEditingController(); // Yeni alan
  final _tedarikciController = TextEditingController(); // Yeni alan
  final _tedarikTarihiController = TextEditingController(); // Yeni alan
  final _notlarController = TextEditingController(); // Yeni alan

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ürün bilgilerini al ve alanları doldur
    final urun = ModalRoute.of(context)!.settings.arguments as Urun?;
    if (urun != null) {
      _barkodController.text = urun.barkod;
      _urunAdiController.text = urun.urunAdi;
      _stokController.text = urun.stok.toString();
      _alisFiyatiController.text = urun.alisFiyati.toString();
      _karOraniController.text = urun.karOrani.toString();
      _satisFiyatiController.text = urun.satisFiyati.toString();
      _kritikStokController.text = urun.kritikStok.toString(); // Yeni alan
      _anaKategoriController.text = urun.anaKategori; // Yeni alan
      _altKategoriController.text = urun.altKategori; // Yeni alan
      _tedarikciController.text = urun.tedarikci; // Yeni alan
      _tedarikTarihiController.text = urun.tedarikTarihi; // Yeni alan
      _notlarController.text = urun.notlar; // Yeni alan
    }
  }

  Future<void> _barkodTara() async {
    var result = await BarcodeScanner.scan();

    if (!mounted) return;

    setState(() {
      _barkodController.text = result.rawContent.isNotEmpty ? result.rawContent : 'Tarama başarısız';
      _urunBilgileriniDoldur(); // Barkod tarandığında ürün bilgilerini doldur
    });
  }

  void _urunBilgileriniDoldur() {
    final urunProvider = Provider.of<UrunProvider>(context, listen: false);
    final barkod = _barkodController.text;

    // Barkod ile eşleşen ürünü bul
    final urun = urunProvider.urunler.firstWhere(
      (u) => u.barkod == barkod,
      orElse: () => Urun(
        barkod: '',
        urunAdi: '',
        stok: 0,
        alisFiyati: 0,
        karOrani: 0,
        satisFiyati: 0,
        kritikStok: 0,
        anaKategori: '',
        altKategori: '',
        tedarikci: '',
        tedarikTarihi: '',
        notlar: '',
      ),
    );

    if (urun.barkod.isNotEmpty) {
      // Ürün bilgilerini doldur
      setState(() {
        _urunAdiController.text = urun.urunAdi;
        _stokController.text = urun.stok.toString();
        _alisFiyatiController.text = urun.alisFiyati.toString();
        _karOraniController.text = urun.karOrani.toString();
        _satisFiyatiController.text = urun.satisFiyati.toString();
        _kritikStokController.text = urun.kritikStok.toString();
        _anaKategoriController.text = urun.anaKategori;
        _altKategoriController.text = urun.altKategori;
        _tedarikciController.text = urun.tedarikci;
        _tedarikTarihiController.text = urun.tedarikTarihi;
        _notlarController.text = urun.notlar;
      });
    } else {
      // Ürün bulunamadıysa alanları temizle
      setState(() {
        _urunAdiController.clear();
        _stokController.clear();
        _alisFiyatiController.clear();
        _karOraniController.clear();
        _satisFiyatiController.clear();
        _kritikStokController.clear();
        _anaKategoriController.clear();
        _altKategoriController.clear();
        _tedarikciController.clear();
        _tedarikTarihiController.clear();
        _notlarController.clear();
      });
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
    _alisFiyatiController.clear();
    _karOraniController.clear();
    _satisFiyatiController.clear();
    _kritikStokController.clear();
    _anaKategoriController.clear();
    _altKategoriController.clear();
    _tedarikciController.clear();
    _tedarikTarihiController.clear();
    _notlarController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ürün Ekle/Güncelle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _barkodController,
                decoration: InputDecoration(
                  labelText: 'Barkod',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: _barkodTara,
                  ),
                ),
                onChanged: (value) {
                  _urunBilgileriniDoldur(); // Barkod elle girildiğinde ürün bilgilerini doldur
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _urunAdiController,
                decoration: InputDecoration(
                  labelText: 'Ürün Adı',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ürün adı boş olamaz';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _stokController,
                decoration: InputDecoration(
                  labelText: 'Stok',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Stok boş olamaz';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _kritikStokController,
                decoration: InputDecoration(
                  labelText: 'Kritik Stok',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kritik stok boş olamaz';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _alisFiyatiController,
                decoration: InputDecoration(
                  labelText: 'Alış Fiyatı',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _hesaplaSatisFiyati(); // Alış fiyatı değiştiğinde satış fiyatını hesapla
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alış fiyatı boş olamaz';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _karOraniController,
                decoration: InputDecoration(
                  labelText: 'Kar Oranı (%)',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _hesaplaSatisFiyati(); // Kar oranı değiştiğinde satış fiyatını hesapla
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kar oranı boş olamaz';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _satisFiyatiController,
                decoration: InputDecoration(
                  labelText: 'Satış Fiyatı',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _hesaplaKarOrani(); // Satış fiyatı değiştiğinde kar oranını hesapla
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Satış fiyatı boş olamaz';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _anaKategoriController,
                decoration: InputDecoration(
                  labelText: 'Ana Kategori',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ana kategori boş olamaz';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _altKategoriController,
                decoration: InputDecoration(
                  labelText: 'Alt Kategori',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alt kategori boş olamaz';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _tedarikciController,
                decoration: InputDecoration(
                  labelText: 'Tedarikçi',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tedarikçi boş olamaz';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _tedarikTarihiController,
                decoration: InputDecoration(
                  labelText: 'Tedarik Tarihi (gg.aa.yyyy)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tedarik tarihi boş olamaz';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _notlarController,
                decoration: InputDecoration(
                  labelText: 'Notlar',
                ),
                maxLines: 3,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Urun yeniUrun = Urun(
                      barkod: _barkodController.text,
                      urunAdi: _urunAdiController.text,
                      stok: int.parse(_stokController.text),
                      alisFiyati: double.parse(_alisFiyatiController.text),
                      karOrani: double.parse(_karOraniController.text),
                      satisFiyati: double.parse(_satisFiyatiController.text),
                      kritikStok: int.parse(_kritikStokController.text),
                      anaKategori: _anaKategoriController.text,
                      altKategori: _altKategoriController.text,
                      tedarikci: _tedarikciController.text,
                      tedarikTarihi: _tedarikTarihiController.text,
                      notlar: _notlarController.text,
                    );

                    final urunProvider = Provider.of<UrunProvider>(context, listen: false);
                    urunProvider.urunEkle(yeniUrun);

                    // Başarılı mesajı göster
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ürün başarıyla eklendi!')),
                    );

                    // Alanları temizle
                    _alanlariTemizle();
                  }
                },
                child: Text('Kaydet'),
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
    _alisFiyatiController.dispose();
    _karOraniController.dispose();
    _satisFiyatiController.dispose();
    _kritikStokController.dispose();
    _anaKategoriController.dispose();
    _altKategoriController.dispose();
    _tedarikciController.dispose();
    _tedarikTarihiController.dispose();
    _notlarController.dispose();
    super.dispose();
  }
}