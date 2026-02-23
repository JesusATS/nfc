import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc/exceptions/app_exception.dart';
import 'package:nfc/providers/nino_provider.dart';
import 'package:nfc/providers/premio_provider.dart';
import 'package:nfc/providers/puntos_provider.dart';
import 'package:nfc/widgets/cards/app_cards.dart';
import 'package:nfc/widgets/common/app_dialogs.dart';
import 'package:nfc/widgets/common/loading_overlay.dart';
import 'package:nfc/widgets/nfc/nfc_reader_dialog.dart';

class PremiosScreen extends ConsumerWidget {
  const PremiosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiosAsync = ref.watch(premioListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Canjear Premios')),
      body: premiosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
        data: (premios) {
          if (premios.isEmpty) {
            return const Center(child: Text('No hay premios para canjear.'));
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
          'Acerca la tarjeta del niño para canjear "${premio['titulo']}" por ${premio['puntos_costo']} puntos.',
      onCardRead: (nfcUid) async {
        try {
          final ninoService = ref.read(ninoServiceProvider);
          final nino = await ninoService.getByNfcUid(nfcUid);
          if (nino == null) {
            if (context.mounted) {
              ErrorDialog.show(
                context,
                message: 'Niño no encontrado',
                onRetry: () => _canjearPremio(context, ref, premio),
              );
            }
            return;
          }

          LoadingDialog.show(context);

          final puntosService = ref.read(puntosServiceProvider);
          final nuevoSaldo = await puntosService.restarPuntos(
            nino['id_nino'] as String,
            premio['puntos_costo'] as int,
            'Premio: ${premio['titulo']}',
          );

          if (context.mounted) {
            Navigator.pop(context);
            SuccessSnackBar.show(
              context,
              message:
                  'Premio canjeado! Nuevo saldo de ${nino['nombre']}: $nuevoSaldo puntos.',
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
    );
  }
}
