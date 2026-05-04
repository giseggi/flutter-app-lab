import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const config = AppConfig.fromEnvironment();
  if (config.isSupabaseConfigured) {
    await Supabase.initialize(
      url: config.supabaseUrl,
      anonKey: config.supabaseAnonKey,
    );
  }

  runApp(
    ProviderScope(
      overrides: [appConfigProvider.overrideWithValue(config)],
      child: const MyApp(),
    ),
  );
}
