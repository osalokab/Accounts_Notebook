import '../models/notification_item.dart';
import 'database_service.dart';

class NotificationService {
  static Future<List<NotificationItem>> getAllNotifications() async {
    final db = await DatabaseService.instance.database;
    final maps = await db.query('notifications', orderBy: 'date DESC, id DESC');
    return maps.map((m) => NotificationItem.fromMap(m)).toList();
  }

  static Future<int> getUnreadCount() async {
    final db = await DatabaseService.instance.database;
    final res = await db.rawQuery('SELECT COUNT(*) as count FROM notifications WHERE is_read = 0');
    return (res.first['count'] as int?) ?? 0;
  }

  static Future<void> addNotification({
    required String title,
    required String message,
    String type = 'system',
  }) async {
    final db = await DatabaseService.instance.database;
    final item = NotificationItem(
      title: title,
      message: message,
      type: type,
    );
    await db.insert('notifications', item.toMap());
  }

  static Future<void> markAllAsRead() async {
    final db = await DatabaseService.instance.database;
    await db.update('notifications', {'is_read': 1});
  }

  static Future<void> clearAll() async {
    final db = await DatabaseService.instance.database;
    await db.delete('notifications');
  }
}
