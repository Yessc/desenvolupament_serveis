import 'package:flutter/material.dart';

class Win95ColorButton extends StatefulWidget {
  final Color color;
  final ValueChanged<Color> onColorSelected;
  final bool enabled;

  const Win95ColorButton({
    super.key,
    required this.color,
    required this.onColorSelected,
    this.enabled = true,
  });

  @override
  State<Win95ColorButton> createState() => _Win95ColorButtonState();
}

class _Win95ColorButtonState extends State<Win95ColorButton> {
  void _openPicker() {
    final colors = [
      const Color(0xFFC0C0C0),
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.black,
    ];

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            "Colores",
            style: TextStyle(fontFamily: 'monospace'),
          ),
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: colors.map((c) {
              return GestureDetector(
                onTap: () {
                  widget.onColorSelected(c);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: c,
                    border: Border.all(color: Colors.black),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled ? _openPicker : null,
      child: Container(
        width: 90,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFFC0C0C0),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Row(
          children: [
            Expanded(child: Container(color: widget.color)),
            Container(
              width: 25,
              color: Colors.black12,
              child: const Icon(Icons.arrow_drop_down, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
