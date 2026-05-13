import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screen/authentication/login_screen.dart';
import 'screen/mechanic/homescreen.dart';
import 'screen/user/navigation_shell.dart';
import 'screen/admin/admin_dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );
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
    _setOnlineStatus(false);  // Also set offline when minimized
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
      home: const AuthGate(), // ✅ Check session instead of always LoginScreen
    );
  }
}

// ✅ Auto-login gate
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      _checkSession();
    });
  }

  Future<void> _checkSession() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      
      if (session != null) {
        // ✅ Session exists locally - user is authenticated
        // Try to get dashboard, but use cached type if offline
        Widget destination;
        
        try {
          destination = await _getDashboard(session.user.id);
        } catch (e) {
          // ⚠️ Offline or error - use cached user type
          destination = await _getCachedDashboard();
        }
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
        }
      } else {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  // ✅ Save user type locally after login
  static Future<void> saveUserType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_type', type);
  }

Future<Widget> _getCachedDashboard() async {
  final prefs = await SharedPreferences.getInstance();
  final userType = prefs.getString('user_type') ?? 'login';  // Same key

  switch (userType) {
    case 'mechanic':
      return const MechanicHomeScreen();
    case 'user':
      return const UserNavigationShell();
    case 'admin':
      return const AdminDashboardScreen();
    default:
      return const LoginScreen();
  }
}

  Future<Widget> _getDashboard(String uid) async {
    // Check admin
    final admin = await Supabase.instance.client
        .from('admin')
        .select('uid')
        .eq('uid', uid)
        .maybeSingle();
    if (admin != null) {
      await saveUserType('admin');
      return const AdminDashboardScreen();
    }

    // Check mechanic
    final mechanic = await Supabase.instance.client
        .from('mechanic')
        .select('uid')
        .eq('uid', uid)
        .maybeSingle();
    if (mechanic != null) {
      await saveUserType('mechanic');
      return const MechanicHomeScreen();
    }

    // Check user
    final user = await Supabase.instance.client
        .from('users')
        .select('uid')
        .eq('uid', uid)
        .maybeSingle();
    if (user != null) {
      await saveUserType('user');
      return const UserNavigationShell();
    }

    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFFB703),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build_circle, size: 64, color: Colors.white),
            SizedBox(height: 16),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}