import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'screens/live_image_screen.dart';
import 'screens/productivity_screen.dart';
import 'screens/record_screen.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/ab.dart';
import 'providers/yield_repository.dart';
import 'providers/acc.dart';
import 'providers/data_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'services/api_client.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => ApiClient()),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(context.read<ApiClient>()),
        ),
        ChangeNotifierProvider(create: (_) => YieldRepository()),
        ChangeNotifierProvider(create: (_) => AccessibilityProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
      ],
      child: const SmartAgriApp(),
    ),
  );
}

class SmartAgriApp extends StatefulWidget {
  const SmartAgriApp({super.key});

  @override
  State<SmartAgriApp> createState() => _SmartAgriAppState();
}

class _SmartAgriAppState extends State<SmartAgriApp> {
  int currentIndex = 0;

  final pages = const [
    HomeScreen(),
    LiveImageScreen(),
    ProductivityScreen(),
    RecordScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) => auth.isAuthenticated
            ? Scaffold(
                body: pages[currentIndex],
                floatingActionButton: const AudioAccessibilityButton(),
                bottomNavigationBar: BottomNavBar(
                  currentIndex: currentIndex,
                  onTap: (i) {
                    setState(() => currentIndex = i);
                    context.read<AccessibilityProvider>().updateScreen(i);
                  },
                ),
              )
            : const LoginScreen(),
      ),
    );
  }
}
