import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // conexion con Supabase
  await Supabase.initialize(
    url: 'https://niylxzeefeisszaqfxgo.supabase.co',
    anonKey: 'sb_publishable_cOeWUOZyxBsNDcFH1mXcfw_3um4JUFc',
  );

  runApp(const ProviderScope(child: MiAppNFC()));
}

class MiAppNFC extends ConsumerWidget {
  const MiAppNFC({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Mi App NFC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
