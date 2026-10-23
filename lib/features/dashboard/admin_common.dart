import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../auth/adminLogin.dart';

const Color adminPrimary = Color(0xFF6038A8);
const Color adminBackground = Color(0xFFF7F6FA);

/// Shows [error] to the admin. A [SessionExpiredException] sends them back to login.
void handleAdminError(BuildContext context, Object error) {
  if (!context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  if (error is SessionExpiredException) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(error.message)));
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const AdminLoginScreen()),
      (route) => route.isFirst,
    );
    return;
  }
  final message = error is ApiException
      ? error.message
      : 'Something went wrong. Please try again.';
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
    ));
}

void showAdminSuccess(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.green.shade700,
      behavior: SnackBarBehavior.floating,
    ));
}

Future<bool> confirmAdminDelete(BuildContext context, String itemName) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete?'),
      content: Text('Delete "$itemName"? This cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Opens a time picker and returns the chosen time as "HH:mm".
Future<String?> pickApiTime(BuildContext context, {String? initial}) async {
  final minutes = initial == null ? 9 * 60 : apiTimeToMinutes(initial);
  final picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
  );
  if (picked == null) return null;
  return '${picked.hour.toString().padLeft(2, '0')}:'
      '${picked.minute.toString().padLeft(2, '0')}';
}

class AdminHeaderCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const AdminHeaderCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: adminPrimary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 34),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }
}

AppBar buildAdminAppBar(String title, {VoidCallback? onRefresh}) {
  return AppBar(
    title: Text(title),
    backgroundColor: Colors.white,
    foregroundColor: const Color(0xFF20202A),
    elevation: 0,
    actions: [
      if (onRefresh != null)
        IconButton(
          tooltip: 'Refresh',
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh),
        ),
    ],
  );
}

class AdminSaveButton extends StatelessWidget {
  final bool saving;
  final String label;
  final VoidCallback? onPressed;
  final IconData icon;

  const AdminSaveButton({
    super.key,
    required this.saving,
    required this.label,
    required this.onPressed,
    this.icon = Icons.save_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: saving ? null : onPressed,
        icon: saving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Icon(icon),
        label: Text(saving ? 'Saving...' : label),
        style: FilledButton.styleFrom(
          backgroundColor: adminPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
