import 'package:flutter/material.dart';
import 'product_add_update_mobile.dart';
import 'product_add_update_web.dart';

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
            return const UrunEkleGuncelleMobile();
          } else {
            return const UrunEkleGuncelleWeb();
          }
        },
      ),
    );
  }
}