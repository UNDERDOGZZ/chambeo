import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/auth_state.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    ref.listen(profileProvider, (previous, next) {
      next.whenData((profile) {
        if (!mounted) {
          return;
        }
        if (profile == null) {
          context.go('/profile/setup');
        } else {
          context.go('/home');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    return Scaffold(
      body: Center(
        child: profileAsync.when(
          data: (_) => const CircularProgressIndicator(),
          loading: () => const CircularProgressIndicator(),
          error: (_, __) => const Text('Error cargando perfil'),
        ),
      ),
    );
  }
}
