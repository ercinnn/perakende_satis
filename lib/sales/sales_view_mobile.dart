import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import '../../providers/urun_provider.dart';
import '../../models/urun_model.dart';

class SalesViewMobile extends StatefulWidget {
  const SalesViewMobile({super.key});

  @override
  State<SalesViewMobile> createState() => _SalesViewMobileState();
}

class _SalesViewMobileState extends State<SalesViewMobile> {
  final TextEditingController _barkodController = TextEditingController();
  final TextEditingController _musteriController = TextEditingController();
  final TextEditingController _satisNotController = TextEditingController();
  final TextEditingController _muhtelifAdController = TextEditingController(text: 'Muhtelif Ürün');
  final TextEditingController _muhtelifTutarController = TextEditingController();
  final List<Urun> _sepet = [];
  double _toplamTutar = 0.0;
  double _brutTutar = 0.0;
  double _iskonto = 0.0;
  bool _iskontoYuzdeMi = true;
  bool _iadeModu = false;
  final Map<String, bool> _fiyatGuncelleDurumu = {};
  int _muhtelifCounter = 1;

  // Sepetteki farklı barkod sayısını hesapla
  int get _farkliBarkodSayisi {
    final barkodlar = _sepet.map((urun) => urun.barkod).toSet();
    return barkodlar.length;
  }

