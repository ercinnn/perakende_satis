import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  final logger = Logger();

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final firmaNo = 'Firma${DateTime.now().millisecondsSinceEpoch}';

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      logger.i("AUTH kayıt sonucu: ${response.user}");

      if (response.user != null) {
        try {
          await Supabase.instance.client.from('admins').insert({
            'email': email,
            'firma_kodu': firmaNo,
            'firma_adi': firmaNo,
          });
          logger.i("admins tablosuna kayıt başarılı.");
        } catch (e) {
          logger.e("admins tablosuna kayıt yapılamadı: $e");
        }

        try {
          await Supabase.instance.client.from('companies').insert({
            'admin_email': email,
            'firma_adi': firmaNo,
          });
          logger.i("companies tablosuna kayıt başarılı.");
        } catch (e) {
          logger.e("companies tablosuna kayıt yapılamadı: $e");
        }

        try {
          await Supabase.instance.client.from('users').insert({
            'email': email,
            'role': 'admin',
            'firma_kodu': firmaNo,
          });
          logger.i("users tablosuna kayıt başarılı.");
        } catch (e) {
          logger.e("users tablosuna kayıt yapılamadı: $e");
        }

        try {
          await Supabase.instance.client.from('stock_features_settings').insert({
            'created_by_email': email,
          });
          logger.i("stock_features_settings tablosuna kayıt başarılı.");
        } catch (e) {
          logger.e("stock_features_settings tablosuna kayıt yapılamadı: $e");
        }

        setState(() {
          _successMessage = 'Kayıt başarılı! Lütfen email adresinizi kontrol ederek doğrulayın.';
        });
      } else {
        setState(() => _errorMessage = 'Kullanıcı kaydı başarısız.');
      }
    } on AuthException catch (e) {
      logger.e("AUTH EXCEPTION: ${e.message}");
      setState(() => _errorMessage = e.message);
    } catch (e) {
      logger.e("GENEL HATA: $e");
      setState(() => _errorMessage = 'Beklenmeyen bir hata oluştu.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.person_add, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email gerekli';
                  }
                  if (!value.contains('@')) {
                    return 'Geçerli bir email girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Şifre en az 6 karakter olmalı';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              if (_successMessage != null)
                Text(_successMessage!, style: const TextStyle(color: Colors.green)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Kayıt Ol'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
                child: const Text('Zaten hesabın var mı? Giriş yap'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
