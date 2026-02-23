import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc/providers/premio_provider.dart';
import 'package:nfc/screens/premios/premio_create_screen.dart';
import 'package:nfc/screens/premios/premio_edit_screen.dart';
import 'package:nfc/widgets/cards/app_cards.dart';
import 'package:nfc/widgets/common/app_dialogs.dart';
import 'package:nfc/widgets/common/loading_overlay.dart';

class PremiosManagerScreen extends ConsumerWidget {
  const PremiosManagerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiosAsync = ref.watch(premioListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Premios')),
      body: Stack(
        children: [
          premiosAsync.when(
            data: (premios) {
              if (premios.isEmpty) {
                return const Center(child: Text('No hay premios creados.'));
              }

              return ListView.builder(
                itemCount: premios.length,
                itemBuilder: (context, index) {
                  final premio = premios[index];
                  return PremioCard(
                    id: premio['id_premio'] as String,
                    titulo: premio['titulo'] as String,
                    costoPuntos: premio['puntos_costo'] as int,
                    icono: premio['icono'] as String? ?? '🎁',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PremioEditScreen(
                            premioId: premio['id_premio'] as String,
                          ),
                        ),
                      );
                    },
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PremioEditScreen(
                            premioId: premio['id_premio'] as String,
                          ),
                        ),
                      );
                    },
                    onDelete: () {
                      ErrorDialog.show(
                        context,
                        title: 'Eliminar Premio',
                        message:
                            '¿Estás seguro de que quieres eliminar el premio "${premio['titulo']}"?',
                        onRetry: () async {
                          try {
                            final service = ref.read(premioServiceProvider);
                            await service.delete(premio['id_premio'] as String);
                            
                            // Invalidar la lista después de eliminar
                            ref.invalidate(premioListProvider);
                            
                            if (context.mounted) {
                              SuccessSnackBar.show(
                                context,
                                message: 'Premio eliminado',
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
            isVisible: premiosAsync.isLoading,
            message: 'Cargando premios...',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PremioCreateScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
