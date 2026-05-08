import 'package:flutter/material.dart';

class Win95Button extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool enabled;
  final Color? color;

  const Win95Button({
    super.key,
    required this.text,
    required this.onPressed,
    this.enabled = true,
    this.color,
  });

  @override
  State<Win95Button> createState() => _Win95ButtonState();
}

class _Win95ButtonState extends State<Win95Button> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.color ?? const Color(0xFFC0C0C0);

    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: widget.enabled
          ? () => setState(() => _pressed = false)
          : null,
      onTap: widget.enabled ? widget.onPressed : null,

      child: Transform.translate(
        offset: _pressed ? const Offset(1, 1) : Offset.zero,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.enabled ? bgColor : Colors.grey[400],
            border: Border(
              top: BorderSide(
                color: _pressed ? Colors.black : Colors.white,
                width: 2,
              ),
              left: BorderSide(
                color: _pressed ? Colors.black : Colors.white,
                width: 2,
              ),
              right: BorderSide(
                color: _pressed ? Colors.white : Colors.black,
                width: 2,
              ),
              bottom: BorderSide(
                color: _pressed ? Colors.white : Colors.black,
                width: 2,
              ),
            ),
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: widget.enabled ? Colors.black : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }
}
