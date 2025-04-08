import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final email = authProvider.userEmail ?? 'Kullanıcı';

    return Scaffold(
      appBar: AppBar(
        title: Text("Hoşgeldin $email"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _handleLogout(context);
            },
          ),
        ],
      ),
      body: const Center(
        child: Text("Ana sayfadasınız"),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.signOut();

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, "/login");
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Çıkış hatası: ${e.toString()}")),
        );
      }
    }
  }
}
