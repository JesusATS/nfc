import 'package:flutter/material.dart';
import '../../services/nfc_service.dart';
import '../../exceptions/app_exception.dart';

/// Dialog reutilizable para lectura de NFC
class NFCReaderDialog extends StatefulWidget {
  final String message;
  final String title;
  final Function(String nfcUid) onCardRead;
  final VoidCallback? onCancel;

  const NFCReaderDialog({
    Key? key,
    required this.onCardRead,
    this.message = 'Acerca la tarjeta NFC...',
    this.title = 'Leer Tarjeta',
    this.onCancel,
  }) : super(key: key);

  /// Mostrar el dialog
  static Future<void> show(
    BuildContext context, {
    required Function(String) onCardRead,
    String message = 'Acerca la tarjeta NFC...',
    String title = 'Leer Tarjeta',
    VoidCallback? onCancel,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => NFCReaderDialog(
        message: message,
        title: title,
        onCardRead: onCardRead,
        onCancel: onCancel,
      ),
    );
  }

  @override
  State<NFCReaderDialog> createState() => _NFCReaderDialogState();
}

class _NFCReaderDialogState extends State<NFCReaderDialog> {
  String? _error;
  bool _isReading = false;

  @override
  void initState() {
    super.initState();
    _startReading();
  }

  @override
  void dispose() {
    // La sesión se detiene automáticamente en el NFCService
    super.dispose();
  }

  Future<void> _startReading() async {
    setState(() {
      _isReading = true;
      _error = null;
    });

    try {
      final nfcUid = await NFCService.readCard(context);
      if (mounted) {
        widget.onCardRead(nfcUid);
        Navigator.of(context).pop();
      }
    } on NFCException catch (e) {
      // Errores específicos de NFC
      if (mounted) {
        setState(() {
          _error = e.message;
          _isReading = false;
        });
      }
    } catch (e) {
      // Otros errores
      if (mounted) {
        setState(() {
          _error = 'Ocurrió un error inesperado: ${e.toString()}';
          _isReading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isReading) ...[
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
          ],
          if (_error != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _startReading,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            NFCService.stopSession();
            widget.onCancel?.call();
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
