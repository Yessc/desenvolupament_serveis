import 'package:flutter/material.dart';

class Win95Window extends StatefulWidget {
  final String title;
  final Widget child;
  final bool darkMode;

  const Win95Window({
    super.key,
    required this.title,
    required this.child,
    this.darkMode = false,
  });

  @override
  State<Win95Window> createState() => _Win95WindowState();
}

class _Win95WindowState extends State<Win95Window> {
  double top = 100;
  double left = 100;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,

      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            left += details.delta.dx;
            top += details.delta.dy;
          });
        },

        child: Container(
          width: 500,
          height: 450,
          color: widget.darkMode ? const Color(0xFF1E1E1E) : Colors.white,

          child: Column(
            children: [
              Container(
                height: 28,
                color: widget.darkMode
                    ? const Color(0xFF3A3A3A)
                    : const Color.fromARGB(255, 8, 44, 206),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          color: widget.darkMode
                              ? Colors.white
                              : const Color.fromARGB(255, 206, 205, 205),
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(4),
                      padding: const EdgeInsets.symmetric(horizontal: 6),

                      decoration: BoxDecoration(
                        color: widget.darkMode
                            ? const Color(0xFF555555)
                            : const Color(0xFFC0C0C0),
                        border: Border.all(color: Colors.black),
                      ),

                      child: const Text("X", style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),

                  color: widget.darkMode
                      ? const Color(0xFF2B2B2B)
                      : Colors.white,

                  child: DefaultTextStyle(
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: widget.darkMode ? Colors.white : Colors.black,
                    ),

                    child: widget.child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
