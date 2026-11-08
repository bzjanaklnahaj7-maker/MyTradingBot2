import 'package:flutter/material.dart';

class NotificationsView extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;

  const NotificationsView({super.key, this.notifications = const []});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات', style: TextStyle(color: Color(0xFFD4AF37))),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('لا توجد إشعارات حالياً', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return Card(
                  color: const Color(0xFF1A1A1A),
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.info, color: Color(0xFFD4AF37)),
                    title: Text(notif['title'] ?? 'إشعار', style: const TextStyle(color: Colors.white)),
                    subtitle: Text(notif['body'] ?? '', style: const TextStyle(color: Colors.grey)),
                  ),
                );
              },
            ),
    );
  }
}
