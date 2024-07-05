import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ClockWidget extends StatefulWidget {
  const ClockWidget({super.key});

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 5,
              blurRadius: 12,
              offset: const Offset(10, 15),
            ),
          ]),
      height: 300.0,
      width: 300.0,
      child: CustomPaint(
        painter: ClockPainter(),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var centerX = size.width / 2;
    var centerY = size.height / 2;
    var center = Offset(centerX, centerY);
    var radius = min(centerX, centerY);

    var fillBrush = Paint()..color = const Color.fromRGBO(240, 245, 248, 1);

    var outlineBrush = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    var minHandBrush = Paint()
      ..color = const Color.fromRGBO(252, 62, 85, .84)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    var hourHandBrush = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6;

    var dashBrush = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius - 10, fillBrush);
    canvas.drawCircle(center, radius - 10, outlineBrush);

    var dateTime = DateTime.now();

    var hourHandX = centerX +
        60 *
            cos((dateTime.hour * 30 + dateTime.minute * 0.5) * pi / 180 -
                pi / 2);
    var hourHandY = centerY +
        60 *
            sin((dateTime.hour * 30 + dateTime.minute * 0.5) * pi / 180 -
                pi / 2);
    canvas.drawLine(center, Offset(hourHandX, hourHandY), hourHandBrush);

    var minHandX = centerX + 80 * cos(dateTime.minute * 6 * pi / 180 - pi / 2);
    var minHandY = centerY + 80 * sin(dateTime.minute * 6 * pi / 180 - pi / 2);
    canvas.drawLine(center, Offset(minHandX, minHandY), minHandBrush);

    var outerCircleRadius = radius - 10;
    var innerCircleRadius = radius - 20;

    for (var i = 0; i < 60; i++) {
      var angle = i * 6 * pi / 180;
      var x1 = centerX + outerCircleRadius * cos(angle);
      var y1 = centerY + outerCircleRadius * sin(angle);

      var x2 = centerX + innerCircleRadius * cos(angle);
      var y2 = centerY + innerCircleRadius * sin(angle);

      if (i % 15 == 0) {
        var numberAngle = i * 6 * pi / 180;
        var numberX = centerX + (innerCircleRadius - 10) * cos(numberAngle);
        var numberY = centerY + (innerCircleRadius - 10) * sin(numberAngle);

        String text;
        switch (i) {
          case 0:
            text = '3';
            break;
          case 15:
            text = '6';
            break;
          case 30:
            text = '9';
            break;
          case 45:
            text = '12';
            break;
          default:
            text = '';
        }

        TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(numberX - textPainter.width / 2,
              numberY - textPainter.height / 2),
        );
      } else if (i % 5 == 0) {
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), dashBrush);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
