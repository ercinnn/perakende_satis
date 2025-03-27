import 'package:flutter/material.dart';
import '../sales/sales_screen.dart'; // Satış sayfasını import ediyoruz
import '../product/urunler.dart'; // Ürünler sayfasını import ediyoruz
import '../product/urun_ekle_guncelle_screen.dart'; // Ürün Ekle/Güncelle sayfasını import ediyoruz
import '../category/kategori_sayfasi.dart'; // Kategoriler sayfasını import ediyoruz

class AnaSayfa extends StatelessWidget {
  const AnaSayfa({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
      ),
      // Drawer Menüsü
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header (Menü Başlığı)
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menü',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            // Satış Sayfası Bağlantısı
            ListTile(
              title: const Text('Satış Sayfası'),
              onTap: () {
                Navigator.pop(context); // Drawer'ı kapat
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SalesScreen()),
                );
              },
            ),
            // Ürünler Sayfası Bağlantısı
            ListTile(
              title: const Text('Ürünler Sayfası'),
              onTap: () {
                Navigator.pop(context); // Drawer'ı kapat
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Urunler()),
                );
              },
            ),
            // Ürün Ekle/Güncelle Sayfası Bağlantısı
            ListTile(
              title: const Text('Ürün Ekle/Güncelle'),
              onTap: () {
                Navigator.pop(context); // Drawer'ı kapat
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UrunEkleGuncelleScreen()),
                );
              },
            ),
            // Kategoriler Sayfası Bağlantısı
            ListTile(
              title: const Text('Kategoriler'),
              onTap: () {
                Navigator.pop(context); // Drawer'ı kapat
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const KategoriSayfasi()),
                );
              },
            ),
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
                  MaterialPageRoute(builder: (context) => const Urunler()),
                );
              },
              child: const Text('Ürünler'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UrunEkleGuncelleScreen()),
                );
              },
              child: const Text('Ürün Ekle/Güncelle'),
            ),
            const SizedBox(height: 16),
            // Satış Sayfası Butonu
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SalesScreen()),
                );
              },
              child: const Text('Satış'),
            ),
            const SizedBox(height: 16),
            // Kategoriler Sayfası Butonu
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const KategoriSayfasi()),
                );
              },
              child: const Text('Kategoriler'),
            ),
          ],
        ),
      ),
    );
  }
}