import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/urun_provider.dart';
import '../models/urun_model.dart';

class SalesViewWeb extends StatefulWidget {
  const SalesViewWeb({super.key});

  @override
  State<SalesViewWeb> createState() => _SalesViewWebState();
}

class _SalesViewWebState extends State<SalesViewWeb> {
  final TextEditingController _barkodController = TextEditingController();
  final TextEditingController _odenmisController = TextEditingController();
  final List<Urun> _sepet = [];
  final List<Urun> _arananUrunler = [];
  double _toplamTutar = 0.0;
  double _iskonto = 0.0;
  double _paraUstu = 0.0;
  bool _iskontoYuzdeMi = true;
  bool _iadeModu = false;
  bool _aramaModu = false;

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

    // Provider'da stok güncelleme
    context.read<UrunProvider>().urunGuncelle(urun.copyWith(stok: yeniMiktar));
  }

  void _sepeteTumunuSil() {
    setState(() {
      _sepet.clear();
      _toplamTutar = 0.0;
      _iskonto = 0.0;
      _paraUstu = 0.0;
      _odenmisController.clear();
    });
    _toplamTutarHesapla();
  }

  void _temizleVeKapat() {
    _barkodController.clear();
    _arananUrunler.clear();
    setState(() {});
  }

  void _toplamTutarHesapla() {
    double toplam = _sepet.fold(
      0.0,
      (previousValue, urun) => previousValue + (urun.satisFiyati * urun.stok),
    );

    if (_iskontoYuzdeMi) {
      toplam -= toplam * (_iskonto / 100);
    } else {
      toplam -= _iskonto;
    }

    setState(() {
      _toplamTutar = toplam < 0 ? 0.0 : toplam;
      _paraUstuHesapla();
    });
  }

  void _paraUstuHesapla() {
    final odenen = double.tryParse(_odenmisController.text) ?? 0.0;
    setState(() {
      _paraUstu = odenen - _toplamTutar;
    });
  }

  void _odemeYap(String odemeTuru) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_iadeModu ? 'İade' : 'Ödeme'} Tamamlandı'),
        content: Text('$odemeTuru ile ${_toplamTutar.toStringAsFixed(2)}₺ ${_iadeModu ? 'iade edildi' : 'alındı'}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _sepet.clear();
                _toplamTutar = 0.0;
                _iskonto = 0.0;
                _odenmisController.clear();
              });
            },
            child: const Text('Tamam', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  void _urunEkle(Urun urun) {
    final index = _sepet.indexWhere((u) => u.barkod == urun.barkod);
    if (index != -1) {
      _miktarGuncelle(index, _sepet[index].stok + 1);
    } else {
      setState(() => _sepet.add(urun.copyWith(stok: 1.0)));
    }
    _temizleVeKapat();
    _toplamTutarHesapla();
  }

  void _barkodIleUrunEkle(String barkod) {
    final urun = context.read<UrunProvider>().barkodlaUrunBul(barkod);
    if (urun != null) {
      _urunEkle(urun);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ürün Bulunamadı'),
          content: Text('$barkod barkodlu ürün kayıtlı değil'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
    }
  }

  void _urunAra(String query) {
    final urunProvider = context.read<UrunProvider>();
    _arananUrunler.clear();
    if (query.isNotEmpty) {
      _arananUrunler.addAll(
        urunProvider.urunler.where((urun) =>
            urun.barkod.contains(query) ||
            urun.urunAdi.toLowerCase().contains(query.toLowerCase())),
      );
    }
    setState(() {});
  }

  Widget _buildOdemeButonu(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(double.infinity, 45),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        onPressed: () => _odemeYap(text),
        child: Text(
          _iadeModu ? '$text İade Al' : text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final urunProvider = context.watch<UrunProvider>();
    
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Row(
        children: [
          // SOL PANEL (ANA İÇERİK)
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _barkodController,
                                  decoration: const InputDecoration(
                                    hintText: 'Barkod veya Ürün Adı Ara',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                    hintStyle: TextStyle(fontSize: 14),
                                  ),
                                  onChanged: _aramaModu ? _urunAra : null,
                                  onSubmitted: _barkodIleUrunEkle,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  _aramaModu ? Icons.search_off : Icons.search,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                                onPressed: () {
                                  setState(() => _aramaModu = !_aramaModu);
                                  if (_aramaModu) _urunAra(_barkodController.text);
                                },
                              ),
                            ],
                          ),
                          if (_arananUrunler.isNotEmpty)
                            SizedBox(
                              height: 180,
                              child: Card(
                                elevation: 2,
                                child: ListView.builder(
                                  itemCount: _arananUrunler.length,
                                  itemBuilder: (context, index) {
                                    final urun = _arananUrunler[index];
                                    return ListTile(
                                      title: Text(urun.urunAdi.toUpperCase(), style: const TextStyle(fontSize: 14)),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Barkod: ${urun.barkod}', style: const TextStyle(fontSize: 12)),
                                          Text('Fiyat: ${urun.satisFiyati.toStringAsFixed(2)}₺', style: const TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                      onTap: () => _urunEkle(urun),
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: _sepeteTumunuSil,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'ÜRÜN BİLGİLERİ',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 90),
                        const Text(
                          'MİKTAR',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Card(
                      elevation: 4,
                      child: ListView.builder(
                        itemCount: _sepet.length,
                        itemBuilder: (context, index) {
                          final urun = _sepet[index];
                          return Container(
                            color: index % 2 == 0 ? Colors.blue[50] : Colors.white,
                            child: ListTile(
                              leading: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () => _miktarGuncelle(index, 0.0),
                              ),
                              title: Text(
                                urun.urunAdi.toUpperCase(),
                                style: const TextStyle(fontSize: 14),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Barkod: ${urun.barkod}', style: const TextStyle(fontSize: 12)),
                                  Text('Birim Fiyat: ${urun.satisFiyati.toStringAsFixed(2)}₺', style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, color: Colors.red, size: 20),
                                    onPressed: () => _miktarGuncelle(index, urun.stok - 1.0),
                                  ),
                                  SizedBox(
                                    width: 90,
                                    child: TextField(
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                      ),
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                      controller: TextEditingController(
                                        text: urun.stok.toStringAsFixed(2),
                                      ),
                                      style: const TextStyle(fontSize: 12),
                                      onSubmitted: (value) {
                                        double yeniMiktar = double.tryParse(value) ?? urun.stok;
                                        _miktarGuncelle(index, yeniMiktar);
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, color: Colors.green, size: 20),
                                    onPressed: () => _miktarGuncelle(index, urun.stok + 1.0),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ORTA PANEL (ÜRÜN LİSTESİ)
          SizedBox(
            width: 350,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                children: [
                  const Text(
                    'ÜRÜN LİSTESİ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Card(
                      elevation: 4,
                      child: ListView.builder(
                        itemCount: urunProvider.urunler.length,
                        itemBuilder: (context, index) {
                          final urun = urunProvider.urunler[index];
                          return Container(
                            color: index % 2 == 0 ? Colors.blue[50] : Colors.white,
                            child: ListTile(
                              title: Text(
                                urun.urunAdi.toUpperCase(),
                                style: const TextStyle(fontSize: 14),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Barkod: ${urun.barkod}', style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.add, color: Colors.green, size: 20),
                                onPressed: () => _urunEkle(urun),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // SAĞ PANEL (ÖDEME)
          SizedBox(
            width: 350,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'İskonto',
                                    border: OutlineInputBorder(),
                                    labelStyle: TextStyle(fontSize: 14),
                                  ),
                                  style: const TextStyle(fontSize: 14),
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
                                  DropdownMenuItem(
                                    value: true,
                                    child: Text('%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                  ),
                                  DropdownMenuItem(
                                    value: false,
                                    child: Text('₺', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                                onChanged: (value) => setState(() {
                                  _iskontoYuzdeMi = value ?? true;
                                  _toplamTutarHesapla();
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('TOPLAM TUTAR', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text(
                                '${_toplamTutar.toStringAsFixed(2)}₺',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text('ÖDENEN', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              TextField(
                                controller: _odenmisController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 14),
                                decoration: const InputDecoration(
                                  suffixText: '₺',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                ),
                                onChanged: (value) => _paraUstuHesapla(),
                              ),
                              const SizedBox(height: 12),
                              const Text('PARA ÜSTÜ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text(
                                '${_paraUstu.toStringAsFixed(2)}₺',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _paraUstu >= 0 ? Colors.green[700] : Colors.red[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildOdemeButonu('Nakit', Colors.green),
                          _buildOdemeButonu('Pos', Colors.blue),
                          _buildOdemeButonu('Açık Hesap', Colors.orange),
                          _buildOdemeButonu('Parçalı Ödeme', Colors.purple),
                        ],
                      ),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('İade Modu', style: TextStyle(fontSize: 14)),
                    value: _iadeModu,
                    onChanged: (value) => setState(() => _iadeModu = value),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}