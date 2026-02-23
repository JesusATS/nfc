import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/historial_service.dart';

/// Provider para HistorialService
final historialServiceProvider = Provider<HistorialService>((ref) {
  return HistorialService(Supabase.instance.client);
});

/// Provider para obtener historial completo de un niño
final historialNinoProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, idNino) async {
      final service = ref.watch(historialServiceProvider);
      return service.getByNino(idNino);
    });

/// Provider para obtener historial de todos los niños del educador
final historialListProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final service = ref.watch(historialServiceProvider);
      return service.getAll();
    });

/// Provider para obtener historial filtrado
final historialFiltradoProvider = FutureProvider.autoDispose
    .family<
      List<Map<String, dynamic>>,
      (String, String?, DateTime?, DateTime?)
    >((ref, params) async {
      final (idNino, tipo, fechaDesde, fechaHasta) = params;
      final service = ref.watch(historialServiceProvider);
      return service.getFiltered(
        idNino: idNino,
        tipo: tipo,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
      );
    });

/// Provider para obtener resumen de movimientos
final historialResumenProvider = FutureProvider.autoDispose
    .family<Map<String, int>, String>((ref, idNino) async {
      final service = ref.watch(historialServiceProvider);
      return service.getResumen(idNino);
    });

/// Provider para obtener últimos movimientos
final historialRecientesProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, (String, int)>((ref, params) async {
      final (idNino, limite) = params;
      final service = ref.watch(historialServiceProvider);
      return service.getRecientes(idNino, limite: limite);
    });

/// Provider para eliminar entrada del historial
final historialDeleteProvider = FutureProvider.autoDispose.family<void, String>(
  (ref, idHistorial) async {
    final service = ref.watch(historialServiceProvider);
    await service.delete(idHistorial);
    // Invalidar listas después de eliminar
    ref.invalidate(historialListProvider);
  },
);
