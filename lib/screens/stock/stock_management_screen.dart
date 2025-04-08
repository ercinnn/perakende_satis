import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';

class StockManagementScreen extends StatelessWidget {
  const StockManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final urunProvider = Provider.of<UrunProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Stok Yönetimi')),
      body: ListView.builder(
        itemCount: urunProvider.urunler.length,
        itemBuilder: (context, index) {
          final urun = urunProvider.urunler[index];
          return ListTile(
            title: Text(urun.urunAdi),
            subtitle: Text('Mevcut Stok: ${urun.stok}'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showStockEditDialog(context, urun),
            ),
          );
        },
      ),
    );
  }

  void _showStockEditDialog(BuildContext context, Urun urun) {
    final controller = TextEditingController(text: urun.stok.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${urun.urunAdi} - Stok Düzenle'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Yeni Stok Miktarı'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final yeniStok = double.tryParse(controller.text);
              if (yeniStok != null) {
                await Provider.of<UrunProvider>(context, listen: false)
                    .stokGuncelle(urun.barkod, yeniStok);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
