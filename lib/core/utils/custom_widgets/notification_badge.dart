import 'package:flutter/material.dart';

import '../../../features/admin/models/notification_model.dart';

class NotificationBadge extends StatelessWidget {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _notificationService.getUnreadNotificationsCount(),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        if (count == 0) {
          return Icon(Icons.notifications_none);
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.notifications),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  count > 9 ? '9+' : '$count',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}