import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

showSnackBar(
  BuildContext context, {
  String? title,
  String? message,
}) {
  final snackBar = SnackBar(content: Text(message!));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showMessage(
  BuildContext context,
  String title,
  String message, {
  NotificationPosition position = NotificationPosition.top,
}) {
  OverlaySupportEntry? entry;
  entry = showSimpleNotification(
    GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        entry!.dismiss();
      },
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ),
    ),
    leading: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        entry!.dismiss();
      },
      child: const Icon(Icons.done_all, color: Colors.white),
    ),
    duration: const Duration(seconds: 2),
    key: Key(title),
    subtitle: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        entry!.dismiss();
      },
      child: Text(
        message,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
    ),
    position: position,
    slideDismissDirection: DismissDirection.horizontal,
    autoDismiss: true,
    background: Theme.of(context).primaryColor.withOpacity(0.85),
  );
}
