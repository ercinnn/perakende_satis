import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Kategorileri getir
  static Future<List<Category>> getCategories() async {
    final response = await _client.from('kategoriler').select();
    return (response as List)
        .map((item) => Category.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  // Yeni kategori ekle
  static Future<void> addCategory(Category category) async {
    await _client.from('kategoriler').insert(category.toMap());
  }

  // Kategori sil
  static Future<void> deleteCategory(String id) async {
    await _client.from('kategoriler').delete().eq('id', id);
  }

  // Kategori güncelle
  static Future<void> updateCategory(Category category) async {
    await _client
        .from('kategoriler')
        .update(category.toMap())
        .eq('id', category.id);
  }
}
