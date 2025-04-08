// lib/screens/personel/personel_dashboard_screen.dart
import 'package:flutter/material.dart';

class PersonelDashboardScreen extends StatelessWidget {
  const PersonelDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personel Paneli')),
      body: const Center(child: Text('🧍 Hoş geldin Personel!')),
    );
  }
}
