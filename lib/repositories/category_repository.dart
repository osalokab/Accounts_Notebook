import 'package:sqflite/sqflite.dart';
import '../models/category.dart';
import '../services/database_service.dart';

class CategoryRepository {
  final DatabaseService _dbService;

  CategoryRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  Future<List<Category>> getAllCategories() async {
    final db = await _dbService.database;
    final maps = await db.query('categories', orderBy: 'id ASC');
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  Future<Category?> getCategoryById(int id) async {
    final db = await _dbService.database;
    final maps = await db.query('categories', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertCategory(Category category) async {
    final db = await _dbService.database;
    return await db.insert('categories', category.toMap());
  }

  Future<int> updateCategory(Category category) async {
    final db = await _dbService.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<bool> deleteCategory(int id) async {
    final db = await _dbService.database;
    // Check if category has accounts
    final accountsCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM accounts WHERE category_id = ?',
      [id],
    )) ?? 0;

    if (accountsCount > 0) {
      return false; // In use
    }

    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
    return true;
  }
}
