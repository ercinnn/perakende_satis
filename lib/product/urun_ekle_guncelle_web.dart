import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/urun_provider.dart';
import '../../providers/kategori_provider.dart';
import '../../models/urun_model.dart';
import '../../models/kategori_model.dart';

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
  final _kritikStokController = TextEditingController(text: '0');
  final _stokKoduController = TextEditingController();
  final _alisFiyatiController = TextEditingController();
  final _kdvOraniController = TextEditingController(text: '20');
  final _karOraniController = TextEditingController();
  final _satisFiyatiController = TextEditingController();
  final _tedarikciController = TextEditingController();
  final _tedarikTarihiController = TextEditingController();
  final _notlarController = TextEditingController();
  
  bool _kdvDahilMi = false;
  String _selectedBirim = 'Adet';
  final List<String> _birimler = ['Adet', 'Kilo', 'Metre', 'Litre', 'Paket'];
  String? _selectedAnaKategoriId;
  String? _selectedAltKategoriId;
  String _barkodDurumMesaji = 'Barkod:';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final urun = ModalRoute.of(context)?.settings.arguments as Urun?;
    if (urun != null) {
      _fillProductFields(urun);
    }
  }

  void _fillProductFields(Urun urun) {
    setState(() {
      _barkodController.text = urun.barkod;
      _urunAdiController.text = urun.urunAdi;
      _stokController.text = urun.stok.toString();
      _kritikStokController.text = urun.kritikStok.toString();
      _selectedBirim = urun.birim;
      _stokKoduController.text = urun.stokKodu ?? '';
      _alisFiyatiController.text = urun.alisFiyati.toString();
      _karOraniController.text = urun.karOrani.toString();
      _satisFiyatiController.text = urun.satisFiyati.toString();
      _selectedAnaKategoriId = _findKategoriId(urun.anaKategori);
      _selectedAltKategoriId = _findKategoriId(urun.altKategori);
      _tedarikciController.text = urun.tedarikci;
      _tedarikTarihiController.text = urun.tedarikTarihi;
      _notlarController.text = urun.notlar;
      _barkodDurumMesaji = 'Barkod: ${urun.barkod} kayıtlıdır. Aşağıdaki bilgilerde güncelleme yapabilirsiniz.';
    });
  }

  String? _findKategoriId(String? kategoriAdi) {
    if (kategoriAdi == null || kategoriAdi.isEmpty) return null;
    final kategoriProvider = Provider.of<KategoriProvider>(context, listen: false);
    final kategori = kategoriProvider.tumAktifKategoriler.firstWhere(
      (k) => k.ad == kategoriAdi,
      orElse: () => Kategori(id: '', ad: ''),
    );
    return kategori.id.isEmpty ? null : kategori.id;
  }

  void _updateStok(double value) {
    double current = double.tryParse(_stokController.text) ?? 0;
    setState(() {
      _stokController.text = (current + value).toStringAsFixed(2);
    });
  }

  void _updateKritikStok(double value) {
    double current = double.tryParse(_kritikStokController.text) ?? 0;
    setState(() {
      _kritikStokController.text = (current + value).toStringAsFixed(2);
    });
  }

  void _hesaplaSatisFiyati(String value) {
    double alisFiyati = double.tryParse(_alisFiyatiController.text) ?? 0;
    double kdvOrani = double.tryParse(_kdvOraniController.text) ?? 0;
    double karOrani = double.tryParse(_karOraniController.text) ?? 0;

    if (_kdvDahilMi) {
      alisFiyati = alisFiyati / (1 + kdvOrani / 100);
    }

    if (alisFiyati > 0 && karOrani > 0) {
      double satisFiyati = alisFiyati * (1 + karOrani / 100);
      setState(() {
        _satisFiyatiController.text = satisFiyati.toStringAsFixed(2);
      });
    }
  }

  void _hesaplaKarOrani(String value) {
    double alisFiyati = double.tryParse(_alisFiyatiController.text) ?? 0;
    double kdvOrani = double.tryParse(_kdvOraniController.text) ?? 0;
    double satisFiyati = double.tryParse(_satisFiyatiController.text) ?? 0;

    if (_kdvDahilMi) {
      alisFiyati = alisFiyati / (1 + kdvOrani / 100);
    }

    if (alisFiyati > 0 && satisFiyati > 0) {
      double karOrani = ((satisFiyati - alisFiyati) / alisFiyati) * 100;
      setState(() {
        _karOraniController.text = karOrani.toStringAsFixed(2);
      });
    }
  }

  void _alanlariTemizle() {
    setState(() {
      _barkodController.clear();
      _urunAdiController.clear();
      _stokController.text = '0';
      _kritikStokController.text = '0';
      _stokKoduController.clear();
      _alisFiyatiController.clear();
      _kdvOraniController.text = '20';
      _karOraniController.clear();
      _satisFiyatiController.clear();
      _tedarikciController.clear();
      _tedarikTarihiController.clear();
      _notlarController.clear();
      _kdvDahilMi = false;
      _selectedBirim = 'Adet';
      _selectedAnaKategoriId = null;
      _selectedAltKategoriId = null;
      _barkodDurumMesaji = 'Barkod:';
    });
  }

  void _showKategoriEkleDialog(BuildContext context) {
    String yeniKategoriAdi = '';
    String? selectedParentId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Kategori Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Kategori Adı'),
              onChanged: (value) => yeniKategoriAdi = value,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Üst Kategori (Opsiyonel)'),
              value: selectedParentId,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Ana Kategori'),
                ),
                ...Provider.of<KategoriProvider>(context, listen: false)
                    .getAnaKategoriler()
                    .map((kategori) {
                  return DropdownMenuItem(
                    value: kategori.id,
                    child: Text(kategori.ad),
                  );
                }),
              ],
              onChanged: (value) => selectedParentId = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (yeniKategoriAdi.isNotEmpty) {
                Provider.of<KategoriProvider>(context, listen: false)
                    .kategoriEkle(yeniKategoriAdi, ustKategoriId: selectedParentId);
                Navigator.pop(context);
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _verifyBarcode() {
    final barcode = _barkodController.text.trim();
    if (barcode.isEmpty) return;

    final urunProvider = Provider.of<UrunProvider>(context, listen: false);
    final existingProduct = urunProvider.barkodlaUrunBul(barcode);

    if (existingProduct != null) {
      _fillProductFields(existingProduct);
    } else {
      setState(() {
        _barkodDurumMesaji = 'Barkod: $barcode kayıtlı değildir. Aşağıdaki bilgileri doldurarak yeni ürün olarak ekleyebilirsiniz';
        _urunAdiController.clear();
        _stokController.text = '0';
        _kritikStokController.text = '0';
        _stokKoduController.clear();
        _alisFiyatiController.clear();
        _karOraniController.clear();
        _satisFiyatiController.clear();
        _selectedAnaKategoriId = null;
        _selectedAltKategoriId = null;
        _tedarikciController.clear();
        _tedarikTarihiController.clear();
        _notlarController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final kategoriProvider = Provider.of<KategoriProvider>(context);
    final anaKategoriler = kategoriProvider.getAnaKategoriler();
    final altKategoriler = _selectedAnaKategoriId != null
        ? kategoriProvider.getAltKategoriler(_selectedAnaKategoriId!)
        : [];

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SizedBox(
            width: 1200,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _barkodController,
                                decoration: const InputDecoration(
                                  labelText: 'Barkod',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 150,
                              child: ElevatedButton(
                                onPressed: _verifyBarcode,
                                child: const Text('Barkod Onayla'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: Container(),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                    child: Text(
                      _barkodDurumMesaji,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _urunAdiController,
                          decoration: const InputDecoration(
                            labelText: 'Ürün Adı*',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ürün adı boş olamaz';
                            }
                            return null;
                          },
                          textCapitalization: TextCapitalization.characters,
                          style: const TextStyle(
                            fontSize: 16,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  TextField(
                                    controller: _alisFiyatiController,
                                    decoration: InputDecoration(
                                      labelText: 'Alış Fiyatı',
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: _kdvDahilMi ? Colors.green : Colors.red,
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) => _hesaplaSatisFiyati(value),
                                  ),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Tooltip(
                                      message: 'KDV dahil',
                                      child: Checkbox(
                                        value: _kdvDahilMi,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            _kdvDahilMi = value ?? false;
                                            _hesaplaSatisFiyati('');
                                            _hesaplaKarOrani('');
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _kdvOraniController,
                                decoration: const InputDecoration(
                                  labelText: 'KDV Oranı (%)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  _hesaplaSatisFiyati(value);
                                  _hesaplaKarOrani(value);
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _karOraniController,
                                decoration: const InputDecoration(
                                  labelText: 'Kar Oranı (%)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) => _hesaplaSatisFiyati(value),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _satisFiyatiController,
                                decoration: const InputDecoration(
                                  labelText: 'Satış Fiyatı',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) => _hesaplaKarOrani(value),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: Container(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 12.0),
                                    child: Text('Stok', style: TextStyle(fontSize: 12)),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove, color: Colors.red),
                                        onPressed: () => _updateStok(-1),
                                      ),
                                      Expanded(
                                        child: TextField(
                                          controller: _stokController,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add, color: Colors.green),
                                        onPressed: () => _updateStok(1),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 12.0),
                                    child: Text('Kritik Stok', style: TextStyle(fontSize: 12)),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove, color: Colors.red),
                                        onPressed: () => _updateKritikStok(-1),
                                      ),
                                      Expanded(
                                        child: TextField(
                                          controller: _kritikStokController,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add, color: Colors.green),
                                        onPressed: () => _updateKritikStok(1),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 12.0),
                                    child: Text('Birim', style: TextStyle(fontSize: 12)),
                                  ),
                                  DropdownButtonFormField<String>(
                                    value: _selectedBirim,
                                    items: _birimler.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedBirim = newValue!;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 12.0),
                                    child: Text('Stok Kodu', style: TextStyle(fontSize: 12)),
                                  ),
                                  TextField(
                                    controller: _stokKoduController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: Container(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 12.0),
                                    child: Text('Ana Kategori', style: TextStyle(fontSize: 12)),
                                  ),
                                  DropdownButtonFormField<String>(
                                    value: _selectedAnaKategoriId,
                                    items: [
                                      const DropdownMenuItem<String>(
                                        value: null,
                                        child: Text('Seçiniz'),
                                      ),
                                      ...anaKategoriler.map((kategori) {
                                        return DropdownMenuItem<String>(
                                          value: kategori.id,
                                          child: Text(kategori.ad),
                                        );
                                      })
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedAnaKategoriId = value;
                                        _selectedAltKategoriId = null;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 12.0),
                                    child: Text('Alt Kategori', style: TextStyle(fontSize: 12)),
                                  ),
                                  DropdownButtonFormField<String>(
                                    value: _selectedAltKategoriId,
                                    items: [
                                      const DropdownMenuItem<String>(
                                        value: null,
                                        child: Text('Seçiniz'),
                                      ),
                                      ...altKategoriler.map((kategori) {
                                        return DropdownMenuItem<String>(
                                          value: kategori.id,
                                          child: Text(kategori.ad),
                                        );
                                      })
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedAltKategoriId = value;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 150,
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Kategoriler'),
                                      content: SizedBox(
                                        width: double.maxFinite,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: anaKategoriler.length,
                                          itemBuilder: (context, index) {
                                            final kategori = anaKategoriler[index];
                                            return ExpansionTile(
                                              title: Text(kategori.ad),
                                              children: kategoriProvider
                                                  .getAltKategoriler(kategori.id)
                                                  .map((altKategori) => ListTile(
                                                        title: Text(altKategori.ad),
                                                        onTap: () {
                                                          setState(() {
                                                            _selectedAnaKategoriId = kategori.id;
                                                            _selectedAltKategoriId = altKategori.id;
                                                          });
                                                          Navigator.pop(context);
                                                        },
                                                      ))
                                                  .toList(),
                                            );
                                          },
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Kapat'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Text('Kategori Bul'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 150,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.add),
                                label: const Text('Kategori Ekle'),
                                onPressed: () => _showKategoriEkleDialog(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: Container(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            TextField(
                              controller: _tedarikciController,
                              decoration: const InputDecoration(
                                hintText: 'Tedarikçi...',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _tedarikTarihiController,
                              decoration: const InputDecoration(
                                hintText: 'Tedarik Tarihi (gg.aa.yyyy)',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _notlarController,
                          decoration: const InputDecoration(
                            labelText: 'Notlar',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _saveProduct(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text('Kaydet'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveProduct(BuildContext context) {
    final kategoriProvider = Provider.of<KategoriProvider>(context, listen: false);
    
    String anaKategoriAd = '';
    String altKategoriAd = '';
    
    if (_selectedAnaKategoriId != null) {
      final anaKategori = kategoriProvider.tumAktifKategoriler.firstWhere(
        (k) => k.id == _selectedAnaKategoriId,
        orElse: () => Kategori(id: '', ad: ''),
      );
      anaKategoriAd = anaKategori.ad;
    }
    
    if (_selectedAltKategoriId != null) {
      final altKategori = kategoriProvider.tumAktifKategoriler.firstWhere(
        (k) => k.id == _selectedAltKategoriId,
        orElse: () => Kategori(id: '', ad: ''),
      );
      altKategoriAd = altKategori.ad;
    }

    double alisFiyati = double.tryParse(_alisFiyatiController.text) ?? 0;
    double kdvOrani = double.tryParse(_kdvOraniController.text) ?? 0;

    if (_kdvDahilMi) {
      alisFiyati = alisFiyati / (1 + kdvOrani / 100);
    }

    Urun yeniUrun = Urun(
      barkod: _barkodController.text,
      urunAdi: _urunAdiController.text.toUpperCase(),
      stok: double.tryParse(_stokController.text) ?? 0,
      kritikStok: double.tryParse(_kritikStokController.text) ?? 0,
      birim: _selectedBirim,
      stokKodu: _stokKoduController.text.isNotEmpty ? _stokKoduController.text : null,
      alisFiyati: alisFiyati,
      karOrani: double.tryParse(_karOraniController.text) ?? 0,
      satisFiyati: double.tryParse(_satisFiyatiController.text) ?? 0,
      anaKategori: anaKategoriAd,
      altKategori: altKategoriAd,
      tedarikci: _tedarikciController.text,
      tedarikTarihi: _tedarikTarihiController.text,
      notlar: _notlarController.text,
    );

    final urunProvider = Provider.of<UrunProvider>(context, listen: false);
    if (urunProvider.barkodlaUrunBul(_barkodController.text) != null) {
      urunProvider.urunGuncelle(yeniUrun);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ürün başarıyla güncellendi!')),
      );
    } else {
      urunProvider.urunEkle(yeniUrun);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ürün başarıyla eklendi!')),
      );
    }

    _alanlariTemizle();
  }

  @override
  void dispose() {
    _barkodController.dispose();
    _urunAdiController.dispose();
    _stokController.dispose();
    _kritikStokController.dispose();
    _stokKoduController.dispose();
    _alisFiyatiController.dispose();
    _kdvOraniController.dispose();
    _karOraniController.dispose();
    _satisFiyatiController.dispose();
    _tedarikciController.dispose();
    _tedarikTarihiController.dispose();
    _notlarController.dispose();
    super.dispose();
  }
}