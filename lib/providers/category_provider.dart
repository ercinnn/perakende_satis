import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/supabase_service.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await SupabaseService.getCategories();
      _categories = data;
    } catch (e) {
      throw Exception('Kategoriler yüklenemedi: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      await SupabaseService.addCategory(category);
      await loadCategories();
    } catch (e) {
      throw Exception('Kategori eklenemedi: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await SupabaseService.deleteCategory(id);
      await loadCategories();
    } catch (e) {
      throw Exception('Kategori silinemedi: $e');
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await SupabaseService.updateCategory(category);
      await loadCategories();
    } catch (e) {
      throw Exception('Kategori güncellenemedi: $e');
    }
  }
}
