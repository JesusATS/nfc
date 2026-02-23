import 'package:supabase_flutter/supabase_flutter.dart';
import '../exceptions/app_exception.dart' as app_exceptions;

/// Servicio para manejar operaciones con niños
class NinoService {
  final SupabaseClient _supabase;

  NinoService(this._supabase);

  /// Obtener todos los niños del educador actual
  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw app_exceptions.AuthException(message: 'Usuario no autenticado');
      }

      final response = await _supabase
          .from('ninos')
          .select()
          .eq('id_educador', userId)
          .order('nombre');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.DatabaseException(
        message: 'Error al obtener niños: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Obtener un niño por su ID
  Future<Map<String, dynamic>?> getById(String id) async {
    try {
      final response = await _supabase
          .from('ninos')
          .select()
          .eq('id_nino', id)
          .maybeSingle();

      return response;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Error al obtener niño: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Obtener niño por su ID de tarjeta NFC
  Future<Map<String, dynamic>?> getByNfcUid(String nfcUid) async {
    try {
      final response = await _supabase
          .from('ninos')
          .select()
          .eq('nfc_uid', nfcUid)
          .maybeSingle();

      return response;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Error al buscar niño por tarjeta: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Buscar niños por nombre
  Future<List<Map<String, dynamic>>> search(String query) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw app_exceptions.AuthException(message: 'Usuario no autenticado');
      }

      final response = await _supabase
          .from('ninos')
          .select()
          .eq('id_educador', userId)
          .ilike('nombre', '%$query%')
          .order('nombre');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.DatabaseException(
        message: 'Error en búsqueda: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Crear nuevo niño
  Future<Map<String, dynamic>> create({
    required String nombre,
    required String nfcUid,
  }) async {
    try {
      _validateNombre(nombre);
      _validateNfcUid(nfcUid);

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw app_exceptions.AuthException(message: 'Usuario no autenticado');
      }

      final response = await _supabase.from('ninos').insert({
        'nombre': nombre.trim(),
        'nfc_uid': nfcUid.trim(),
        'puntos_actuales': 0,
        'id_educador': userId,
      }).select();

      if (response.isEmpty) {
        throw app_exceptions.DatabaseException(message: 'Error al crear niño');
      }

      return response.first;
    } on app_exceptions.ValidationException {
      rethrow;
    } on app_exceptions.AuthException {
      rethrow;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Error al crear niño: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Actualizar niño
  Future<Map<String, dynamic>> update({
    required String id,
    required String nombre,
    required String nfcUid,
  }) async {
    try {
      _validateNombre(nombre);
      _validateNfcUid(nfcUid);

      final response = await _supabase
          .from('ninos')
          .update({'nombre': nombre.trim(), 'nfc_uid': nfcUid.trim()})
          .eq('id_nino', id)
          .select();

      if (response.isEmpty) {
        throw app_exceptions.DatabaseException(message: 'Niño no encontrado');
      }

      return response.first;
    } on app_exceptions.ValidationException {
      rethrow;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Error al actualizar niño: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Eliminar niño
  Future<void> delete(String id) async {
    try {
      await _supabase.from('ninos').delete().eq('id_nino', id);
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Error al eliminar niño: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Validar nombre
  void _validateNombre(String nombre) {
    if (nombre.trim().isEmpty) {
      throw app_exceptions.ValidationException(
        message: 'El nombre no puede estar vacío',
        field: 'nombre',
      );
    }
    if (nombre.trim().length < 2) {
      throw app_exceptions.ValidationException(
        message: 'El nombre debe tener al menos 2 caracteres',
        field: 'nombre',
      );
    }
  }

  /// Validar NFC UID
  void _validateNfcUid(String nfcUid) {
    if (nfcUid.trim().isEmpty) {
      throw app_exceptions.ValidationException(
        message: 'El ID de tarjeta no puede estar vacío',
        field: 'nfc_uid',
      );
    }
  }
}
