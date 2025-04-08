import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SalesProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  double _dailySales = 0.0;
  double _monthlySales = 0.0;
  String _topProduct = 'Yükleniyor...';

  double get dailySales => _dailySales;
  double get monthlySales => _monthlySales;
  String get topProduct => _topProduct;

  bool isLoading = false;

  Future<void> loadSalesData() async {
    isLoading = true;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı oturumu yok');

      final firmaData = await _supabase
          .from('adminler')
          .select('firma_id')
          .eq('id', userId)
          .single();

      final firmaId = firmaData['firma_id'] as String;

      final today = DateTime.now();

      // Günlük satış toplamı
      final dailyRes = await _supabase
          .from('satislar')
          .select('tutar')
          .eq('firma_id', firmaId)
          .gte('tarih', DateTime(today.year, today.month, today.day).toIso8601String());

      _dailySales = (dailyRes as List)
          .map((e) => (e['tutar'] ?? 0).toDouble())
          .fold(0.0, (a, b) => a + b);

      // Aylık satış toplamı
      final monthlyRes = await _supabase
          .from('satislar')
          .select('tutar')
          .eq('firma_id', firmaId)
          .gte('tarih', DateTime(today.year, today.month, 1).toIso8601String());

      _monthlySales = (monthlyRes as List)
          .map((e) => (e['tutar'] ?? 0).toDouble())
          .fold(0.0, (a, b) => a + b);

      // En çok satan ürün (manual SQL view ya da Supabase function ile yapılmalı, geçici çözüm):
      final raw = await _supabase
          .rpc('get_top_product', params: {'firma_id_param': firmaId});

      if (raw != null && raw is List && raw.isNotEmpty) {
        _topProduct = raw.first['urun_adi'] ?? 'Yok';
      } else {
        _topProduct = 'Yok';
      }
    } catch (e) {
      debugPrint('Satış verileri yüklenemedi: $e');
      _dailySales = 0.0;
      _monthlySales = 0.0;
      _topProduct = 'Hata oluştu';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
