import 'package:flutter/material.dart';
import '../product/urunler.dart';
import '../product/urun_ekle_guncelle.dart';

class AnaSayfa extends StatelessWidget {
  const AnaSayfa({super.key}); // key parametresi eklendi

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ana Sayfa'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Urunler()),
                );
              },
              child: Text('Ürünler Sayfasına Git'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UrunEkleGuncelle()),
                );
              },
              child: Text('Ürün Ekle/Güncelle Sayfasına Git'),
            ),
          ],
        ),
      ),
    );
  }
}