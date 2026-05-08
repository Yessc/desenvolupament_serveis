import 'package:flutter/material.dart';

abstract class Drawable {
  final String id; 
  Drawable({required this.id});
  void draw(Canvas canvas);
}

class Line extends Drawable {
  final Offset start;
  final Offset end;
  final Color color;
  final double strokeWidth;

  Line({
    required super.id,
    required this.start,
    required this.end,
    this.color = Colors.black,
    this.strokeWidth = 2.0,
  });

  @override
  void draw(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, paint);
  }
}

class Rectangle extends Drawable {
  final Offset topLeft;
  final Offset bottomRight;
  final Color strokeColor;
  final Color? fillColor;
  final double strokeWidth;


  Rectangle({
    required super.id,
    required this.topLeft,
    required this.bottomRight,
    this.strokeColor = Colors.black,
    this.fillColor,
    this.strokeWidth = 2.0,
  });

  @override
  void draw(Canvas canvas) {
    final rect = Rect.fromPoints(topLeft, bottomRight);
    if (fillColor != null) {
      canvas.drawRect(rect, Paint()..color = fillColor!..style = PaintingStyle.fill);
    }
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, paint);
  }
}

class Circle extends Drawable {
  final Offset center;
  final double radius;
  final Color strokeColor;
  final Color? fillColor;
  final double strokeWidth;

  Circle({
    required super.id,
    required this.center,
    required this.radius,
    this.strokeColor =Colors.black,
    this.fillColor,
    this.strokeWidth = 2.0,
  });

  @override
  void draw(Canvas canvas) {
    if (fillColor != null) {
      canvas.drawCircle(center, radius, Paint()..color = fillColor!..style = PaintingStyle.fill);
    }
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, paint);
  }
}

class TextElement extends Drawable {
  final String text;
  final Offset position;
  final Color color;
  final double fontSize;
  final bool isBold;

  TextElement({
    required super.id,
    required this.text,
    required this.position,
    this.color = Colors.black,
    this.fontSize = 20.0,
    this.isBold =false,
  });

  @override
  void draw(Canvas canvas) {
    final textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    );
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }
}
