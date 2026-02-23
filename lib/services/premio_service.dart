import 'package:supabase_flutter/supabase_flutter.dart';
import '../exceptions/app_exception.dart' as app_exceptions;

/// Servicio para manejar operaciones con premios
class PremioService {
  final SupabaseClient _supabase;

  PremioService(this._supabase);

  /// Obtener todos los premios del educador
  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw app_exceptions.AuthException(message: 'Usuario no autenticado');
      }

      final response = await _supabase
          .from('premios')
          .select()
          .eq('id_educador', userId)
          .order('puntos_costo', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.DatabaseException(
        message: 'Error al obtener premios: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Obtener un premio por su ID
  Future<Map<String, dynamic>?> getById(String id) async {
    try {
      final response = await _supabase
          .from('premios')
          .select()
          .eq('id_premio', id)
          .maybeSingle();

      return response;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Error al obtener premio: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Crear nuevo premio
  Future<Map<String, dynamic>> create({
    required String titulo,
    required int costoPuntos,
    String icono = '🎁',
  }) async {
    try {
      _validateTitulo(titulo);
      _validateCosto(costoPuntos);

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw app_exceptions.AuthException(message: 'Usuario no autenticado');
      }

      final response = await _supabase.from('premios').insert({
        'titulo': titulo.trim(),
        'puntos_costo': costoPuntos,
        'icono': icono.trim(),
        'id_educador': userId,
      }).select();

      if (response.isEmpty) {
        throw app_exceptions.DatabaseException(
          message: 'Error al crear premio',
        );
      }

      return response.first;
    } on app_exceptions.ValidationException {
      rethrow;
    } on app_exceptions.AuthException {
      rethrow;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Error al crear premio: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Actualizar premio
  Future<Map<String, dynamic>> update({
    required String id,
    required String titulo,
    required int costoPuntos,
    String icono = '🎁',
  }) async {
    try {
      _validateTitulo(titulo);
      _validateCosto(costoPuntos);

      final response = await _supabase
          .from('premios')
          .update({
            'titulo': titulo.trim(),
            'puntos_costo': costoPuntos,
            'icono': icono.trim(),
          })
          .eq('id_premio', id)
          .select();

      if (response.isEmpty) {
        throw app_exceptions.DatabaseException(message: 'Premio no encontrado');
      }

      return response.first;
    } on app_exceptions.ValidationException {
      rethrow;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Error al actualizar premio: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Eliminar premio
  Future<void> delete(String id) async {
    try {
      await _supabase.from('premios').delete().eq('id_premio', id);
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Error al eliminar premio: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Validar título
  void _validateTitulo(String titulo) {
    if (titulo.trim().isEmpty) {
      throw app_exceptions.ValidationException(
        message: 'El título no puede estar vacío',
        field: 'titulo',
      );
    }
    if (titulo.trim().length < 3) {
      throw app_exceptions.ValidationException(
        message: 'El título debe tener al menos 3 caracteres',
        field: 'titulo',
      );
    }
  }

  /// Validar costo en puntos
  void _validateCosto(int costo) {
    if (costo <= 0) {
      throw app_exceptions.ValidationException(
        message: 'El costo debe ser mayor que 0',
        field: 'costo_puntos',
      );
    }
    if (costo > 1000) {
      throw app_exceptions.ValidationException(
        message: 'El costo no puede ser mayor que 1000',
        field: 'costo_puntos',
      );
    }
  }
}
