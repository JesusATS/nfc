import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/nino_service.dart';

/// Provider para NinoService
final ninoServiceProvider = Provider<NinoService>((ref) {
  return NinoService(Supabase.instance.client);
});

/// Provider para obtener lista de todos los niños
final ninoListProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>(
  (ref) async {
    final service = ref.watch(ninoServiceProvider);
    return service.getAll();
  },
);

/// Provider para obtener un niño por ID
final ninoDetailProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, id) async {
      final service = ref.watch(ninoServiceProvider);
      return service.getById(id);
    });

/// Provider para buscar niño por UID de NFC
final ninoByNfcProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, nfcUid) async {
      final service = ref.watch(ninoServiceProvider);
      return service.getByNfcUid(nfcUid);
    });

/// Provider para búsqueda de niños por nombre
final ninoSearchProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, query) async {
      final service = ref.watch(ninoServiceProvider);
      return service.search(query);
    });

final ninoUpdateProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, (String, String, String)>((
      ref,
      params,
    ) async {
      final (id, nombre, nfcUid) = params;
      final service = ref.watch(ninoServiceProvider);
      final result = await service.update(
        id: id,
        nombre: nombre,
        nfcUid: nfcUid,
      );
      // Invalidar la lista de niños después de crear
      ref.invalidate(ninoListProvider);
      ref.invalidate(ninoDetailProvider(id));
      return result;
    });

final ninoDeleteProvider = FutureProvider.autoDispose.family<void, String>((
  ref,
  id,
) async {
  final service = ref.watch(ninoServiceProvider);
  await service.delete(id);
  // Invalidar la lista después de eliminar
  ref.invalidate(ninoListProvider);
});
