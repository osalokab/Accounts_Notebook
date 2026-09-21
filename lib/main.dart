import 'package:flutter/material.dart';
import 'app/app.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Database safely
  try {
    await DatabaseService.instance.database;
  } catch (e) {
    debugPrint('Database initialization warning: $e');
  }

  runApp(const AccountsNotebookApp());
}
