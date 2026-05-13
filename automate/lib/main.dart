import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screen/authentication/login_screen.dart';
import 'screen/authentication/loading_screen.dart';
import 'screen/authentication/welcome_screen.dart';
import 'screen/user/user_offline_screen.dart';
import 'screen/mechanic/homescreen.dart';
import 'screen/user/navigation_shell.dart';
import 'screen/admin/admin_dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      _setOnlineStatus(false);
    } else if (state == AppLifecycleState.paused) {
      _setOnlineStatus(false); // Also set offline when minimized
    }
  }

  Future<void> _setOnlineStatus(bool isOnline) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        await Supabase.instance.client
            .from('mechanic')
            .update({'online_status': isOnline})
            .eq('uid', user.id);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Automate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: UserOfflineScreen(
        child: LoadingScreen(destination: const WelcomeScreen()),
      ),
    );
  }
}
