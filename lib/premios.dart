import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/premio_provider.dart';
import 'providers/nino_provider.dart';
import 'providers/puntos_provider.dart';
import 'widgets/cards/app_cards.dart';
import 'widgets/common/app_dialogs.dart';
import 'package:nfc/widgets/common/loading_overlay.dart';
import 'package:nfc/widgets/nfc/nfc_reader_dialog.dart';
import 'exceptions/app_exception.dart';

/// Pantalla para canjear premios
class PremiosScreen extends ConsumerWidget {
  const PremiosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiosAsync = ref.watch(premioListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tienda de Premios'),
        elevation: 0,
        backgroundColor: Colors.purple,
      ),
      body: premiosAsync.when(
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
        data: (premios) {
          if (premios.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.card_giftcard,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay premios disponibles',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea premios para que los niños canjeen puntos',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: premios.length,
            itemBuilder: (context, index) {
              final premio = premios[index];
              return PremioCard(
                id: premio['id_premio'] as String,
                titulo: premio['titulo'] as String,
                costoPuntos: premio['costo_puntos'] as int,
                icono: premio['icono'] as String? ?? '🎁',
                onTap: () => _canjearPremio(context, ref, premio),
              );
            },
          );
        },
      ),
    );
  }

  void _canjearPremio(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> premio,
  ) {
    NFCReaderDialog.show(
      context,
      title: 'Canjear Premio',
      message:
          'Acerca la tarjeta del niño para cobrar ${premio['costo_puntos']} puntos...',
      onCardRead: (nfcUid) async {
        try {
          // 1. Buscar niño por NFC
          final ninoAsync = await ref.read(ninoByNfcProvider(nfcUid).future);

          if (ninoAsync == null) {
            if (context.mounted) {
              ErrorDialog.show(
                context,
                message: 'Tarjeta no registrada',
                onRetry: () => _canjearPremio(context, ref, premio),
              );
            }
            return;
          }

          // 2. Validar saldo
          final tieneSaldo = await ref.read(
            validarSaldoProvider((
              ninoAsync['id_nino'] as String,
              premio['costo_puntos'] as int,
            )).future,
          );

          if (!tieneSaldo) {
            if (context.mounted) {
              final saldoActual = (ninoAsync['puntos'] as int? ?? 0);
              final falta = (premio['costo_puntos'] as int) - saldoActual;
              ErrorDialog.show(
                context,
                message:
                    '❌ Saldo insuficiente\n${ninoAsync['nombre']} tiene $saldoActual pts\nLe faltan $falta pts',
                onRetry: () => _canjearPremio(context, ref, premio),
              );
            }
            return;
          }

          // 3. Restar puntos
          if (context.mounted) {
            LoadingDialog.show(context);
          }

          final nuevoSaldo = await ref.read(
            restarPuntosProvider((
              ninoAsync['id_nino'] as String,
              premio['costo_puntos'] as int,
              'Canje: ${premio['titulo']}',
            )).future,
          );

          if (context.mounted) {
            Navigator.pop(context); // Cerrar loading
            SuccessSnackBar.show(
              context,
              message:
                  '🎉 ¡Premio canjeado por ${ninoAsync['nombre']}!\nLe quedan $nuevoSaldo pts',
            );
          }
        } on BusinessException catch (e) {
          if (context.mounted) {
            Navigator.pop(context);
            ErrorDialog.show(context, message: e.message);
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.pop(context);
            ErrorDialog.show(
              context,
              message: 'Error: $e',
              onRetry: () => _canjearPremio(context, ref, premio),
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
