import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneLauncher {
  PhoneLauncher._();

  /// Validates and launches a phone call via native dialer.
  /// Shows an Alert dialog if unsupported or failed.
  static Future<void> makePhoneCall(BuildContext context, String phoneNumber) async {
    // Strip extraneous characters except + and digits
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: cleanNumber);

    try {
      final canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          _showErrorDialog(context);
        }
      }
    } catch (_) {
      if (context.mounted) {
        _showErrorDialog(context);
      }
    }
  }

  static void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: const Text('Dialer is not supported on this device'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
