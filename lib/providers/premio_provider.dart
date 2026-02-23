import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/premio_service.dart';

/// Provider para PremioService
final premioServiceProvider = Provider<PremioService>((ref) {
  return PremioService(Supabase.instance.client);
});

/// Provider para obtener lista de todos los premios
final premioListProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final service = ref.watch(premioServiceProvider);
      return service.getAll();
    });

/// Provider para obtener un premio por ID
final premioDetailProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, id) async {
      final service = ref.watch(premioServiceProvider);
      return service.getById(id);
    });

/// Provider para crear premio
final premioCreateProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, (String, int, String)>((ref, params) async {
      final (titulo, costoPuntos, icono) = params;
      final service = ref.watch(premioServiceProvider);
      final result = await service.create(
        titulo: titulo,
        costoPuntos: costoPuntos,
        icono: icono,
      );
      // Invalidar la lista de premios después de crear
      ref.invalidate(premioListProvider);
      return result;
    });

/// Provider para actualizar premio
final premioUpdateProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, (String, String, int, String)>((
      ref,
      params,
    ) async {
      final (id, titulo, costoPuntos, icono) = params;
      final service = ref.watch(premioServiceProvider);
      final result = await service.update(
        id: id,
        titulo: titulo,
        costoPuntos: costoPuntos,
        icono: icono,
      );
      // Invalidar la lista y detalle después de actualizar
      ref.invalidate(premioListProvider);
      ref.invalidate(premioDetailProvider(id));
      return result;
    });

/// Provider para eliminar premio
final premioDeleteProvider = FutureProvider.autoDispose.family<void, String>((
  ref,
  id,
) async {
  final service = ref.watch(premioServiceProvider);
  await service.delete(id);
  // Invalidar la lista después de eliminar
  ref.invalidate(premioListProvider);
});
