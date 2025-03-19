import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import '../providers/urun_provider.dart';
import '../models/urun_model.dart';

class SalesViewWeb extends StatefulWidget {
  const SalesViewWeb({super.key});

  @override
  State<SalesViewWeb> createState() => _SalesViewWebState();
}

class _SalesViewWebState extends State<SalesViewWeb> {
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

  void _barkodGirildi(String barkod) {
    final urunProvider = Provider.of<UrunProvider>(context, listen: false);
    var urun = urunProvider.urunler.firstWhere(
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
      _urunEkle(urun);
      _barkodController.clear(); // Barkod alanını temizle
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Hata'),
          content: Text('Barkod bulunamadı!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Tamam'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Sol Taraf: Barkod ve Ürün Listesi
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Barkod Okuma ve Arama Alanı
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _barkodController,
                        decoration: InputDecoration(
                          labelText: 'Barkod',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (barkod) {
                          _barkodGirildi(barkod); // Enter tuşuna basıldığında çalışır
                        },
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
                          _barkodGirildi(result.rawContent);
                        }
                      },
                    ),
                  ],
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
              ],
            ),
          ),
        ),
        // Sağ Taraf: Ödeme Bilgileri ve Butonlar
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text('Ödenen: 0.00₺'),
                Text('Tutar: ${_toplamTutar.toStringAsFixed(2)}₺'),
                Text('Para Üstü: 0.00₺'),
                SizedBox(height: 20),
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
        ),
      ],
    );
  }
}