class NotificationItem {
  final int? id;
  final String title;
  final String message;
  final DateTime date;
  final bool isRead;
  final String type; // 'system', 'recurring', 'backup', 'alert'

  NotificationItem({
    this.id,
    required this.title,
    required this.message,
    DateTime? date,
    this.isRead = false,
    this.type = 'system',
  }) : date = date ?? DateTime.now();

  NotificationItem copyWith({
    int? id,
    String? title,
    String? message,
    DateTime? date,
    bool? isRead,
    String? type,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'date': date.toIso8601String(),
      'is_read': isRead ? 1 : 0,
      'type': type,
    };
  }

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      message: map['message'] as String,
      date: map['date'] != null ? DateTime.parse(map['date'] as String) : DateTime.now(),
      isRead: (map['is_read'] as int? ?? 0) == 1,
      type: map['type'] as String? ?? 'system',
    );
  }
}
