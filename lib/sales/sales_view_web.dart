import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/product_provider.dart';
import '../models/product_model.dart';

class SalesViewWeb extends StatefulWidget {
  const SalesViewWeb({super.key});

  @override
  State<SalesViewWeb> createState() => _SalesViewWebState();
}

class _SalesViewWebState extends State<SalesViewWeb> {
  final TextEditingController _barkodController = TextEditingController();
  final TextEditingController _odenmisController = TextEditingController();
  final TextEditingController _muhtelifUrunController = TextEditingController();
  final TextEditingController _muhtelifTutarController = TextEditingController();
  final List<Urun> _sepet = [];
  final List<Urun> _arananUrunler = [];
  double _toplamTutar = 0.0;
  double _iskonto = 0.0;
  double _paraUstu = 0.0;
  bool _iskontoYuzdeMi = true;
  bool _iadeModu = false;
  bool _aramaModu = false;
  int _muhtelifCounter = 1;
  final SupabaseClient _supabase = Supabase.instance.client;

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

    Provider.of<UrunProvider>(context, listen: false)
        .urunGuncelle(urun.copyWith(stok: yeniMiktar));
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
        title: Text('${_iadeModu ? 'İade' : 'Ödeme'} Tamamlandı',
            style: TextStyle(color: _iadeModu ? Colors.red : Colors.green)),
        content: Text('$odemeTuru ile ${_toplamTutar.toStringAsFixed(2)}₺ ${_iadeModu ? 'iade edildi' : 'alındı'}',
            style: const TextStyle(fontSize: 16)),
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

  Future<void> _urunEkle(Urun urun) async {
    final index = _sepet.indexWhere((u) => u.barkod == urun.barkod);
    if (index != -1) {
      _miktarGuncelle(index, _sepet[index].stok + 1);
    } else {
      setState(() => _sepet.add(urun.copyWith(stok: 1.0)));
    }
    _temizleVeKapat();
    _toplamTutarHesapla();
  }

