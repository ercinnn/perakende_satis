import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase/supabase.dart';
import 'home/anasayfa.dart';
import 'providers/urun_provider.dart';
import 'providers/kategori_provider.dart';
import 'core/services/supabase_client.dart';
import 'services/auth_service.dart'; // AuthService importu eklendi
import 'screens/login_screen.dart'; // LoginScreen importu eklendi
import 'screens/splash_screen.dart'; // SplashScreen importu eklendi
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env"); // Dosyayı yükle
  // Supabase yapılandırmasını başlat
  final supabase = SupabaseConfig.client;
  
  
  runApp(
    MultiProvider(
      providers: [
        Provider<SupabaseClient>.value(value: supabase),
        ChangeNotifierProvider(create: (_) => UrunProvider(supabase)),
        ChangeNotifierProvider(create: (_) => KategoriProvider(supabase)),
        Provider(create: (context) => AuthService(supabase)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Perakende Satış Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(), // AuthWrapper widget'ına taşındı
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    return FutureBuilder(
      future: authService.supabase.auth.session(),
      builder: (context, snapshot) {
        // Yükleme durumu
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        
        // Hata durumu
        if (snapshot.hasError) {
          return const LoginScreen(); // Hata durumunda login ekranına yönlendir
        }
        
        // Oturum kontrolü
        final session = snapshot.data;
        if (session != null) {
          return FutureBuilder(
            future: authService.supabase
              .from('adminler')
              .select('firma_id')
              .eq('id', session.user.id)
              .single(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }
              
              if (userSnapshot.hasError || userSnapshot.data == null) {
                return const LoginScreen();
              }
              
              final userData = userSnapshot.data!;
              
              return MultiProvider(
                providers: [
                  Provider<String>.value(value: userData['firma_id']),
                  Provider<String>.value(value: session.user.id),
                ],
                child: const AnaSayfa(),
              );
            },
          );
        }
        
        // Oturum yoksa login ekranı
        return const LoginScreen();
      },
    );
  }
}