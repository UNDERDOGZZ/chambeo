import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth_phone_screen.dart';
import '../screens/auth_otp_screen.dart';
import '../screens/profile_setup_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/job_create_screen.dart';
import '../screens/job_detail_screen.dart';
import '../screens/job_offers_screen.dart';
import '../screens/job_offer_send_screen.dart';
import '../screens/job_room_screen.dart';
import '../screens/job_rate_screen.dart';
import '../state/auth_state.dart';
import '../screens/error_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/auth/phone',
    refreshListenable: RouterRefreshNotifier(
      ref.watch(authStateProvider.stream),
    ),
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final session = authState.valueOrNull?.session;
      final hasSession = session != null;
      final location = state.uri.toString();

      if (!hasSession && location != '/auth/phone' && location != '/auth/otp') {
        return '/auth/phone';
      }

      if (hasSession && (location == '/auth/phone' || location == '/auth/otp')) {
        return '/splash';
      }

      return null;
    },
    errorBuilder: (context, state) => ErrorScreen(
      message: state.error?.toString() ?? 'Ruta no encontrada',
    ),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth/phone',
        builder: (context, state) => const AuthPhoneScreen(),
      ),
      GoRoute(
        path: '/auth/otp',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: AuthOtpScreen(
            phone: state.uri.queryParameters['phone'] ?? '',
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fade = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            );
            final slide = Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(fade);
            return FadeTransition(
              opacity: fade,
              child: SlideTransition(position: slide, child: child),
            );
          },
        ),
      ),
      GoRoute(
        path: '/profile/setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/job/create',
        builder: (context, state) => const JobCreateScreen(),
      ),
      GoRoute(
        path: '/job/:id',
        builder: (context, state) => JobDetailScreen(jobId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/job/:id/offers',
        builder: (context, state) => JobOffersScreen(jobId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/job/:id/offer/send',
        builder: (context, state) => JobOfferSendScreen(jobId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/job/:id/room',
        builder: (context, state) => JobRoomScreen(jobId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/job/:id/rate',
        builder: (context, state) => JobRateScreen(jobId: state.pathParameters['id']!),
      ),
    ],
  );
});

class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Stream<dynamic> stream) {
    _subscription = stream.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