  Future<void> _barkodIleUrunEkle(String barkod) async {
    final urun = await Provider.of<UrunProvider>(context, listen: false)
        .barkodlaUrunBul(barkod);
    if (urun != null) {
      await _urunEkle(urun);
    } else {
      if (mounted) {
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
  }

  void _muhtelifUrunEkle() {
    if (_muhtelifTutarController.text.isNotEmpty) {
      final tutar = double.tryParse(_muhtelifTutarController.text) ?? 0.0;
      final urunAdi = _muhtelifUrunController.text.isEmpty
          ? 'Muhtelif Ürün - ${tutar.toStringAsFixed(2)}₺'
          : _muhtelifUrunController.text;

      final firmaId = _supabase.auth.currentUser?.id;
      final userEmail = _supabase.auth.currentUser?.email;
      final firmaAdi = 'Firma Adı'; // Gerçek firma adını buraya ekleyin

      if (firmaId == null || userEmail == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kullanıcı girişi yapılmamış')),
          );
        }
        return;
      }

      final yeniUrun = Urun(
        barkod: 'MUHTELIF-${_muhtelifCounter++}',
        urunAdi: urunAdi,
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
        firmaId: firmaId,
        firmaAdi: firmaAdi,
        userEmail: userEmail,
      );
      _urunEkle(yeniUrun);
      _muhtelifUrunController.clear();
      _muhtelifTutarController.clear();
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: _iadeModu
                  ? const Color.fromRGBO(255, 0, 0, 0.2)
                  : const Color.fromRGBO(0, 255, 0, 0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 1.5),
            )
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            minimumSize: const Size(double.infinity, 50),
            side: BorderSide(
              color: _iadeModu
                  ? const Color.fromARGB(255, 255, 0, 0)
                  : const Color.fromARGB(255, 0, 255, 0),
              width: 2.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.2),
          ),
          onPressed: () => _odemeYap(text),
          child: Text(
            _iadeModu ? '$text İade Al' : text,
            style: TextStyle(
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 5,
                  color: _iadeModu
                      ? const Color.fromARGB(255, 255, 0, 0)
                      : const Color.fromARGB(255, 0, 255, 0),
                  offset: Offset.zero,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDivider() {
    return SizedBox(
      height: 1,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange,
              const Color.fromRGBO(255, 165, 0, 0.05)
            ],
            stops: const [0.4, 1.0],
            begin: Alignment.center,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }

  Widget _buildSepetBaslik() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                _sepet.clear();
                _toplamTutarHesapla();
              });
            },
          ),
          const SizedBox(width: 10),
          Text(
            'Ürün Bilgisi (${_sepet.map((e) => e.barkod).toSet().length} Barkod)',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            'Miktar: ${_sepet.fold(0.0, (sum, urun) => sum + urun.stok).toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
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
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
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
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 15),
                                    hintStyle: TextStyle(fontSize: 16)),
                                  onChanged: _aramaModu ? _urunAra : null,
                                  onSubmitted: _barkodIleUrunEkle,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  _aramaModu ? Icons.search_off : Icons.search,
                                  color: Colors.blue,
                                  size: 32),
                                onPressed: () {
                                  setState(() => _aramaModu = !_aramaModu);
                                  if (_aramaModu) _urunAra(_barkodController.text);
                                },
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: TextField(
                                    controller: _muhtelifUrunController,
                                    decoration: const InputDecoration(
                                      labelText: 'Muhtelif ürün',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 20)),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: _muhtelifTutarController,
                                    decoration: const InputDecoration(
                                      labelText: 'Muhtelif Tutar',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 15),
                                      prefixText: '₺ '),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle,
                                      color: Colors.green,
                                      size: 40),
                                  onPressed: _muhtelifUrunEkle,
                                ),
                              ],
                            ),
                          ),
                          if (_arananUrunler.isNotEmpty)
                            SizedBox(
                              height: 200,
                              child: Card(
                                elevation: 3,
                                shadowColor: Colors.black12,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListView.builder(
                                  itemCount: _arananUrunler.length,
                                  itemBuilder: (context, index) {
                                    final urun = _arananUrunler[index];
                                    return Column(
                                      children: [
                                        ListTile(
                                          title: Text(urun.urunAdi.toUpperCase(),
                                              style: const TextStyle(fontSize: 16)),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Barkod: ${urun.barkod}',
                                                  style: const TextStyle(fontSize: 14)),
                                              Text('Fiyat: ${urun.satisFiyati.toStringAsFixed(2)}₺',
                                                  style: const TextStyle(fontSize: 14)),
                                            ],
                                          ),
                                          onTap: () => _urunEkle(urun),
                                        ),
                                        _buildCustomDivider(),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildSepetBaslik(),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Card(
                      elevation: 4,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListView.builder(
                        itemCount: _sepet.length,
                        itemBuilder: (context, index) {
                          final urun = _sepet[index];
                          return Column(
                            children: [
                              ListTile(
                                leading: IconButton(
                                  icon: const Icon(Icons.delete_forever,
                                      color: Colors.red,
                                      size: 28),
                                  onPressed: () => _miktarGuncelle(index, 0.0),
                                ),
                                title: Text(
                                  urun.urunAdi.toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Barkod: ${urun.barkod}',
                                        style: const TextStyle(fontSize: 14)),
                                    Text('Birim Fiyat: ${urun.satisFiyati.toStringAsFixed(2)}₺',
                                        style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle,
                                          color: Colors.red,
                                      size: 28),
                                      onPressed: () => _miktarGuncelle(index, urun.stok - 1.0),
                                    ),
                                    SizedBox(
                                      width: 100,
                                      child: TextField(
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 12)),
                                        keyboardType: TextInputType.numberWithOptions(
                                            decimal: true),
                                        controller: TextEditingController(
                                          text: urun.stok.toStringAsFixed(2)),
                                        style: const TextStyle(fontSize: 14),
                                        onSubmitted: (value) {
                                          double yeniMiktar =
                                              double.tryParse(value) ?? urun.stok;
                                          _miktarGuncelle(index, yeniMiktar);
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle,
                                          color: Colors.green,
                                          size: 28),
                                      onPressed: () => _miktarGuncelle(index, urun.stok + 1.0),
                                    ),
                                  ],
                                ),
                              ),
                              _buildCustomDivider(),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        'ÜRÜN LİSTESİ',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 7, 57, 101))),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Card(
                      elevation: 4,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListView.builder(
                        itemCount: urunProvider.urunler.length,
                        itemBuilder: (context, index) {
                          final urun = urunProvider.urunler[index];
                          return Column(
                            children: [
                              ListTile(
                                title: Text(
                                  urun.urunAdi.toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                                subtitle: Text('Barkod: ${urun.barkod}',
                                    style: const TextStyle(fontSize: 14)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.add_box,
                                      color: Color.fromARGB(255, 0, 161, 5),
                                      size: 32),
                                  onPressed: () => _urunEkle(urun),
                                ),
                              ),
                              _buildCustomDivider(),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'İskonto',
                                    border: OutlineInputBorder(),
                                    labelStyle: TextStyle(fontSize: 16)),
                                  style: const TextStyle(fontSize: 16),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      _iskonto = double.tryParse(value) ?? 0.0;
                                      _toplamTutarHesapla();
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              DropdownButton<bool>(
                                value: _iskontoYuzdeMi,
                                items: const [
                                  DropdownMenuItem(
                                    value: true,
                                    child: Text('%',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  DropdownMenuItem(
                                    value: false,
                                    child: Text('₺',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                                onChanged: (value) => setState(() {
                                  _iskontoYuzdeMi = value ?? true;
                                  _toplamTutarHesapla();
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('TOPLAM TUTAR',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey)),
                              Text(
                                '${_toplamTutar.toStringAsFixed(2)}₺',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                  shadows: [
                                    const Shadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.1),
                                      blurRadius: 5,
                                      offset: Offset(1.5, 1.5),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15),
                              const Text('ÖDENEN',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey)),
                              TextField(
                                controller: _odenmisController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 18),
                                decoration: const InputDecoration(
                                  suffixText: '₺',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 15),
                                ),
                                onChanged: (value) => _paraUstuHesapla(),
                              ),
                              const SizedBox(height: 15),
                              const Text('PARA ÜSTÜ',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey)),
                              Text(
                                '${_paraUstu.toStringAsFixed(2)}₺',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: _paraUstu >= 0
                                      ? const Color.fromRGBO(0, 100, 0, 1)
                                      : const Color.fromRGBO(139, 0, 0, 1),
                                  shadows: [
                                    const Shadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.1),
                                      blurRadius: 5,
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildOdemeButonu('Nakit', const Color.fromARGB(255, 7, 232, 14)),
                          _buildOdemeButonu('Pos', const Color.fromARGB(255, 2, 109, 197)),
                          _buildOdemeButonu('Açık Hesap', const Color.fromARGB(255, 255, 154, 1)),
                          _buildOdemeButonu('Parçalı Ödeme', const Color.fromARGB(255, 169, 2, 198)),
                        ],
                      ),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('İade Modu',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    activeColor: Colors.red,
                    inactiveThumbColor: const Color.fromARGB(255, 0, 97, 3),
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