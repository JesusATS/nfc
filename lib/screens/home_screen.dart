import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Monitorear cambios en autenticación para logout
    ref.listen(authStateProvider, (previous, next) {
      next.whenData((user) {
        if (user == null) {
          context.go('/login');
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authService = ref.read(authServiceProvider);
              await authService.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        children: [
          _HomeCard(
            title: 'Gestionar Niños',
            icon: Icons.people,
            onTap: () => context.go('/home/ninos'),
          ),
          _HomeCard(
            title: 'Gestionar Tareas',
            icon: Icons.task,
            onTap: () => context.go('/home/tareas'),
          ),
          _HomeCard(
            title: 'Gestionar Premios',
            icon: Icons.emoji_events,
            onTap: () => context.go('/home/premios'),
          ),
          _HomeCard(
            title: 'Consultar Saldo',
            icon: Icons.account_balance_wallet,
            onTap: () => context.go('/home/consulta'),
          ),
          _HomeCard(
            title: 'Asignar Tareas',
            icon: Icons.add_task,
            onTap: () => context.go('/home/asignar-tareas'),
          ),
          _HomeCard(
            title: 'Canjear Premios',
            icon: Icons.redeem,
            onTap: () => context.go('/home/canjear-premios'),
          ),
        ],
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48.0),
            const SizedBox(height: 16.0),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
