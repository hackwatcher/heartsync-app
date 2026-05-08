import 'package:flutter/material.dart';
import 'ui/sync_theme.dart';

import 'ui/splash_screen.dart';
import 'core/services/app_state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/services/persistence_service.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (args.contains('--instance=2')) {
    PersistenceService().setPrefix('instance2_');
  }
  await AppState().loadFromStorage();
  runApp(const HeartSyncApp());
}

class HeartSyncApp extends StatelessWidget {
  const HeartSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeartSync',
      debugShowCheckedModeBanner: false,
      theme: SyncTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
