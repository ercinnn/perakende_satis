import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:open_file/open_file.dart';
import 'package:file_selector/file_selector.dart';
import 'package:universal_html/html.dart' as html;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/product_provider.dart';
import '../models/product_model.dart';

class Urunler extends StatefulWidget {
  const Urunler({super.key});

  @override
  State<Urunler> createState() => _UrunlerState();
}

class _UrunlerState extends State<Urunler> {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final urunProvider = Provider.of<UrunProvider>(context);
    final urunler = urunProvider.urunler;
    final firmaId = _supabase.auth.currentUser?.id ?? '';
    final userEmail = _supabase.auth.currentUser?.email ?? '';
    final firmaAdi = 'Firma Adi';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürünler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: () => _urunleriExceldenEkle(firmaId, userEmail, firmaAdi),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _urunleriExceleAktar(urunler),
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
                Text('Stok Kodu: ${urun.stokKodu ?? '-'}'),
                Text('Kritik Stok: ${urun.kritikStok}'),
                Text('Birim: ${urun.birim}'),
                Text('Ana Kategori: ${urun.anaKategori}'),
                Text('Alt Kategori: ${urun.altKategori}'),
                Text('Tedarikçi: ${urun.tedarikci ?? '-'}'),
                Text('Tedarik Tarihi: ${urun.tedarikTarihi ?? '-'}'),
                Text('Notlar: ${urun.notlar ?? '-'}'),
                Text('Satış Fiyatı: ${urun.satisFiyati.toStringAsFixed(2)} TL'),
              ],
            ),
          );
        },
      ),
    );
  }

  void _urunleriExceleAktar(List<Urun> urunler) async {
    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];

    sheet.appendRow([
      'Barkod',
      'Ürün Adı',
      'Stok',
      'Stok Kodu',
      'Kritik Stok',
      'Birim',
      'Alış Fiyatı',
      'Kar Oranı',
      'Satış Fiyatı',
      'Ana Kategori',
      'Alt Kategori',
      'Tedarikçi',
      'Tedarik Tarihi',
      'Notlar',
    ]);

    for (var urun in urunler) {
      sheet.appendRow([
        urun.barkod,
        urun.urunAdi,
        urun.stok,
        urun.stokKodu ?? '',
        urun.kritikStok,
        urun.birim,
        urun.alisFiyati,
        urun.karOrani,
        urun.satisFiyati,
        urun.anaKategori,
        urun.altKategori,
        urun.tedarikci ?? '',
        urun.tedarikTarihi ?? '',
        urun.notlar ?? '',
      ]);
    }

    var excelBytes = excel.encode();

    if (excelBytes != null) {
      if (kIsWeb) {
        final blob = html.Blob([excelBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', 'urunler.xlsx')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/urunler.xlsx');
        await file.writeAsBytes(excelBytes);
        OpenFile.open(file.path);
      }
    }
  }

  Future<void> _urunleriExceldenEkle(String firmaId, String userEmail, String firmaAdi) async {
    try {
      final XFile? file = await openFile(acceptedTypeGroups: [
        XTypeGroup(label: 'Excel Files', extensions: ['xlsx']),
      ]);

      if (file != null) {
        final bytes = await file.readAsBytes();
        final excel = Excel.decodeBytes(bytes);
        final sheet = excel.tables[excel.tables.keys.first];

        final List<Urun> eklenecekUrunler = [];
        for (int i = 1; i < sheet!.rows.length; i++) {
          final row = sheet.rows[i];
          if (row[0]?.value != null && row[0]!.value.toString().isNotEmpty) {
            final urun = Urun(
              barkod: row[0]!.value.toString(),
              urunAdi: row[1]?.value.toString() ?? '',
              stok: double.tryParse(row[2]?.value.toString() ?? '0') ?? 0,
              stokKodu: row[3]?.value.toString(),
              kritikStok: double.tryParse(row[4]?.value.toString() ?? '0') ?? 0,
              birim: row[5]?.value.toString() ?? 'Adet',
              alisFiyati: double.tryParse(row[6]?.value.toString() ?? '0') ?? 0,
              karOrani: double.tryParse(row[7]?.value.toString() ?? '0') ?? 0,
              satisFiyati: double.tryParse(row[8]?.value.toString() ?? '0') ?? 0,
              anaKategori: row[9]?.value.toString() ?? '',
              altKategori: row[10]?.value.toString() ?? '',
              tedarikci: row[11]?.value.toString(),
              tedarikTarihi: row[12]?.value.toString(),
              notlar: row[13]?.value.toString(),
              firmaId: firmaId,
              firmaAdi: firmaAdi,
              userEmail: userEmail,
            );
            eklenecekUrunler.add(urun);
          }
        }

        if (mounted) {
          Provider.of<UrunProvider>(context, listen: false).urunleriEkle(eklenecekUrunler);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${eklenecekUrunler.length} ürün başarıyla eklendi.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }
}
