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
          .select('puntos')
          .eq('id_nino', idNino)
          .single();

      return response['puntos'] as int;
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

      // 1. Obtener saldo actual
      final saldoActual = await getSaldo(idNino);

      // 2. Calcular nuevo saldo
      final nuevoSaldo = saldoActual + cantidad;

      // 3. Actualizar saldo
      await _supabase
          .from('ninos')
          .update({'puntos': nuevoSaldo})
          .eq('id_nino', idNino);

      // 4. Registrar en historial
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

      // 1. Obtener saldo actual
      final saldoActual = await getSaldo(idNino);

      // 2. Validar que haya saldo suficiente
      if (saldoActual < cantidad) {
        throw BusinessException(
          message:
              'Saldo insuficiente. Disponible: $saldoActual, Requerido: $cantidad',
        );
      }

      // 3. Calcular nuevo saldo
      final nuevoSaldo = saldoActual - cantidad;

      // 4. Actualizar saldo
      await _supabase
          .from('ninos')
          .update({'puntos': nuevoSaldo})
          .eq('id_nino', idNino);

      // 5. Registrar en historial
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

  /// Validar que haya saldo suficiente para un canje
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

  /// Validar cantidad
  void _validateCantidad(int cantidad) {
    if (cantidad <= 0) {
      throw ValidationException(
        message: 'La cantidad debe ser mayor que 0',
        field: 'cantidad',
      );
    }
    if (cantidad > 10000) {
      throw ValidationException(
        message: 'La cantidad no puede ser mayor que 10000',
        field: 'cantidad',
      );
    }
  }
}
