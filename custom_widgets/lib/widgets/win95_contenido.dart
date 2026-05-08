import 'package:flutter/material.dart';
import '../widgets/win95_button.dart';
import '../widgets/win95_color_button.dart';

class Win95Content extends StatefulWidget {
  final String option;
  final ValueChanged<bool>? onThemeChanged;

  const Win95Content({super.key, required this.option, this.onThemeChanged});

  @override
  State<Win95Content> createState() => _Win95ContentState();
}

class _Win95ContentState extends State<Win95Content> {
  bool _enabled = true;
  Color _buttonColor = const Color(0xFFC0C0C0);
  double _progress = 0.0;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    switch (widget.option) {
      case "Introducció":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Introducció a Windows 95",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Aquest es un sistema d'escriptori simulat a Flutter.\n\n"
              "S'han utilitzat widgets personalitzats per simular una interfície d'estil Windows 95.",
              style: TextStyle(fontFamily: 'monospace'),
            ),
          ],
        );

      case "Botons":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "BOTONS",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),

            const SizedBox(height: 10),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Deshabilitar",
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _enabled,
                      onChanged: (value) {
                        setState(() {
                          _enabled = value!;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            Win95Button(
              text: "OK",
              enabled: _enabled,
              color: _buttonColor,
              onPressed: () {},
            ),
            const Text(
              "Colors:",
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),
            Win95ColorButton(
              color: _buttonColor,
              enabled: _enabled,
              onColorSelected: (color) {
                setState(() {
                  _buttonColor = color;
                });
              },
            ),
          ],
        );

      case "Progress":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Carregant sistema..."),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: () {
                setState(() {
                  _progress += 0.1;
                  if (_progress > 1.0) _progress = 1.0;
                });
              },
              child: LinearProgressIndicator(value: _progress, minHeight: 10),
            ),

            const SizedBox(height: 10),

            Text(
              "${(_progress * 100).toInt()}%",
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ],
        );

      case "Tema":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tema",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Radio<bool>(
                  value: false,
                  groupValue: _darkMode,
                  onChanged: (value) {
                    setState(() {
                      _darkMode = value!;
                    });
                    widget.onThemeChanged?.call(value!);
                  },
                ),
                const Text("Clar"),
              ],
            ),

            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: _darkMode,
                  onChanged: (value) {
                    setState(() {
                      _darkMode = value!;
                    });
                    widget.onThemeChanged?.call(value!);
                  },
                ),
                const Text("Fosc"),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              _darkMode ? "Modo fosc activat" : "Modo clar activat",
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ],
        );

      default:
        return const Text("Selecciona una opción del menú");
    }
  }
}
