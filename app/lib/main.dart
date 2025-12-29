import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env', isOptional: true);

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
  final hasConfig = supabaseUrl != null && supabaseAnonKey != null;

  if (hasConfig) {
    await Supabase.initialize(
      url: supabaseUrl!,
      anonKey: supabaseAnonKey!,
    );
  }

  runApp(ProviderScope(child: ChambaApp(isConfigured: hasConfig)));
}

class ChambaApp extends ConsumerWidget {
  const ChambaApp({super.key, required this.isConfigured});

  final bool isConfigured;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      useMaterial3: true,
    );

    if (!isConfigured) {
      return MaterialApp(
        title: 'Chambeo',
        theme: theme,
        home: const Scaffold(
          body: Center(
            child: Text('Configura SUPABASE_URL y SUPABASE_ANON_KEY en .env'),
          ),
        ),
      );
    }

    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'Chambeo',
      theme: theme,
      routerConfig: router,
    );
  }
}
