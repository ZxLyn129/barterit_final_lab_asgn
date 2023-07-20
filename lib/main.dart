import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'interfaces/splash_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
        textTheme: GoogleFonts.aBeeZeeTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      title: 'BarterIt',
      home: const SplashPage(),
    );
  }
}
