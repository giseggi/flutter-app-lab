import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/sign_in_page.dart';
import '../features/feed/presentation/feed_page.dart';
import 'app_theme.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shokuba',
      theme: buildAppTheme(),
      home: authState.isAuthenticated ? const FeedPage() : const SignInPage(),
    );
  }
}
