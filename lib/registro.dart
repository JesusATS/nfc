import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/nino_provider.dart';
import 'widgets/common/app_dialogs.dart';
import 'widgets/common/app_button.dart';
import 'widgets/nfc/nfc_reader_dialog.dart';
import 'exceptions/app_exception.dart';

/// Pantalla para registrar nuevos niños con NFC
class RegistroNinoScreen extends ConsumerStatefulWidget {
  const RegistroNinoScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegistroNinoScreen> createState() => _RegistroNinoScreenState();
}

class _RegistroNinoScreenState extends ConsumerState<RegistroNinoScreen> {
  final TextEditingController _nombreController = TextEditingController();
  String? _nfcUidLeido;
  bool _guardando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  void _leerTarjeta() {
    NFCReaderDialog.show(
      context,
      title: 'Registrar Nuevo Niño',
      message: 'Acerca la NUEVA tarjeta del niño...',
      onCardRead: (nfcUid) {
        setState(() {
          _nfcUidLeido = nfcUid;
        });
        SuccessSnackBar.show(
          context,
          message: 'Tarjeta registrada: $nfcUid\nAhora presiona "Guardar Niño"',
        );
      },
      onCancel: () {
        InfoSnackBar.show(context, message: 'Lectura de tarjeta cancelada');
      },
    );
  }

  Future<void> _guardarNino() async {
    final nombre = _nombreController.text.trim();

    if (nombre.isEmpty) {
      ErrorDialog.show(
        context,
        message: 'Por favor, escribe el nombre del niño',
      );
      return;
    }

    if (_nfcUidLeido == null) {
      ErrorDialog.show(
        context,
        message: 'Por favor, escanea la tarjeta del niño antes de guardar',
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      final ninoService = ref.read(ninoServiceProvider);
      await ninoService.create(nombre: nombre, nfcUid: _nfcUidLeido!);

      if (mounted) {
        SuccessSnackBar.show(
          context,
          message: '¡$nombre registrado exitosamente!',
        );

        setState(() {
          _nombreController.clear();
          _nfcUidLeido = null;
          _guardando = false;
        });

        ref.invalidate(ninoListProvider);
      }
    } on ValidationException catch (e) {
      if (mounted) {
        ErrorDialog.show(context, message: e.message);
      }
      setState(() => _guardando = false);
    } catch (e) {
      if (mounted) {
        ErrorDialog.show(context, message: 'Error al guardar: ${e.toString()}');
      }
      setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Nuevo Niño'), elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Icon(
                  Icons.person_add,
                  size: 80,
                  color: Colors.blue.shade400,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre del niño/a',
                  hintText: 'Ej: Juan Pérez',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person),
                  enabled: !_guardando,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _guardando ? null : _leerTarjeta,
                icon: Icon(
                  Icons.nfc,
                  color: _nfcUidLeido != null ? Colors.white : null,
                ),
                label: Text(
                  _nfcUidLeido == null
                      ? 'Escanear Tarjeta NFC'
                      : 'Tarjeta OK: $_nfcUidLeido',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _nfcUidLeido == null
                      ? Colors.blue
                      : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 32),
              AppButton(
                label: _guardando ? 'Guardando...' : 'Guardar Niño',
                onPressed: _guardarNino,
                isLoading: _guardando,
                isFullWidth: true,
                backgroundColor: Colors.deepPurple,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pasos:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Escribe el nombre del niño',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '2. Escanea la tarjeta NFC del niño',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '3. Presiona "Guardar Niño"',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: _nfcUidLeido != null
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _nfcUidLeido != null ? Colors.green : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
