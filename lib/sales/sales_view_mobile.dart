import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import '../providers/urun_provider.dart';
import '../models/urun_model.dart';

class SalesViewMobile extends StatefulWidget {
  const SalesViewMobile({super.key});

  @override
  State<SalesViewMobile> createState() => _SalesViewMobileState();
}

class _SalesViewMobileState extends State<SalesViewMobile> {
  final TextEditingController _barkodController = TextEditingController();
  final List<Urun> _sepet = [];
  double _toplamTutar = 0.0;

  void _urunEkle(Urun urun) {
    setState(() {
      var urunIndex = _sepet.indexWhere((u) => u.barkod == urun.barkod);
      if (urunIndex != -1) {
        // Ürün zaten sepette, miktarını artır
        _sepet[urunIndex] = _sepet[urunIndex].copyWith(stok: _sepet[urunIndex].stok + 1);
      } else {
        // Ürünü sepete ekle
        _sepet.add(urun.copyWith(stok: 1));
      }
      _toplamTutarHesapla();
    });
  }

  void _toplamTutarHesapla() {
    _toplamTutar = _sepet.fold(0.0, (sum, urun) => sum + (urun.satisFiyati * urun.stok));
  }

  void _urunSil(int index) {
    setState(() {
      _sepet.removeAt(index);
      _toplamTutarHesapla();
    });
  }

  void _odemeYap(String odemeTuru) {
    // Ödeme işlemleri burada yapılabilir
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ödeme Başarılı'),
        content: Text('$odemeTuru ile ödeme yapıldı.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final urunProvider = Provider.of<UrunProvider>(context);

    return Column(
      children: [
        // Barkod Okuma ve Arama Alanı
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _barkodController,
                  decoration: InputDecoration(
                    labelText: 'Barkod',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Arama'),
                      content: Text('Ürün adı ya da barkod ile ara'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Tamam'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.qr_code_scanner),
                onPressed: () async {
                  // Barkod tarama işlemi
                  var result = await BarcodeScanner.scan();
                  if (result.rawContent.isNotEmpty) {
                    _barkodController.text = result.rawContent;
                    var urun = urunProvider.urunler.firstWhere(
                      (u) => u.barkod == result.rawContent,
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
                      _urunEkle(urun);
                    }
                  }
                },
              ),
            ],
          ),
        ),
        // Toplam Tutar Gösterimi
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Toplam Tutar: ${_toplamTutar.toStringAsFixed(2)}₺',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // Ürün Listesi
        Expanded(
          child: ListView.builder(
            itemCount: _sepet.length,
            itemBuilder: (context, index) {
              final urun = _sepet[index];
              return ListTile(
                leading: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _urunSil(index),
                ),
                title: Text(
                  urun.urunAdi,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: Text(urun.barkod),
                    ),
                    Text('${urun.satisFiyati.toStringAsFixed(2)}₺'),
                  ],
                ),
                trailing: Text(
                  '${(urun.satisFiyati * urun.stok).toStringAsFixed(2)}₺',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ),
        // Ödeme Butonları
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _odemeYap('Nakit'),
                child: Text('Nakit'),
              ),
              ElevatedButton(
                onPressed: () => _odemeYap('Pos'),
                child: Text('Pos'),
              ),
              ElevatedButton(
                onPressed: () => _odemeYap('Açık Hesap'),
                child: Text('Açık Hesap'),
              ),
              ElevatedButton(
                onPressed: () => _odemeYap('Parçalı Ödeme'),
                child: Text('Parçalı Ödeme'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}