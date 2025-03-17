import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home/anasayfa.dart';
import 'providers/urun_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UrunProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // key parametresi eklendi

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perakende Satış Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AnaSayfa(),
    );
  }
}