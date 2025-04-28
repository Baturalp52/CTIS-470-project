import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/topic_provider.dart';
import 'providers/entry_provider.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'services/topic_service.dart';
import 'services/entry_service.dart';
import "firebase_options.dart";

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final prefs = await SharedPreferences.getInstance();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
          Provider(create: (_) => AuthService(prefs)),
          Provider(create: (_) => UserService()),
          Provider(create: (_) => TopicService()),
          Provider(create: (_) => EntryService()),
          ChangeNotifierProxyProvider<AuthService, AuthProvider>(
            create: (context) => AuthProvider(context.read<AuthService>()),
            update: (context, authService, previous) =>
                previous ?? AuthProvider(authService),
          ),
          ChangeNotifierProxyProvider2<AuthService, TopicService,
              TopicProvider>(
            create: (context) => TopicProvider(
              context.read<TopicService>(),
              context.read<AuthService>(),
            ),
            update: (context, authService, topicService, previous) =>
                previous ?? TopicProvider(topicService, authService),
          ),
          ChangeNotifierProxyProvider<EntryService, EntryProvider>(
            create: (context) => EntryProvider(context.read<EntryService>()),
            update: (context, entryService, previous) =>
                previous ?? EntryProvider(entryService),
          ),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error: $e'),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          initialRoute: '/',
          routes: {
            '/': (context) => const AuthWrapper(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/home': (context) => const HomeScreen(title: 'CTIS Dictionary'),
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authProvider.isAuthenticated) {
      return const HomeScreen(title: 'CTIS Dictionary');
    }

    return const LoginScreen();
  }
}
