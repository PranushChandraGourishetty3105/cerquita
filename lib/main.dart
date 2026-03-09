import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: "Cerquita",

      theme: ThemeData(

        useMaterial3: true,

        /* ===== PRIMARY COLOR ===== */
        primaryColor: const Color(0xFFFF6B00),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B00),
        ),

        /* ===== APP BACKGROUND ===== */
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),

        /* ===== APP BAR ===== */
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.black),

          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        /* ===== BUTTON STYLE ===== */
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(

            backgroundColor: const Color(0xFFFF6B00),
            foregroundColor: Colors.white,

            minimumSize: const Size(double.infinity, 52),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),

            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),

          ),
        ),

        /* ===== INPUT FIELDS ===== */
        inputDecorationTheme: InputDecorationTheme(

          filled: true,
          fillColor: Colors.white,

          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFFF6B00),
              width: 1.5,
            ),
          ),

        ),

        /* ===== CARD DESIGN ===== */
        cardTheme: CardThemeData(
          elevation: 4,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),

        /* ===== ICON STYLE ===== */
        iconTheme: const IconThemeData(
          color: Color(0xFFFF6B00),
        ),

      ),

      home: const SplashScreen(),

    );
  }
}