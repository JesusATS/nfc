import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nfc/screens/home_screen.dart';
import 'package:nfc/screens/premios/premio_create_screen.dart';
import 'package:nfc/screens/premios/premio_edit_screen.dart';
import 'package:nfc/screens/premios/premios_manager_screen.dart';
import 'package:nfc/screens/premios/premios_screen.dart';
import 'package:nfc/screens/tareas/tarea_create_screen.dart';
import 'package:nfc/screens/tareas/tarea_edit_screen.dart';
import 'package:nfc/screens/tareas/tareas_manager_screen.dart';
import 'package:nfc/tareas.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/consulta_screen.dart';
import 'screens/ninos/nino_list_screen.dart';
import 'screens/ninos/nino_detail_screen.dart';
import 'screens/ninos/nino_edit_screen.dart';
import 'screens/ninos/nino_create_screen.dart';
import 'providers/auth_provider.dart';
import 'debug_utils.dart';

/// Provider para el router con autenticación
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      DebugUtils.log('Router redirect evaluando: ${state.matchedLocation}');
      final authState = ref.watch(authStateProvider);
      final isLoggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isSplash = state.matchedLocation == '/splash';

      return authState.when(
        data: (user) {
          final isLoggedIn = user != null;
          DebugUtils.log('Auth state: loggedIn=$isLoggedIn, isSplash=$isSplash, isLoggingIn=$isLoggingIn');
          
          // Si está logueado
          if (isLoggedIn) {
            // Si está en login/register o splash, ir a home
            if (isLoggingIn || isSplash) {
              DebugUtils.log('Usuario logueado, redirecting to /home');
              return '/home';
            }
            // Si está en home u otras rutas protegidas, permitir
            DebugUtils.log('Usuario logueado en ruta protegida, permitiendo acceso');
            return null;
          }
          
          // Si NO está logueado
          if (!isLoggedIn) {
            // Si ya está en login/register, permitir
            if (isLoggingIn) {
              DebugUtils.log('Usuario no logueado en página de auth, permitiendo acceso');
              return null;
            }
            // En cualquier otro caso (splash u otras rutas), ir a login
            DebugUtils.log('Usuario no logueado, redirecting to /login');
            return '/login';
          }
          
          DebugUtils.log('Sin redirección necesaria');
          return null;
        },
        loading: () {
          DebugUtils.log('Auth state LOADING...');
          return '/splash';
        },
        error: (error, stack) {
          DebugUtils.error('Error en authStateProvider: $error');
          return '/login';
        },
      );
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Home Route (Principal)
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) {
          return const HomeScreen();
        },
        routes: [
          // Subrutas del home
          GoRoute(
            path: 'ninos',
            name: 'ninos',
            builder: (context, state) => const NinoListScreen(),
            routes: [
              GoRoute(
                path: 'crear',
                name: 'nino-crear',
                builder: (context, state) => const NinoCreateScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'nino-detalle',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return NinoDetailScreen(ninoId: id);
                },
              ),
              GoRoute(
                path: ':id/editar',
                name: 'nino-editar',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return NinoEditScreen(ninoId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'tareas',
            name: 'tareas',
            builder: (context, state) => const TareasManagerScreen(),
            routes: [
              GoRoute(
                path: 'crear',
                name: 'tarea-crear',
                builder: (context, state) => const TareaCreateScreen(),
              ),
              GoRoute(
                path: ':id/editar',
                name: 'tarea-editar',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return TareaEditScreen(tareaId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'premios',
            name: 'premios',
            builder: (context, state) => const PremiosManagerScreen(),
            routes: [
              GoRoute(
                path: 'crear',
                name: 'premio-crear',
                builder: (context, state) => const PremioCreateScreen(),
              ),
              GoRoute(
                path: ':id/editar',
                name: 'premio-editar',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return PremioEditScreen(premioId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'asignar-tareas',
            name: 'asignar-tareas',
            builder: (context, state) => const TareasScreen(),
          ),
          GoRoute(
            path: 'canjear-premios',
            name: 'canjear-premios',
            builder: (context, state) => const PremiosScreen(),
          ),
          GoRoute(
            path: 'historial',
            name: 'historial',
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Historial')),
              body: const Center(child: Text('Historial - Próximamente')),
            ),
          ),
          GoRoute(
            path: 'consulta',
            name: 'consulta',
            builder: (context, state) => const ConsultaScreen(),
          ),
        ],
      ),
    ],

    // Error page
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Ir al inicio'),
            ),
          ],
        ),
      ),
    ),
  );
});
