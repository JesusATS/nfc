import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/tarea_service.dart';

/// Provider para TareasService
final tareaServiceProvider = Provider<TareasService>((ref) {
  return TareasService(Supabase.instance.client);
});

/// Provider para obtener lista de todas las tareas
final tareaListProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final service = ref.watch(tareaServiceProvider);
      return service.getAll();
    });

/// Provider para obtener una tarea por ID
final tareaDetailProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, id) async {
      final service = ref.watch(tareaServiceProvider);
      return service.getById(id);
    });

/// Provider para crear tarea
final tareaCreateProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, (String, int, String)>((ref, params) async {
      final (titulo, puntosGanados, icono) = params;
      final service = ref.watch(tareaServiceProvider);
      final result = await service.create(
        titulo: titulo,
        puntosGanados: puntosGanados,
        icono: icono,
      );
      // Invalidar la lista de tareas después de crear
      ref.invalidate(tareaListProvider);
      return result;
    });

/// Provider para actualizar tarea
final tareaUpdateProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, (String, String, int, String)>((
      ref,
      params,
    ) async {
      final (id, titulo, puntosGanados, icono) = params;
      final service = ref.watch(tareaServiceProvider);
      final result = await service.update(
        id: id,
        titulo: titulo,
        puntosGanados: puntosGanados,
        icono: icono,
      );
      // Invalidar la lista y detalle después de actualizar
      ref.invalidate(tareaListProvider);
      ref.invalidate(tareaDetailProvider(id));
      return result;
    });

/// Provider para eliminar tarea
final tareaDeleteProvider = FutureProvider.autoDispose.family<void, String>((
  ref,
  id,
) async {
  final service = ref.watch(tareaServiceProvider);
  await service.delete(id);
  // Invalidar la lista después de eliminar
  ref.invalidate(tareaListProvider);
});
