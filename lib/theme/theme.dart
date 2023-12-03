import 'package:flutter/material.dart';

final Color accentColor = Color(0xFF009688);
final Color myDarkBackground = Color(0xFF121212);
ThemeData lightMode = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.grey.shade200, // Set the fill color to grey 200
        ),
    colorScheme:
        ColorScheme.light(
            background: Colors.white,
            primary: accentColor,
        ),
);
// ThemeData darkMode = ThemeData(
//     brightness: Brightness.dark,
//     useMaterial3: true,
//
//     inputDecorationTheme: InputDecorationTheme(
//             filled: true,
//             fillColor: Colors.grey.shade400, // Set the fill color to grey 200
//
//     ),
//     colorScheme: ColorScheme.dark(
//         background: myDarkBackground, primary: accentColor,));
