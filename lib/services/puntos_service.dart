import 'package:supabase_flutter/supabase_flutter.dart';
import '../exceptions/app_exception.dart';

/// Servicio para gestionar la lógica de puntos
class PuntosService {
  final SupabaseClient _supabase;

  PuntosService(this._supabase);

  /// Obtener saldo actual de un niño
  Future<int> getSaldo(String idNino) async {
    try {
      final response = await _supabase
          .from('ninos')
          .select('puntos_actuales') // CAMBIADO: antes era 'puntos'
          .eq('id_nino', idNino)
          .single();

      return response['puntos_actuales'] as int; // CAMBIADO
    } catch (e) {
      throw DatabaseException(
        message: 'Error al obtener saldo: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Sumar puntos a un niño
  Future<int> sumarPuntos(String idNino, int cantidad, String motivo) async {
    try {
      _validateCantidad(cantidad);
      final saldoActual = await getSaldo(idNino);
      final nuevoSaldo = saldoActual + cantidad;

      // Actualizar saldo
      await _supabase
          .from('ninos')
          .update({'puntos_actuales': nuevoSaldo}) // CAMBIADO
          .eq('id_nino', idNino);

      // Registrar en historial
      await _supabase.from('historial').insert({
        'id_nino': idNino,
        'tipo': 'ingreso',
        'cantidad': cantidad,
        'saldo_anterior': saldoActual,
        'saldo_nuevo': nuevoSaldo,
        'motivo': motivo,
        'fecha': DateTime.now().toIso8601String(),
      });

      return nuevoSaldo;
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw DatabaseException(
        message: 'Error al sumar puntos: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Restar puntos a un niño
  Future<int> restarPuntos(String idNino, int cantidad, String motivo) async {
    try {
      _validateCantidad(cantidad);
      final saldoActual = await getSaldo(idNino);

      if (saldoActual < cantidad) {
        throw BusinessException(
          message:
              'Saldo insuficiente. Disponible: $saldoActual, Requerido: $cantidad',
        );
      }

      final nuevoSaldo = saldoActual - cantidad;

      // Actualizar saldo
      await _supabase
          .from('ninos')
          .update({'puntos_actuales': nuevoSaldo}) // CAMBIADO
          .eq('id_nino', idNino);

      // Registrar en historial
      await _supabase.from('historial').insert({
        'id_nino': idNino,
        'tipo': 'gasto',
        'cantidad': cantidad,
        'saldo_anterior': saldoActual,
        'saldo_nuevo': nuevoSaldo,
        'motivo': motivo,
        'fecha': DateTime.now().toIso8601String(),
      });

      return nuevoSaldo;
    } on ValidationException {
      rethrow;
    } on BusinessException {
      rethrow;
    } catch (e) {
      throw DatabaseException(
        message: 'Error al restar puntos: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<bool> validarSaldo(String idNino, int cantidadRequerida) async {
    try {
      final saldo = await getSaldo(idNino);
      return saldo >= cantidadRequerida;
    } catch (e) {
      throw DatabaseException(
        message: 'Error al validar saldo: ${e.toString()}',
        originalError: e,
      );
    }
  }

  void _validateCantidad(int cantidad) {
    if (cantidad <= 0) {
      throw ValidationException(message: 'La cantidad debe ser mayor que 0', field: 'cantidad');
    }
    if (cantidad > 10000) {
      throw ValidationException(message: 'La cantidad no puede ser mayor que 10000', field: 'cantidad');
    }
  }
}