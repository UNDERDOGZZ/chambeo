import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  final auth = Supabase.instance.client.auth;
  return auth.onAuthStateChange;
});

final sessionProvider = Provider<Session?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull?.session;
});

class Profile {
  const Profile({
    required this.id,
    required this.fullName,
    required this.role,
  });

  final String id;
  final String fullName;
  final String role;
}

final profileProvider = FutureProvider<Profile?>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session == null) {
    return null;
  }

  final client = Supabase.instance.client;
  final response = await client
      .from('profiles')
      .select('id, full_name, role')
      .eq('id', session.user.id)
      .maybeSingle();

  if (response == null) {
    return null;
  }

  return Profile(
    id: response['id'] as String,
    fullName: response['full_name'] as String,
    role: response['role'] as String,
  );
});
