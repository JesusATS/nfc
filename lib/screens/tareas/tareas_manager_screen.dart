import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc/providers/tarea_provider.dart';
import 'package:nfc/screens/tareas/tarea_create_screen.dart';
import 'package:nfc/screens/tareas/tarea_edit_screen.dart';
import 'package:nfc/widgets/cards/app_cards.dart';
import 'package:nfc/widgets/common/app_dialogs.dart';
import 'package:nfc/widgets/common/loading_overlay.dart';

class TareasManagerScreen extends ConsumerWidget {
  const TareasManagerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tareasAsync = ref.watch(tareaListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Tareas')),
      body: Stack(
        children: [
          tareasAsync.when(
            data: (tareas) {
              if (tareas.isEmpty) {
                return const Center(child: Text('No hay tareas creadas.'));
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TareaEditScreen(
                            tareaId: tarea['id_tarea'] as String,
                          ),
                        ),
                      );
                    },
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TareaEditScreen(
                            tareaId: tarea['id_tarea'] as String,
                          ),
                        ),
                      );
                    },
                    onDelete: () {
                      ErrorDialog.show(
                        context,
                        title: 'Eliminar Tarea',
                        message:
                            '¿Estás seguro de que quieres eliminar la tarea "${tarea['titulo']}"?',
                        onRetry: () async {
                          try {
                            final service = ref.read(tareaServiceProvider);
                            await service.delete(tarea['id_tarea'] as String);
                            
                            // Invalidar la lista después de eliminar
                            ref.invalidate(tareaListProvider);
                            
                            if (context.mounted) {
                              SuccessSnackBar.show(
                                context,
                                message: 'Tarea eliminada',
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ErrorDialog.show(
                                context,
                                message: 'Error al eliminar: $e',
                              );
                            }
                          }
                        },
                        retryLabel: 'Eliminar',
                      );
                    },
                  );
                },
              );
            },
            error: (err, stack) => Center(child: Text('Error: $err')),
            loading: () => const SizedBox.shrink(),
          ),
          LoadingOverlay(
            isVisible: tareasAsync.isLoading,
            message: 'Cargando tareas...',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TareaCreateScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
