import 'package:flutter/material.dart';
import 'sales_view_mobile.dart';
import 'sales_view_web.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Satış Ekranı'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return constraints.maxWidth < 600
              ? const SalesViewMobile()
              : const SalesViewWeb();
        },
      ),
    );
  }
}