  void _showUrunAramaModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        List<Urun> filteredUrunler = context.read<UrunProvider>().urunler;

        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                children: [
                  TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Ürün ara...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      filteredUrunler = context
                          .read<UrunProvider>()
                          .urunler
                          .where((urun) =>
                              urun.urunAdi.toLowerCase().contains(value.toLowerCase()) ||
                              urun.barkod.contains(value))
                          .toList();
                      setState(() {});
                    },
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredUrunler.length,
                      itemBuilder: (context, index) {
                        final urun = filteredUrunler[index];
                        return ListTile(
                          title: Text(urun.urunAdi, style: Theme.of(context).textTheme.bodyLarge),
                          subtitle: Text('Barkod: ${urun.barkod}', style: Theme.of(context).textTheme.bodyMedium),
                          trailing: Text('${urun.satisFiyati.toStringAsFixed(2)} TL', style: Theme.of(context).textTheme.bodyLarge),
                          onTap: () {
                            _urunEkle(urun.barkod);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _miktarGuncelle(int index, double yeniMiktar) {
    final urun = _sepet[index];
    setState(() {
      if (yeniMiktar <= 0) {
        _sepet.removeAt(index);
      } else {
        _sepet[index] = urun.copyWith(stok: yeniMiktar);
      }
      _toplamTutarHesapla();
    });
  }

  void _toplamTutarHesapla() {
    _brutTutar = _sepet.fold(0.0, (sum, urun) => sum + (urun.satisFiyati * urun.stok));
    
    double toplam = _brutTutar;
    if (_iskontoYuzdeMi) {
      toplam -= toplam * (_iskonto / 100);
    } else {
      toplam -= _iskonto;
    }
    
    setState(() {
      _toplamTutar = toplam < 0 ? 0.0 : toplam;
    });
  }

  void _odemeYap(String odemeTuru) {
    for (final urun in _sepet) {
      if (_fiyatGuncelleDurumu[urun.barkod] ?? false) {
        context.read<UrunProvider>().urunFiyatGuncelle(urun.barkod, urun.satisFiyati);
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_iadeModu ? 'İade' : 'Ödeme'} Tamamlandı',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _iadeModu ? Colors.red : Colors.green,
            )),
        content: Text('$odemeTuru ile ${_toplamTutar.toStringAsFixed(2)} TL ${_iadeModu ? 'iade edildi' : 'alındı'}',
            style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _sepet.clear();
                _toplamTutar = 0.0;
                _brutTutar = 0.0;
                _iskonto = 0.0;
                _muhtelifTutarController.clear();
                _fiyatGuncelleDurumu.clear();
              });
            },
            child: const Text('Tamam', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Future<void> _barkodTara() async {
    var result = await BarcodeScanner.scan();
    if (!mounted) return;
    
    if (result.rawContent.isNotEmpty) {
      _urunEkle(result.rawContent);
      _barkodController.clear();
    }
  }

  void _urunEkle(String barkod) {
    final urun = context.read<UrunProvider>().barkodlaUrunBul(barkod);
    if (urun != null) {
      final index = _sepet.indexWhere((u) => u.barkod == barkod);
      setState(() {
        if (index != -1) {
          _sepet[index] = urun.copyWith(stok: _sepet[index].stok + 1);
        } else {
          _sepet.add(urun.copyWith(stok: 1));
        }
        _toplamTutarHesapla();
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ürün Bulunamadı', style: TextStyle(fontSize: 16)),
          content: Text('$barkod barkodlu ürün kayıtlı değil', style: Theme.of(context).textTheme.bodyMedium),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tamam', style: TextStyle(fontSize: 14)))],
        ),
      );
    }
    _barkodController.clear();
  }

  Widget _buildSepetItem(int index) {
    final urun = _sepet[index];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: IconButton(
          icon: const Icon(Icons.remove_circle, color: Colors.red, size: 24),
          onPressed: () => _miktarGuncelle(index, urun.stok - 1),
        ),
        title: Text(urun.urunAdi, style: Theme.of(context).textTheme.bodyLarge),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Barkod: ${urun.barkod}', style: Theme.of(context).textTheme.bodyMedium),
            Text('Birim Fiyat: ${urun.satisFiyati.toStringAsFixed(2)} TL', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${urun.stok.toStringAsFixed(2)}x',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Icon(
              Icons.edit,
              color: Colors.blue,
              size: 20,
            ),
            Text(
              '${(urun.satisFiyati * urun.stok).toStringAsFixed(2)} TL',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        onTap: () => _showMiktarDialog(index, urun),
      ),
    );
  }

  void _showMiktarDialog(int index, Urun urun) {
    final TextEditingController miktarController = TextEditingController(text: urun.stok.toStringAsFixed(2));
    final TextEditingController fiyatController = TextEditingController(text: urun.satisFiyati.toStringAsFixed(2));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Miktar Güncelle',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.red),
                          onPressed: () {
                            final yeniMiktar = (double.tryParse(miktarController.text) ?? 0.0) - 1;
                            if (yeniMiktar >= 0) {
                              miktarController.text = yeniMiktar.toStringAsFixed(2);
                              setModalState(() {});
                            }
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: miktarController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              labelText: 'Miktar',
                              border: OutlineInputBorder(),
                            ),
                            autofocus: true,
                            onChanged: (value) => setModalState(() {}),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.green),
                          onPressed: () {
                            final yeniMiktar = (double.tryParse(miktarController.text) ?? 0.0) + 1;
                            miktarController.text = yeniMiktar.toStringAsFixed(2);
                            setModalState(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Fiyat Güncelle',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.red),
                          onPressed: () {
                            final yeniFiyat = (double.tryParse(fiyatController.text) ?? 0.0) - 1;
                            if (yeniFiyat >= 0) {
                              fiyatController.text = yeniFiyat.toStringAsFixed(2);
                              setModalState(() {});
                            }
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: fiyatController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              labelText: 'Fiyat',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) => setModalState(() {}),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.green),
                          onPressed: () {
                            final yeniFiyat = (double.tryParse(fiyatController.text) ?? 0.0) + 1;
                            fiyatController.text = yeniFiyat.toStringAsFixed(2);
                            setModalState(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setModalState(() {
                          _fiyatGuncelleDurumu[urun.barkod] = 
                            !(_fiyatGuncelleDurumu[urun.barkod] ?? false);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: 
                          (_fiyatGuncelleDurumu[urun.barkod] ?? false) 
                            ? Colors.green 
                            : Colors.grey,
                        minimumSize: const Size(double.infinity, 40),
                      ),
                      child: const Text('Ürün Fiyatını Kalıcı Olarak Güncelle'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            final yeniMiktar = double.tryParse(miktarController.text) ?? 0.0;
                            final yeniFiyat = double.tryParse(fiyatController.text) ?? urun.satisFiyati;

                            setState(() {
                              _sepet[index] = urun.copyWith(
                                stok: yeniMiktar,
                                satisFiyati: yeniFiyat
                              );
                              _toplamTutarHesapla();
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Kaydet'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('İptal'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMuhtelifDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Muhtelif Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _muhtelifAdController,
              decoration: const InputDecoration(
                labelText: 'Ürün Adı',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _muhtelifTutarController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tutar (₺)',
                border: OutlineInputBorder(),
              ),
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
              final tutar = double.tryParse(_muhtelifTutarController.text) ?? 0.0;
              if (tutar > 0) {
                final yeniUrun = Urun(
                  barkod: 'MUHTELIF-${_muhtelifCounter++}',
                  urunAdi: _muhtelifAdController.text,
                  stok: 1,
                  alisFiyati: 0,
                  karOrani: 0,
                  satisFiyati: tutar,
                  kritikStok: 0,
                  anaKategori: 'Muhtelif',
                  altKategori: 'Genel',
                  tedarikci: '-',
                  tedarikTarihi: DateTime.now().toString(),
                  notlar: 'Elle eklenen ürün',
                );
                setState(() {
                  _sepet.add(yeniUrun);
                  _toplamTutarHesapla();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  Widget _buildOdemeButonu(String text, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(80, 60),
          padding: const EdgeInsets.all(4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () => _odemeYap(text),
        child: Text(
          _iadeModu ? '$text\nİade Al' : text,
          textAlign: TextAlign.center,
          softWrap: true,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade200,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('Barkod', style: TextStyle(fontSize: 12)),
                        Text(
                          _farkliBarkodSayisi.toString(),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Miktar', style: TextStyle(fontSize: 12)),
                        Text(
                          _sepet.fold(0.0, (sum, urun) => sum + urun.stok).toStringAsFixed(0),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Brüt', style: TextStyle(fontSize: 12)),
                        Text(
                          _brutTutar.toStringAsFixed(2),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('İskonto', style: TextStyle(fontSize: 12)),
                        Text(
                          '${_iskonto.toStringAsFixed(2)} ${_iskontoYuzdeMi ? '%' : '₺'}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Tutar', style: TextStyle(fontSize: 12)),
                        Text(
                          _toplamTutar.toStringAsFixed(2),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _iadeModu ? Colors.red : Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'İskonto',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _iskonto = double.tryParse(value) ?? 0.0;
                            _toplamTutarHesapla();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<bool>(
                      value: _iskontoYuzdeMi,
                      items: const [
                        DropdownMenuItem(value: true, child: Text('%', style: TextStyle(fontSize: 14))),
                        DropdownMenuItem(value: false, child: Text('₺', style: TextStyle(fontSize: 14))),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _iskontoYuzdeMi = value ?? true;
                          _toplamTutarHesapla();
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          minimumSize: const Size(0, 50),
                        ),
                        onPressed: _showMuhtelifDialog,
                        child: const Text('Muhtelif', 
                          style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _iadeModu ? Colors.red : Colors.grey,
                        minimumSize: const Size(80, 50),
                      ),
                      onPressed: () => setState(() => _iadeModu = !_iadeModu),
                      child: Text(
                        'İade',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: _iadeModu ? Colors.white : Colors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _barkodController,
                        decoration: InputDecoration(
                          hintText: 'Barkod ara...',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.qr_code_scanner, color: Colors.blue),
                            onPressed: _barkodTara,
                          ),
                        ),
                        onSubmitted: (value) {
                          _urunEkle(value);
                          _barkodController.clear();
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.blue),
                      onPressed: _showUrunAramaModal,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _sepet.isEmpty
                ? Center(child: Text('Sepetiniz boş', style: Theme.of(context).textTheme.bodyLarge))
                : ListView.builder(
                    itemCount: _sepet.length,
                    itemBuilder: (context, index) => _buildSepetItem(index),
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey.shade200,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _musteriController,
                        decoration: const InputDecoration(
                          hintText: 'Müşteri...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.blue),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _satisNotController,
                  decoration: const InputDecoration(
                    hintText: 'Satış Notu...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOdemeButonu('Nakit', Colors.green),
                    _buildOdemeButonu('Pos', Colors.blue),
                    _buildOdemeButonu('Açık', Colors.orange),
                    _buildOdemeButonu('Parçalı', Colors.purple),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  onPressed: () {},
                  child: const Text('Ürün Grupları', 
                    style: TextStyle(color: Colors.white, fontSize: 14)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}