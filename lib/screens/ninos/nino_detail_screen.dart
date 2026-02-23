import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc/providers/historial_provider.dart';
import 'package:nfc/providers/nino_provider.dart';
import 'package:nfc/widgets/common/loading_overlay.dart';

class NinoDetailScreen extends ConsumerWidget {
  const NinoDetailScreen({Key? key, required this.ninoId}) : super(key: key);
  final String ninoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ninoAsync = ref.watch(ninoDetailProvider(ninoId));
    final historialAsync = ref.watch(historialNinoProvider(ninoId));

    return Scaffold(
      appBar: AppBar(
        title: ninoAsync.when(
          data: (nino) => Text(nino?['nombre'] as String? ?? 'Detalle'),
          loading: () => const Text('Cargando...'),
          error: (err, stack) => const Text('Error'),
        ),
      ),
      body: Stack(
        children: [
          ninoAsync.when(
            data: (nino) {
              if (nino == null) {
                return const Center(child: Text('Niño no encontrado.'));
              }
              return Column(
                children: [
                  ListTile(
                    title: Text(nino['nombre'] as String),
                    subtitle: Text(
                      'NFC: ${nino['nfc_uid'] as String? ?? 'No asignado'}',
                    ),
                    trailing: Text('${nino['puntos_actuales'] as int} puntos'),
                  ),
                  const Divider(),
                  Expanded(
                    child: historialAsync.when(
                      data: (historial) {
                        if (historial.isEmpty) {
                          return const Center(
                            child: Text('No hay historial de movimientos.'),
                          );
                        }
                        return ListView.builder(
                          itemCount: historial.length,
                          itemBuilder: (context, index) {
                            final item = historial[index];
                            final isSuma =
                                (item['puntos_ganados'] as int? ?? 0) > 0;
                            return ListTile(
                              leading: isSuma
                                  ? const Icon(Icons.add, color: Colors.green)
                                  : const Icon(Icons.remove, color: Colors.red),
                              title: Text(item['descripcion'] as String),
                              trailing: Text(
                                '${isSuma ? '+' : ''}${item['puntos_ganados'] as int? ?? item['puntos_gastados'] as int? ?? 0} puntos',
                              ),
                            );
                          },
                        );
                      },
                      error: (err, stack) => Center(child: Text('Error: $err')),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ],
              );
            },
            error: (err, stack) => Center(child: Text('Error: $err')),
            loading: () => const SizedBox.shrink(),
          ),
          LoadingOverlay(
            isVisible: ninoAsync.isLoading,
            message: 'Cargando...',
          ),
        ],
      ),
    );
  }
}
