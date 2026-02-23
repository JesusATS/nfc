import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/tarea_provider.dart';
import 'providers/nino_provider.dart';
import 'providers/puntos_provider.dart';
import 'widgets/cards/app_cards.dart';
import 'widgets/common/app_dialogs.dart';
import 'package:nfc/widgets/common/loading_overlay.dart';
import 'package:nfc/widgets/nfc/nfc_reader_dialog.dart';
import 'exceptions/app_exception.dart';

/// Pantalla para asignar tareas y dar puntos
class TareasScreen extends ConsumerWidget {
  const TareasScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tareasAsync = ref.watch(tareaListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Asignar Tareas'), elevation: 0),
      body: tareasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $err'),
            ],
          ),
        ),
        data: (tareas) {
          if (tareas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No hay tareas registradas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea tareas para comenzar a repartir puntos',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: tareas.length,
            itemBuilder: (context, index) {
              final tarea = tareas[index];
              return TareaCard(
                id: tarea['id_tarea'] as String,
                titulo: tarea['titulo'] as String,
                puntosGanados: tarea['puntos_ganados'] as int,
                icono: tarea['icono'] as String? ?? '📝',
                onTap: () => _darPuntos(context, ref, tarea),
              );
            },
          );
        },
      ),
    );
  }

  void _darPuntos(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> tarea,
  ) {
    NFCReaderDialog.show(
      context,
      title: 'Asignar Tarea',
      message:
          'Acerca la tarjeta del niño para sumar ${tarea['puntos_ganados']} puntos...',
      onCardRead: (nfcUid) async {
        try {
          // 1. Buscar niño por NFC
          final ninoAsync = await ref.read(ninoByNfcProvider(nfcUid).future);

          if (ninoAsync == null) {
            if (context.mounted) {
              ErrorDialog.show(
                context,
                message: 'Tarjeta no registrada',
                onRetry: () => _darPuntos(context, ref, tarea),
              );
            }
            return;
          }

          // 2. Sumar puntos
          if (context.mounted) {
            LoadingDialog.show(context);
          }

          final nuevoSaldo = await ref.read(
            sumarPuntosProvider((
              ninoAsync['id_nino'] as String,
              tarea['puntos_ganados'] as int,
              'Tarea: ${tarea['titulo']}',
            )).future,
          );

          if (context.mounted) {
            Navigator.pop(context); // Cerrar loading
            SuccessSnackBar.show(
              context,
              message:
                  '✅ +${tarea['puntos_ganados']} puntos a ${ninoAsync['nombre']}\nTotal: $nuevoSaldo pts',
            );
          }
        } on BusinessException catch (e) {
          if (context.mounted) {
            Navigator.pop(context); // Cerrar loading si está visible
            ErrorDialog.show(context, message: e.message);
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.pop(context);
            ErrorDialog.show(
              context,
              message: 'Error: $e',
              onRetry: () => _darPuntos(context, ref, tarea),
            );
          }
        }
      },
      onCancel: () {
        // Dialog cerrado
      },
    );
  }
}
