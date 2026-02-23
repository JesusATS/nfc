/// Base para todas las excepciones de la app
abstract class AppException implements Exception {
  final String message;
  final dynamic originalError;

  AppException({required this.message, this.originalError});

  @override
  String toString() => message;
}

/// Excepciones relacionadas con autenticación
class AuthException extends AppException {
  final String? code;

  AuthException({required super.message, this.code, super.originalError});
}

/// Excepciones de NFC
class NFCException extends AppException {
  NFCException({required super.message, super.originalError});
}

/// Excepciones de base de datos
class DatabaseException extends AppException {
  final String? code;

  DatabaseException({required super.message, this.code, super.originalError});
}

/// Excepciones de validación
class ValidationException extends AppException {
  final String? field;

  ValidationException({
    required super.message,
    this.field,
    super.originalError,
  });
}

/// Excepciones de lógica de negocios
class BusinessException extends AppException {
  final String? code;

  BusinessException({required super.message, this.code, super.originalError});
}

/// Excepciones de red/conexión
class NetworkException extends AppException {
  NetworkException({required super.message, super.originalError});
}
