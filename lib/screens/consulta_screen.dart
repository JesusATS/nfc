import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/nino_provider.dart';
import '../../providers/puntos_provider.dart';
import '../../providers/historial_provider.dart';
import '../../widgets/nfc/nfc_reader_dialog.dart';
import '../../widgets/cards/app_cards.dart';
import '../../widgets/common/app_dialogs.dart';
import '../../widgets/common/loading_overlay.dart';

/// Pantalla para consultar saldo de un niño por NFC
/// No modifica nada, solo lectura
class ConsultaScreen extends ConsumerStatefulWidget {
  const ConsultaScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsultaScreen> createState() => _ConsultaScreenState();
}

class _ConsultaScreenState extends ConsumerState<ConsultaScreen> {
  String? _selectedNinoId;
  bool _isReading = false;

  void _leerTarjeta() {
    setState(() => _isReading = true);

    NFCReaderDialog.show(
      context,
      title: 'Consultar Saldo',
      message: 'Acerca la tarjeta para consultar saldo...',
      onCardRead: (nfcUid) async {
        // Buscar niño por NFC UID
        try {
          final service = ref.read(ninoServiceProvider);
          final ninoAsync = await service.getByNfcUid(nfcUid);

          if (ninoAsync != null) {
            setState(() {
              _selectedNinoId = ninoAsync['id_nino'] as String;
              _isReading = false;
            });
          } else {
            if (mounted) {
              ErrorDialog.show(
                context,
                title: 'Tarjeta No Encontrada',
                message: 'No hay ningún niño vinculado a esta tarjeta.',
                onRetry: _leerTarjeta,
              );
            }
            setState(() => _isReading = false);
          }
        } catch (e) {
          if (mounted) {
            ErrorDialog.show(
              context,
              title: 'Error',
              message: 'Error al buscar niño: $e',
              onRetry: _leerTarjeta,
            );
          }
          setState(() => _isReading = false);
        }
      },
      onCancel: () {
        setState(() => _isReading = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text('Consultar Saldo'), elevation: 0),
          body: _selectedNinoId == null
              ? _buildEmptyState()
              : _buildConsultaContent(),
          floatingActionButton: _selectedNinoId == null
              ? FloatingActionButton.extended(
                  onPressed: _isReading ? null : _leerTarjeta,
                  icon: const Icon(Icons.nfc),
                  label: const Text('Leer Tarjeta'),
                )
              : FloatingActionButton(
                  onPressed: _isReading ? null : _leerTarjeta,
                  tooltip: 'Leer otra tarjeta',
                  child: const Icon(Icons.refresh),
                ),
        ),
        LoadingOverlay(isVisible: _isReading, message: 'Leyendo tarjeta...'),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.nfc, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 24),
          Text(
            'Consultar Saldo',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Acerca la tarjeta NFC del niño para ver su saldo actual y últimos movimientos',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultaContent() {
    final ninoAsync = ref.watch(ninoDetailProvider(_selectedNinoId!));
    final saldoAsync = ref.watch(saldoNinoProvider(_selectedNinoId!));
    final historialAsync = ref.watch(
      historialRecientesProvider((_selectedNinoId!, 5)),
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          // Información del niño
          ninoAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Center(child: Text('Error: $err')),
            data: (nino) {
              if (nino == null) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.all(16),
                child: NinoCard(
                  id: nino['id_nino'] as String,
                  nombre: nino['nombre'] as String,
                  puntosActuales: nino['puntos'] as int,
                  nfcUid: nino['nfc_uid'] as String?,
                  fechaCreacion: nino['fecha_creacion'] != null
                      ? DateTime.parse(nino['fecha_creacion'] as String)
                      : null,
                ),
              );
            },
          ),

          // Saldo actual
          saldoAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
            error: (err, st) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error al obtener saldo: $err'),
            ),
            data: (saldo) => Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Saldo Actual',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$saldo',
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'puntos disponibles',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Últimos movimientos
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Últimos Movimientos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                historialAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, st) => Center(child: Text('Error: $err')),
                  data: (movimientos) {
                    if (movimientos.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'Sin movimientos registrados',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: movimientos.length,
                      itemBuilder: (_, index) {
                        final mov = movimientos[index];
                        final tipo = mov['tipo'] as String;
                        final isIngreso = tipo == 'ingreso';
                        final cantidad = mov['cantidad'] as int;
                        final motivo = mov['motivo'] as String?;
                        final fecha = DateTime.parse(mov['fecha'] as String);
                        final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              isIngreso
                                  ? Icons.add_circle
                                  : Icons.remove_circle,
                              color: isIngreso ? Colors.green : Colors.red,
                            ),
                            title: Text(motivo ?? 'Movimiento'),
                            subtitle: Text(dateFormatter.format(fecha)),
                            trailing: Text(
                              '${isIngreso ? '+' : '−'}$cantidad',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isIngreso ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
