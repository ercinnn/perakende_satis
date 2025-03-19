import 'package:flutter/material.dart';
import 'sales_view_mobile.dart';
import 'sales_view_web.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perakende Satış'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return SalesViewMobile(); // Mobil tasarım
          } else {
            return SalesViewWeb(); // Web tasarım
          }
        },
      ),
    );
  }
}