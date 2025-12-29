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

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(
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
        builder: (context, state) => const AuthOtpScreen(),
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
