import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../debug_utils.dart';
import '../services/auth_service.dart';

/// Provider para AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(Supabase.instance.client);
});

/// Stream provider para monitorear cambios en el estado de autenticación
/// Este es el ÚNICO provider que debe usarse para redirección
final authStateProvider = StreamProvider<User?>((ref) {
  DebugUtils.log('Creando Stream de autenticación');
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider para verificar si el usuario está logueado (rápido)
final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final user = await ref.watch(authStateProvider.future);
  return user != null;
});

