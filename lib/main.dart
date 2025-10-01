import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const PixabayApp());
}

class PixabayApp extends StatelessWidget {
  const PixabayApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixabay Gallery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1a1a2e),
      ),
      home: const HomeScreen(),
    );
  }
}