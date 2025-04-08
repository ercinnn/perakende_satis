import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/product_provider.dart'; // Bu satır eksikti!

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<UrunProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Panel'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSummaryCard('Toplam Ürün', productProvider.urunler.length.toString()),
          _buildSummaryCard(
            'Düşük Stok',
            _countLowStockProducts(productProvider.urunler).toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  int _countLowStockProducts(List<Urun> urunler) {
    return urunler.where((p) => p.stok < 10).length;
  }
}
