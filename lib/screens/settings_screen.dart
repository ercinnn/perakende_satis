import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;
  late final BuildContext _safeContext;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _safeContext = context;
  }

  Future<void> _handleSignOut() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(_safeContext, listen: false);

    try {
      await authProvider.signOut();
      if (!mounted) return;
      
      Navigator.of(_safeContext).pushReplacementNamed('/welcome');
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(_safeContext).showSnackBar(
        SnackBar(content: Text('Çıkış hatası: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanıcı Ayarları'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _UserInfoText(
                  label: 'Kullanıcı ID',
                  value: authProvider.userId,
                ),
                const SizedBox(height: 10),
                _UserInfoText(
                  label: 'Email',
                  value: authProvider.userEmail,
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignOut,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'ÇIKIŞ YAP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _UserInfoText extends StatelessWidget {
  final String label;
  final String? value;

  const _UserInfoText({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87),
          ),
          TextSpan(
            text: value ?? 'Belirtilmemiş',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54),
          ),
        ],
      ),
    );
  }
}