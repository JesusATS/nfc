import 'package:supabase_flutter/supabase_flutter.dart';
import '../debug_utils.dart';

class AuthService {
  final SupabaseClient _supabase;

  AuthService(this._supabase);

  /// Stream de cambios en el estado de autenticación
  Stream<User?> get authStateChanges {
    DebugUtils.log('Inicializando authStateChanges stream');
    return _supabase.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      DebugUtils.log('Estado de auth cambió: ${user?.email ?? 'Sin usuario'}');
      return user;
    });
  }

  /// Obtener usuario actual
  User? get currentUser => _supabase.auth.currentUser;

  /// Login con email y contraseña
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.session == null) {
        throw Exception('Email o contraseña incorrectos');
      }
      return response;
    } on AuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  /// Registrar nuevo usuario
  Future<User?> register({
    required String email,
    required String password,
    required String nombre,
  }) async {
    try {
      // 1. Crear usuario en Auth de Supabase
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Error al crear usuario en autenticación');
      }

      // 2. Crear perfil en tabla 'users'
      // IMPORTANTE: Esto debe hacerse con un pequeño delay para asegurar que el usuario esté creado
      await Future.delayed(const Duration(milliseconds: 500));
      
      try {
        print('Intentando crear perfil para usuario: ${authResponse.user!.id}');
        await _supabase.from('users').insert({
          'id_usuario': authResponse.user!.id,
          'nombre': nombre,
          'email': email,
          'rol': 'educador',
        });
        print('Perfil creado exitosamente');
      } catch (profileError) {
        print('Error al crear perfil: ${profileError.toString()}');
        // Re-lanzar el error para que se vea en la UI
        throw Exception('Error al crear perfil de usuario: ${profileError.toString()}');
      }

      return authResponse.user;
    } on AuthException catch (e) {
      throw _mapAuthError(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Logout del usuario actual
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  /// Enviar email de recuperación de contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  /// Mapear errores de Auth a mensajes amigables
  Exception _mapAuthError(AuthException e) {
    if (e.message.contains('Invalid login credentials')) {
      return Exception('Email o contraseña incorrectos');
    }
    if (e.message.contains('User already registered')) {
      return Exception('Este email ya está registrado');
    }
    if (e.message.contains('Signup disabled')) {
      return Exception('El registro está deshabilitado');
    }
    if (e.message.contains('Email not confirmed')) {
      return Exception('Por favor confirma tu email');
    }
    return Exception(e.message);
  }
}
