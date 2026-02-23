import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc/exceptions/app_exception.dart';
import 'package:nfc/providers/nino_create_provider.dart';
import 'package:nfc/providers/nino_provider.dart';
import 'package:nfc/widgets/common/app_button.dart';
import 'package:nfc/widgets/common/app_dialogs.dart';
import 'package:nfc/widgets/nfc/nfc_reader_dialog.dart';

/// Pantalla para crear nuevo niño (alternativa mejorada a RegistroNinoScreen)
class NinoCreateScreen extends ConsumerWidget {
  const NinoCreateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ninoCreateProvider);
    final notifier = ref.read(ninoCreateProvider.notifier);
    final nombreController = TextEditingController();

    void leerTarjeta() {
      NFCReaderDialog.show(
        context,
        title: 'Registrar Nuevo Niño',
        message: 'Acerca la tarjeta del niño...',
        onCardRead: (nfcUid) {
          notifier.setNfcUid(nfcUid);
          SuccessSnackBar.show(
            context,
            message: 'Tarjeta registrada: $nfcUid\nAhora presiona "Crear Niño"',
          );
        },
      );
    }

    Future<void> crearNino() async {
      final nombre = nombreController.text.trim();

      if (nombre.isEmpty) {
        ErrorDialog.show(
          context,
          message: 'Por favor, escribe el nombre del niño',
        );
        return;
      }

      if (state.nfcUid == null) {
        ErrorDialog.show(
          context,
          message: 'Por favor, escanea la tarjeta del niño antes de crear',
        );
        return;
      }

      notifier.startLoading();

      try {
        final ninoService = ref.read(ninoServiceProvider);
        await ninoService.create(nombre: nombre, nfcUid: state.nfcUid!);

        if (context.mounted) {
          SuccessSnackBar.show(
            context,
            message: '✅ ¡$nombre creado exitosamente!',
          );

          ref.invalidate(ninoListProvider);
          Navigator.pop(context);
        }
      } on ValidationException catch (e) {
        if (context.mounted) {
          ErrorDialog.show(context, message: e.message);
        }
        notifier.stopLoading();
      } catch (e) {
        if (context.mounted) {
          ErrorDialog.show(context, message: 'Error al crear: ${e.toString()}');
        }
        notifier.stopLoading();
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Nuevo Niño'), elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // Ícono
              Center(
                child: Icon(
                  Icons.person_add_alt_1,
                  size: 80,
                  color: Colors.green.shade400,
                ),
              ),

              const SizedBox(height: 32),

              // Instrucciones
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
                    Text(
                      'Pasos para crear un niño:',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '1️⃣  Escribe el nombre del niño',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '2️⃣  Escanea la tarjeta NFC vinculada',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '3️⃣  Presiona "Crear Niño"',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Campo de nombre
              TextField(
                controller: nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre del niño/a',
                  hintText: 'Ej: Juan Pérez',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person),
                  enabled: !state.isLoading,
                ),
              ),

              const SizedBox(height: 32),

              // Botón para leer tarjeta
              ElevatedButton.icon(
                onPressed: state.isLoading ? null : leerTarjeta,
                icon: Icon(
                  Icons.nfc,
                  color: state.nfcUid != null ? Colors.white : null,
                ),
                label: Text(
                  state.nfcUid == null
                      ? 'Escanear Tarjeta NFC'
                      : 'Tarjeta: ${state.nfcUid}',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: state.nfcUid == null
                      ? Colors.blue
                      : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 32),

              // Botón crear
              AppButton(
                label: state.isLoading ? 'Creando...' : 'Crear Niño',
                onPressed: crearNino,
                isLoading: state.isLoading,
                isFullWidth: true,
                backgroundColor: Colors.green,
              ),

              const SizedBox(height: 16),

              // Botón cancelar
              AppOutlineButton(
                label: 'Cancelar',
                onPressed: state.isLoading
                    ? null
                    : () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
