import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:open_file/open_file.dart';
import '../providers/urun_provider.dart';
import '../models/urun_model.dart';

class Urunler extends StatefulWidget {
  const Urunler({super.key}); // super.key kullanıldı

  @override
  State<Urunler> createState() => _UrunlerState();
}

class _UrunlerState extends State<Urunler> {
  @override
  Widget build(BuildContext context) {
    final urunProvider = Provider.of<UrunProvider>(context);
    final urunler = urunProvider.urunler;

    return Scaffold(
      appBar: AppBar(
        title: Text('Ürünler'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () {
              // Excel'e ürün dışa aktarma işlemi
              _urunleriExceleAktar(context, urunler);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: urunler.length,
        itemBuilder: (context, index) {
          final urun = urunler[index];
          return ListTile(
            title: Text(urun.urunAdi),
            subtitle: Text('Barkod: ${urun.barkod} - Stok: ${urun.stok}'),
            trailing: Text('${urun.satisFiyati.toStringAsFixed(2)} TL'),
          );
        },
      ),
    );
  }

  void _urunleriExceleAktar(BuildContext context, List<Urun> urunler) async {
    // Excel dosyasını oluştur
    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];

    // Başlık satırı
    sheet.appendRow(['Barkod', 'Ürün Adı', 'Stok', 'Alış Fiyatı', 'Kar Oranı', 'Satış Fiyatı']);

    // Ürünleri Excel'e yazma
    for (var urun in urunler) {
      sheet.appendRow([
        urun.barkod,
        urun.urunAdi,
        urun.stok.toString(),
        urun.alisFiyati.toString(),
        urun.karOrani.toString(),
        urun.satisFiyati.toString(),
      ]);
    }

    // Dosya yolunu belirle
    final directory = await getApplicationDocumentsDirectory(); // Documents klasörü
    final filePath = '${directory.path}/urunler.xlsx'; // Dosya yolu

    // Dosyayı kaydet
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    // Dosyayı aç
    OpenFile.open(filePath);

    // BuildContext'in hala geçerli olup olmadığını kontrol et
    if (mounted) {
      // Başarılı mesajı göster
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ürünler Excel\'e başarıyla aktarıldı. Dosya: $filePath')),
      );
    }
  }
}