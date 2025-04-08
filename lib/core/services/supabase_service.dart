import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:perakende_satis/models/category_model.dart';

class SupabaseService {
  static final _client = Supabase.instance.client;

  static Future<List<Category>> getCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .order('name', ascending: true);

    return (response as List)
        .map((item) => Category.fromMap(item))
        .toList();
  }

  static Future<void> addCategory(Category category) async {
    await _client.from('categories').insert(category.toMap());
  }

  static Future<void> deleteCategory(String id) async {
    await _client.from('categories').delete().match({'id': id});
  }
}
