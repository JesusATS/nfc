import 'package:supabase_flutter/supabase_flutter.dart';
import '../exceptions/app_exception.dart' as app_exceptions;

/// Servicio para manejar operaciones con tareas
class TareasService {
  final SupabaseClient _supabase;

  TareasService(this._supabase);

  /// Obtener todas las tareas del educador
  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw app_exceptions.AuthException(message: 'Usuario no autenticado');
      }

      final response = await _supabase
          .from('tareas')
          .select()
          .eq('id_educador', userId)
          .order('puntos_ganados', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.DatabaseException(
        message: 'Error al obtener tareas: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Obtener una tarea por su ID
  Future<Map<String, dynamic>?> getById(String id) async {
    try {
      final response = await _supabase
          .from('tareas')
          .select()
          .eq('id_tarea', id)
          .maybeSingle();

      return response;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Error al obtener tarea: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Crear nueva tarea
  Future<Map<String, dynamic>> create({
    required String titulo,
    required int puntosGanados,
    String icono = '📝',
  }) async {
    try {
      _validateTitulo(titulo);
      _validatePuntos(puntosGanados);

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw app_exceptions.AuthException(message: 'Usuario no autenticado');
      }

      final response = await _supabase.from('tareas').insert({
        'titulo': titulo.trim(),
        'puntos_ganados': puntosGanados,
        'icono': icono.trim(),
        'id_educador': userId,
      }).select();

      if (response.isEmpty) {
        throw app_exceptions.DatabaseException(message: 'Error al crear tarea');
      }

      return response.first;
    } on app_exceptions.ValidationException {
      rethrow;
    } on app_exceptions.AuthException {
      rethrow;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Error al crear tarea: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Actualizar tarea
  Future<Map<String, dynamic>> update({
    required String id,
    required String titulo,
    required int puntosGanados,
    String icono = '📝',
  }) async {
    try {
      _validateTitulo(titulo);
      _validatePuntos(puntosGanados);

      final response = await _supabase
          .from('tareas')
          .update({
            'titulo': titulo.trim(),
            'puntos_ganados': puntosGanados,
            'icono': icono.trim(),
          })
          .eq('id_tarea', id)
          .select();

      if (response.isEmpty) {
        throw app_exceptions.DatabaseException(message: 'Tarea no encontrada');
      }

      return response.first;
    } on app_exceptions.ValidationException {
      rethrow;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Error al actualizar tarea: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Eliminar tarea
  Future<void> delete(String id) async {
    try {
      await _supabase.from('tareas').delete().eq('id_tarea', id);
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Error al eliminar tarea: ${e.toString()}',
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

  /// Validar puntos
  void _validatePuntos(int puntos) {
    if (puntos <= 0) {
      throw app_exceptions.ValidationException(
        message: 'Los puntos deben ser mayor que 0',
        field: 'puntos_ganados',
      );
    }
    if (puntos > 1000) {
      throw app_exceptions.ValidationException(
        message: 'Los puntos no pueden ser mayor que 1000',
        field: 'puntos_ganados',
      );
    }
  }
}
