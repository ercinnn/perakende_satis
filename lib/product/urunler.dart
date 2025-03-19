import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart'; // Mobilde dosya işlemleri için
import 'package:excel/excel.dart';
import 'package:open_file/open_file.dart'; // Mobilde dosya açma için
import 'package:file_selector/file_selector.dart'; // Webde dosya seçme için
import 'package:universal_html/html.dart' as html; // Webde dosya indirme için
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
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Barkod: ${urun.barkod}'),
                Text('Stok: ${urun.stok}'),
                Text('Kritik Stok: ${urun.kritikStok}'),
                Text('Ana Kategori: ${urun.anaKategori}'),
                Text('Alt Kategori: ${urun.altKategori}'),
                Text('Tedarikçi: ${urun.tedarikci}'),
                Text('Tedarik Tarihi: ${urun.tedarikTarihi}'),
                Text('Notlar: ${urun.notlar}'),
                Text('Satış Fiyatı: ${urun.satisFiyati.toStringAsFixed(2)} TL'),
              ],
            ),
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
    sheet.appendRow([
      'Barkod',
      'Ürün Adı',
      'Stok',
      'Kritik Stok',
      'Alış Fiyatı',
      'Kar Oranı',
      'Satış Fiyatı',
      'Ana Kategori',
      'Alt Kategori',
      'Tedarikçi',
      'Tedarik Tarihi',
      'Notlar',
    ]);

    // Ürünleri Excel'e yazma
    for (var urun in urunler) {
      sheet.appendRow([
        urun.barkod,
        urun.urunAdi,
        urun.stok.toString(),
        urun.kritikStok.toString(),
        urun.alisFiyati.toString(),
        urun.karOrani.toString(),
        urun.satisFiyati.toString(),
        urun.anaKategori,
        urun.altKategori,
        urun.tedarikci,
        urun.tedarikTarihi,
        urun.notlar,
      ]);
    }

    // Excel dosyasını byte dizisine dönüştür
    var excelBytes = excel.encode();

    if (excelBytes != null) {
      if (kIsWeb) {
        // Webde dosya indirme işlemi
        final blob = html.Blob([excelBytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url) // anchor değişkeni kaldırıldı
          ..setAttribute('download', 'urunler.xlsx')
          ..click();
        html.Url.revokeObjectUrl(url);

        // Başarılı mesajı göster
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ürünler Excel\'e başarıyla aktarıldı. Dosya indiriliyor...')),
          );
        }
      } else {
        // Mobilde dosya kaydetme işlemi
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/urunler.xlsx';
        final file = File(filePath);
        await file.writeAsBytes(excelBytes);
        OpenFile.open(filePath);

        // Başarılı mesajı göster
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ürünler Excel\'e başarıyla aktarıldı. Dosya: $filePath')),
          );
        }
      }
    } else {
      // Hata durumunda mesaj göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Excel dosyası oluşturulamadı!')),
        );
      }
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

        // Satırları oku ve verileri işle
        for (int i = 1; i <= urunSayisi; i++) {
          var row = sheet.rows[i];

          // Nullable değerleri kontrol et
          if (row[0]?.value != null && row[0]!.value.toString().isNotEmpty) {
            Urun yeniUrun = Urun(
              barkod: row[0]!.value.toString(),
              urunAdi: row[1]?.value.toString() ?? '',
              stok: int.tryParse(row[2]?.value.toString() ?? '0') ?? 0,
              kritikStok: int.tryParse(row[3]?.value.toString() ?? '0') ?? 0,
              alisFiyati: double.tryParse(row[4]?.value.toString() ?? '0') ?? 0,
              karOrani: double.tryParse(row[5]?.value.toString() ?? '0') ?? 0,
              satisFiyati: double.tryParse(row[6]?.value.toString() ?? '0') ?? 0,
              anaKategori: row[7]?.value.toString() ?? '',
              altKategori: row[8]?.value.toString() ?? '',
              tedarikci: row[9]?.value.toString() ?? '',
              tedarikTarihi: row[10]?.value.toString() ?? '',
              notlar: row[11]?.value.toString() ?? '',
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