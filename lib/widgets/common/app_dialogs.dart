import 'package:flutter/material.dart';

/// Dialog para mostrar errores
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const ErrorDialog({
    Key? key,
    this.title = 'Error',
    required this.message,
    this.onRetry,
    this.retryLabel = 'Reintentar',
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    String title = 'Error',
    required String message,
    VoidCallback? onRetry,
    String? retryLabel = 'Reintentar',
  }) {
    return showDialog(
      context: context,
      builder: (_) => ErrorDialog(
        title: title,
        message: message,
        onRetry: onRetry,
        retryLabel: retryLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: Text(message),
      actions: [
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            child: Text(
              retryLabel!,
              style: const TextStyle(color: Colors.blue),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

/// Snackbar para mostrar éxito
class SuccessSnackBar extends SnackBar {
  SuccessSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) : super(
         content: Row(
           children: [
             const Icon(Icons.check_circle, color: Colors.white),
             const SizedBox(width: 12),
             Expanded(child: Text(message)),
           ],
         ),
         backgroundColor: Colors.green.shade600,
         duration: duration,
         action: action,
       );

  /// Mostrar snackbar de éxito
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SuccessSnackBar(message: message, duration: duration));
  }
}

/// Snackbar para mostrar información
class InfoSnackBar extends SnackBar {
  InfoSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) : super(
         content: Row(
           children: [
             const Icon(Icons.info_outline, color: Colors.white),
             const SizedBox(width: 12),
             Expanded(child: Text(message)),
           ],
         ),
         backgroundColor: Colors.blue.shade600,
         duration: duration,
       );

  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(InfoSnackBar(message: message, duration: duration));
  }
}

/// Snackbar para mostrar advertencias
class WarningSnackBar extends SnackBar {
  WarningSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) : super(
         content: Row(
           children: [
             const Icon(Icons.warning_amber_rounded, color: Colors.white),
             const SizedBox(width: 12),
             Expanded(child: Text(message)),
           ],
         ),
         backgroundColor: Colors.orange.shade600,
         duration: duration,
       );

  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(WarningSnackBar(message: message, duration: duration));
  }
}
