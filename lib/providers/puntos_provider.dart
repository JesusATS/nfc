import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/puntos_service.dart';

/// Provider para PuntosService
final puntosServiceProvider = Provider<PuntosService>((ref) {
  return PuntosService(Supabase.instance.client);
});

/// Provider para obtener saldo actual de un niño
final saldoNinoProvider = FutureProvider.autoDispose.family<int, String>((
  ref,
  idNino,
) async {
  final service = ref.watch(puntosServiceProvider);
  return service.getSaldo(idNino);
});

/// Provider para sumar puntos
final sumarPuntosProvider = FutureProvider.autoDispose
    .family<int, (String, int, String)>((ref, params) async {
      final (idNino, cantidad, motivo) = params;
      final service = ref.watch(puntosServiceProvider);
      final nuevoSaldo = await service.sumarPuntos(idNino, cantidad, motivo);
      // Invalidar saldo después de cambios
      ref.invalidate(saldoNinoProvider(idNino));
      return nuevoSaldo;
    });

/// Provider para restar puntos
final restarPuntosProvider = FutureProvider.autoDispose
    .family<int, (String, int, String)>((ref, params) async {
      final (idNino, cantidad, motivo) = params;
      final service = ref.watch(puntosServiceProvider);
      final nuevoSaldo = await service.restarPuntos(idNino, cantidad, motivo);
      // Invalidar saldo después de cambios
      ref.invalidate(saldoNinoProvider(idNino));
      return nuevoSaldo;
    });

/// Provider para validar saldo
final validarSaldoProvider = FutureProvider.autoDispose
    .family<bool, (String, int)>((ref, params) async {
      final (idNino, cantidadRequerida) = params;
      final service = ref.watch(puntosServiceProvider);
      return service.validarSaldo(idNino, cantidadRequerida);
    });
