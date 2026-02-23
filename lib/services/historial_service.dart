import 'package:supabase_flutter/supabase_flutter.dart';
import '../exceptions/app_exception.dart' as app_exceptions;

/// Servicio para gestionar el historial de movimientos
class HistorialService {
  final SupabaseClient _supabase;

  HistorialService(this._supabase);

  /// Obtener todo el historial de un niño
  Future<List<Map<String, dynamic>>> getByNino(String idNino) async {
    try {
      final response = await _supabase
          .from('historial')
          .select()
          .eq('id_nino', idNino)
          .order('fecha', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Error al obtener historial: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Obtener historial de todos los niños del educador
  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw app_exceptions.AuthException(message: 'Usuario no autenticado');
      }

      final response = await _supabase
          .from('historial')
          .select('*, ninos(id_nino, nombre, puntos)')
          .eq('ninos.id_educador', userId)
          .order('fecha', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.DatabaseException(
        message: 'Error al obtener historial: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Obtener historial filtrado por tipo y rango de fechas
  Future<List<Map<String, dynamic>>> getFiltered({
    required String idNino,
    String? tipo, // 'ingreso', 'gasto', null para todos
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    try {
      var query = _supabase.from('historial').select().eq('id_nino', idNino);

      if (tipo != null) {
        query = query.eq('tipo', tipo);
      }

      if (fechaDesde != null) {
        query = query.gte('fecha', fechaDesde.toIso8601String());
      }

      if (fechaHasta != null) {
        query = query.lte('fecha', fechaHasta.toIso8601String());
      }

      final response = await query.order('fecha', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Error al filtrar historial: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Obtener resumen de movimientos (total ingresos y gastos)
  Future<Map<String, int>> getResumen(String idNino) async {
    try {
      final response = await _supabase
          .from('historial')
          .select('tipo, cantidad')
          .eq('id_nino', idNino);

      int totalIngresos = 0;
      int totalGastos = 0;

      for (var movimiento in response) {
        final cantidad = movimiento['cantidad'] as int;
        if (movimiento['tipo'] == 'ingreso') {
          totalIngresos += cantidad;
        } else if (movimiento['tipo'] == 'gasto') {
          totalGastos += cantidad;
        }
      }

      return {
        'ingresos': totalIngresos,
        'gastos': totalGastos,
        'neto': totalIngresos - totalGastos,
      };
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Error al obtener resumen: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Obtener últimos N movimientos
  Future<List<Map<String, dynamic>>> getRecientes(
    String idNino, {
    int limite = 10,
  }) async {
    try {
      _validateLimite(limite);

      final response = await _supabase
          .from('historial')
          .select()
          .eq('id_nino', idNino)
          .order('fecha', ascending: false)
          .limit(limite);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Error al obtener movimientos recientes: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Eliminar entrada del historial (solo para correcciones)
  Future<void> delete(String idHistorial) async {
    try {
      await _supabase
          .from('historial')
          .delete()
          .eq('id_historial', idHistorial);
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Error al eliminar entrada: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Validar límite
  void _validateLimite(int limite) {
    if (limite <= 0 || limite > 100) {
      throw app_exceptions.ValidationException(
        message: 'El límite debe estar entre 1 y 100',
        field: 'limite',
      );
    }
  }
}
