import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase/supabase.dart';
import '../services/auth_service.dart';
import '../core/services/supabase_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: dotenv.get('DEFAULT_ADMIN_EMAIL', fallback: ''));
  final _passwordController = TextEditingController(text: dotenv.get('DEFAULT_ADMIN_PASSWORD', fallback: ''));
  final _personelCodeController = TextEditingController();
  bool _isAdminLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _personelCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      Map<String, dynamic> userData;

      if (_isAdminLogin) {
        // Admin girişi
        userData = await authService.adminGiris(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        // Personel girişi
        userData = await authService.personelGiris(
          _emailController.text.trim(),
          _personelCodeController.text.trim(),
          _passwordController.text.trim(),
        );
      }

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/home', arguments: {
        'firmaId': userData['firma_id'],
        'userId': userData['user_id'],
        'userType': _isAdminLogin ? 'admin' : 'personel',
      });
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } on Exception catch (e) {
      setState(() => _errorMessage = 'Giriş başarısız: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Arka plan gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColorDark,
                ],
              ),
            ),
          ),

          // Ana içerik
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: size.width > 600 ? 500 : size.width * 0.9,
                padding: const EdgeInsets.all(24),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo
                          Image.asset(
                            'assets/images/logo.png',
                            height: 100,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.store,
                              size: 80,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Başlık
                          Text(
                            _isAdminLogin ? 'ADMİN GİRİŞİ' : 'PERSONEL GİRİŞİ',
                            style: Theme.of(context).textTheme.headline5?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                          ),
                          const SizedBox(height: 24),

                          // Email alanı
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Firma Emaili',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email zorunludur';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Geçerli bir email girin';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Personel kodu (sadece personel girişinde)
                          if (!_isAdminLogin)
                            Column(
                              children: [
                                TextFormField(
                                  controller: _personelCodeController,
                                  decoration: InputDecoration(
                                    labelText: 'Personel Kodu',
                                    prefixIcon: const Icon(Icons.badge_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (!_isAdminLogin && (value == null || value.isEmpty)) {
                                      return 'Personel kodu zorunludur';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),

                          // Şifre alanı
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Şifre',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword 
                                    ? Icons.visibility_off_outlined 
                                    : Icons.visibility_outlined),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Şifre zorunludur';
                              }
                              if (value.length < 6) {
                                return 'Şifre en az 6 karakter olmalı';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),

                          // Giriş türü değiştirme
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _isAdminLogin = !_isAdminLogin;
                                  _errorMessage = null;
                                });
                              },
                              child: Text(
                                _isAdminLogin 
                                    ? 'Personel girişi yap' 
                                    : 'Admin girişi yap',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),

                          // Hata mesajı
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Theme.of(context).errorColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                          // Giriş butonu
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _isLoading ? null : _handleLogin,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      _isAdminLogin ? 'ADMİN GİRİŞİ' : 'PERSONEL GİRİŞİ',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}