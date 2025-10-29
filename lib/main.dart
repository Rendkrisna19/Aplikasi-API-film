import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const MoviesApp());
}

class MoviesApp extends StatelessWidget {
  const MoviesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0EA5E9),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MovieAPI (OMDb)',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFF0B0B0D),

        // ✅ CardTheme yang kompatibel Material 3 (hindari tint abu-abu)
      
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B0B0D),
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const HomePage(),
    );
  }
}
