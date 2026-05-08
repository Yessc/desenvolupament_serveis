import 'package:flutter/material.dart';
import 'view/responsive_view.dart';

void main() {
  runApp(const NintendoApp());
}

class NintendoApp extends StatelessWidget {
  const NintendoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.red),
      home: const ResponsiveView(),
    );
  }
}