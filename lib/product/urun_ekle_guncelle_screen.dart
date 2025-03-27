import 'package:flutter/material.dart';
import 'urun_ekle_guncelle_mobile.dart';
import 'urun_ekle_guncelle_web.dart';

class UrunEkleGuncelleScreen extends StatelessWidget {
  const UrunEkleGuncelleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürün Ekle/Güncelle'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return const UrunEkleGuncelleMobile(); // Mobil tasarım
          } else {
            return const UrunEkleGuncelleWeb(); // Web tasarım
          }
        },
      ),
    );
  }
}