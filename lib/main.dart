import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_provider.dart';
import 'firebase_options.dart';
import 'screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(create: (_) => AppProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appProv = Provider.of<AppProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ứng dụng nghe nhạc online',
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      themeMode: appProv.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AuthScreen(),
    );
  }
}
