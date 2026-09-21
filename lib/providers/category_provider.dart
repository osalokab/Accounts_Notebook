import 'package:flutter/foundation.dart' hide Category;
import '../models/category.dart';
import '../repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repository;

  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _isLoading = false;

  CategoryProvider({CategoryRepository? repository})
      : _repository = repository ?? CategoryRepository();

  List<Category> get categories => _categories;
  Category? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    _categories = await _repository.getAllCategories();
    if (_selectedCategory == null && _categories.isNotEmpty) {
      _selectedCategory = _categories.first; // Default to 'عام'
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectCategory(Category? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> addCategory(String name, {String type = 'general'}) async {
    final cat = Category(name: name, type: type);
    await _repository.insertCategory(cat);
    await loadCategories();
  }

  Future<void> updateCategory(Category category) async {
    await _repository.updateCategory(category);
    await loadCategories();
  }

  Future<bool> deleteCategory(int id) async {
    final success = await _repository.deleteCategory(id);
    if (success) {
      if (_selectedCategory?.id == id) {
        _selectedCategory = _categories.isNotEmpty ? _categories.first : null;
      }
      await loadCategories();
    }
    return success;
  }
}
