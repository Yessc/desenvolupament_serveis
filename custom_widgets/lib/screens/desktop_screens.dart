import 'package:flutter/material.dart';
import '../widgets/win95_window.dart';
import '../widgets/win95_contenido.dart';

class DesktopScreen extends StatefulWidget {
  const DesktopScreen({super.key});

  @override
  State<DesktopScreen> createState() => _DesktopScreenState();
}

class _DesktopScreenState extends State<DesktopScreen> {
  String? openedWindow;
  bool showStartMenu = false;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/image.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            if (openedWindow != null)
              Positioned(
                top: 120,
                left: 120,
                child: Win95Window(
                  title: openedWindow!,
                  darkMode: _darkMode,
                  child: Win95Content(
                    option: openedWindow!,
                    onThemeChanged: (value) {
                      setState(() {
                        _darkMode = value;
                      });
                    },
                  ),
                ),
              ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 40,
                color: const Color(0xFFC0C0C0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showStartMenu = !showStartMenu;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC0C0C0),
                          border: Border.all(color: Colors.black),
                        ),
                        child: const Text("Inicio"),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (showStartMenu)
              Positioned(
                bottom: 40,
                left: 0,
                child: Container(
                  width: 200,
                  color: const Color(0xFFC0C0C0),
                  child: Column(
                    children: [
                      Container(
                        height: 35,
                        width: double.infinity,
                        color: const Color(0xFF000080),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: const Text(
                          "Windows 95",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      _menuItem("Introducció"),
                      _menuItem("Botons"),
                      _menuItem("Progress"),
                      _menuItem("Tema"),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          openedWindow = title;
          showStartMenu = false;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        child: Text(title),
      ),
    );
  }
}
