import 'package:flutter/material.dart';
import '../sales/sales_screen.dart'; // Satış sayfasını import ediyoruz
import '../product/urunler.dart'; // Ürünler sayfasını import ediyoruz
import '../product/urun_ekle_guncelle.dart'; // Ürün Ekle/Güncelle sayfasını import ediyoruz

class AnaSayfa extends StatelessWidget {
  const AnaSayfa({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ana Sayfa'),
      ),
      // Drawer Menüsü
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header (Menü Başlığı)
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menü',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            // Satış Sayfası Bağlantısı
            ListTile(
              title: Text('Satış Sayfası'),
              onTap: () {
                Navigator.pop(context); // Drawer'ı kapat
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SalesScreen()),
                );
              },
            ),
            // Ürünler Sayfası Bağlantısı
            ListTile(
              title: Text('Ürünler Sayfası'),
              onTap: () {
                Navigator.pop(context); // Drawer'ı kapat
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Urunler()),
                );
              },
            ),
            // Ürün Ekle/Güncelle Sayfası Bağlantısı
            ListTile(
              title: Text('Ürün Ekle/Güncelle'),
              onTap: () {
                Navigator.pop(context); // Drawer'ı kapat
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UrunEkleGuncelle()),
                );
              },
            ),
            // Diğer menü öğeleri buraya eklenebilir
          ],
        ),
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
            SizedBox(height: 20),
            // Satış Sayfası Butonu
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SalesScreen()),
                );
              },
              child: Text('Satış Sayfasına Git'),
            ),
          ],
        ),
      ),
    );
  }
}