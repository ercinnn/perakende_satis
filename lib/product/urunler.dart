import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart'; // path_provider paketi
import 'package:excel/excel.dart';
import 'package:open_file/open_file.dart'; // open_file paketi
import 'package:file_selector/file_selector.dart'; // file_selector paketi
import '../providers/urun_provider.dart';
import '../models/urun_model.dart';

class Urunler extends StatefulWidget {
  const Urunler({super.key});

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
            icon: Icon(Icons.upload),
            onPressed: () {
              // Excel'den ürün ekleme işlemi
              _urunleriExceldenEkle();
            },
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () {
              // Excel'e ürün dışa aktarma işlemi
              _urunleriExceleAktar(urunler);
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

  void _urunleriExceleAktar(List<Urun> urunler) async {
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

    // Başarılı mesajı göster
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ürünler Excel\'e başarıyla aktarıldı. Dosya: $filePath')),
      );
    }
  }

  void _urunleriExceldenEkle() async {
    try {
      // Kullanıcıdan Excel dosyası seçmesini iste
      final XFile? file = await openFile(acceptedTypeGroups: [
        XTypeGroup(label: 'Excel Files', extensions: ['xlsx']),
      ]);

      if (file != null) {
        // Seçilen dosyayı oku
        final bytes = await file.readAsBytes();

        // Excel dosyasını oku
        var excel = Excel.decodeBytes(bytes);

        // İlk sayfayı al
        var sheet = excel.tables[excel.tables.keys.first];

        // Ürün sayısını belirle
        int urunSayisi = sheet!.rows.length - 1; // Başlık satırını çıkar

        // Ürünleri eklemek için bir liste oluştur
        List<Urun> eklenecekUrunler = [];

        // Satırları rezerve et ve verileri oku
        for (int i = 1; i <= urunSayisi; i++) {
          var row = sheet.rows[i];

          // Nullable değerleri kontrol et
          if (row[0]?.value != null && row[0]!.value.toString().isNotEmpty) {
            Urun yeniUrun = Urun(
              barkod: row[0]!.value.toString(),
              urunAdi: row[1]?.value.toString() ?? '',
              stok: int.tryParse(row[2]?.value.toString() ?? '0') ?? 0,
              alisFiyati: double.tryParse(row[3]?.value.toString() ?? '0') ?? 0,
              karOrani: double.tryParse(row[4]?.value.toString() ?? '0') ?? 0,
              satisFiyati: double.tryParse(row[5]?.value.toString() ?? '0') ?? 0,
            );
            eklenecekUrunler.add(yeniUrun);
          }
        }

        // Provider.of çağrısını asenkron işlemlerden önce yap
        if (mounted) {
          final urunProvider = Provider.of<UrunProvider>(context, listen: false);

          // Ürünleri ekle
          urunProvider.urunleriEkle(eklenecekUrunler);

          // Başarılı mesajı göster
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$urunSayisi adet ürün başarıyla eklendi!')),
          );
        }
      } else {
        // Kullanıcı dosya seçmedi
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Dosya seçilmedi!')),
          );
        }
      }
    } catch (e) {
      // Hata durumunda mesaj göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }
}