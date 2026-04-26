import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app_theme.dart';
import 'screens/photo_poem_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const PhotoPoemApp());
}

class PhotoPoemApp extends StatelessWidget {
  const PhotoPoemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo To Poetry',
      debugShowCheckedModeBanner: false,
      theme: poeticTheme(context),
      home: const PhotoPoemScreen(),
    );
  }
}
