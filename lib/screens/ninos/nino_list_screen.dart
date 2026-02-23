import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc/providers/nino_provider.dart';
import 'package:nfc/screens/ninos/nino_create_screen.dart';
import 'package:nfc/screens/ninos/nino_detail_screen.dart';
import 'package:nfc/screens/ninos/nino_edit_screen.dart';
import 'package:nfc/widgets/cards/app_cards.dart';
import 'package:nfc/widgets/common/app_dialogs.dart';
import 'package:nfc/widgets/common/loading_overlay.dart';

class NinoListScreen extends ConsumerWidget {
  const NinoListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ninosAsync = ref.watch(ninoListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Niños')),
      body: Stack(
        children: [
          ninosAsync.when(
            data: (ninos) {
              if (ninos.isEmpty) {
                return const Center(child: Text('No hay niños creados.'));
              }

              return ListView.builder(
                itemCount: ninos.length,
                itemBuilder: (context, index) {
                  final nino = ninos[index];
                  return NinoCard(
                    id: nino['id_nino'] as String,
                    nombre: nino['nombre'] as String,
                    puntosActuales: nino['puntos_actuales'] as int,
                    nfcUid: nino['nfc_uid'] as String?,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NinoDetailScreen(
                            ninoId: nino['id_nino'] as String,
                          ),
                        ),
                      );
                    },
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NinoEditScreen(ninoId: nino['id_nino'] as String),
                        ),
                      );
                    },
                    onDelete: () {
                      ErrorDialog.show(
                        context,
                        title: 'Eliminar Niño',
                        message:
                            '¿Estás seguro de que quieres eliminar a "${nino['nombre']}"?',
                        onRetry: () async {
                          try {
                            final service = ref.read(ninoServiceProvider);
                            await service.delete(nino['id_nino'] as String);
                            
                            // Invalidar la lista después de eliminar
                            ref.invalidate(ninoListProvider);
                            
                            if (context.mounted) {
                              SuccessSnackBar.show(
                                context,
                                message: 'Niño eliminado',
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
            isVisible: ninosAsync.isLoading,
            message: 'Cargando niños...',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NinoCreateScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
