import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final Urun urun;
  final VoidCallback onTap;

  const ProductCard({
    required this.urun,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(urun.urunAdi),
        subtitle: Text('${urun.satisFiyati.toStringAsFixed(2)} TL'),
        trailing: Text('Stok: ${urun.stok.toStringAsFixed(0)}'),
        onTap: onTap,
      ),
    );
  }
}
