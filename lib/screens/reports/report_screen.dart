import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sales_provider.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final salesProvider = Provider.of<SalesProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Satış Raporları')),
      body: ListView(
        children: [
          _buildReportItem('Günlük Satış', salesProvider.dailySales.toStringAsFixed(2)),
          _buildReportItem('Aylık Satış', salesProvider.monthlySales.toStringAsFixed(2)),
          _buildReportItem('En Çok Satan Ürün', salesProvider.topProduct),
        ],
      ),
    );
  }

  Widget _buildReportItem(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(value, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}