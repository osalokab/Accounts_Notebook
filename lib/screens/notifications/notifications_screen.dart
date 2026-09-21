import 'package:flutter/material.dart';
import '../../models/notification_item.dart';
import '../../services/notification_service.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final items = await NotificationService.getAllNotifications();
    if (mounted) {
      setState(() {
        _notifications = items;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التنبيهات'),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.done_all, size: 18),
            label: const Text('عرض الكل'),
            onPressed: () async {
              await NotificationService.markAllAsRead();
              _loadNotifications();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'إضافة تنبيه تجريبي',
            onPressed: () => _showAddNotificationDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.textSecondary),
                      SizedBox(height: 12),
                      Text('لا توجد تنبيهات جديدة', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final item = _notifications[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item.isRead
                              ? AppColors.textSecondary.withValues(alpha: 0.15)
                              : AppColors.primaryLight.withValues(alpha: 0.2),
                          child: Icon(
                            item.isRead ? Icons.notifications_none : Icons.notifications_active,
                            color: item.isRead ? AppColors.textSecondary : AppColors.primary,
                          ),
                        ),
                        title: Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(item.message),
                            const SizedBox(height: 4),
                            Text(
                              AppFormatters.formatDateTime(item.date),
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showAddNotificationDialog() {
    final titleCtrl = TextEditingController();
    final msgCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة تنبيه جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'عنوان التنبيه')),
            const SizedBox(height: 10),
            TextField(controller: msgCtrl, decoration: const InputDecoration(labelText: 'نص التنبيه'), maxLines: 2),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.isNotEmpty && msgCtrl.text.isNotEmpty) {
                await NotificationService.addNotification(
                  title: titleCtrl.text.trim(),
                  message: msgCtrl.text.trim(),
                );
                if (ctx.mounted) Navigator.pop(ctx);
                _loadNotifications();
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
