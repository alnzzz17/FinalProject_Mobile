import 'package:flutter/material.dart';
import 'dart:math';

class CompassWidget extends StatelessWidget {
  final double? heading;
  final double size;

  const CompassWidget({
    super.key,
    required this.heading,
    this.size = 300,
  });

  @override
  Widget build(BuildContext context) {
    if (heading == null) {
      return SizedBox(
        width: size,
        height: size,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: CompassPainter(angle: heading!),
          ),
          Text(
            _getDirectionLetter(heading!),
            style: TextStyle(
              color: Colors.blue[800],
              fontSize: 82,
            ),
          ),
        ],
      ),
    );
  }

  String _getDirectionLetter(double heading) {
    heading = heading % 360;

    if (heading >= 337.5 || heading < 22.5) return 'N';
    if (heading >= 22.5 && heading < 67.5) return 'NE';
    if (heading >= 67.5 && heading < 112.5) return 'E';
    if (heading >= 112.5 && heading < 157.5) return 'SE';
    if (heading >= 157.5 && heading < 202.5) return 'S';
    if (heading >= 202.5 && heading < 247.5) return 'SW';
    if (heading >= 247.5 && heading < 292.5) return 'W';
    return 'NW';
  }
}

class CompassPainter extends CustomPainter {
  final double angle;

  const CompassPainter({required this.angle});

  double get rotation => -angle * pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);

    // Draw compass base
    Paint circle = Paint()
      ..strokeWidth = 2
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Paint shadowCircle = Paint()
      ..strokeWidth = 2
      ..color = Colors.grey.withOpacity(.2)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset.zero, size.width / 2, circle);

    // Draw markers
    Paint darkMarker = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    Paint lightMarker = Paint()
      ..color = Colors.grey
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.rotate(-pi / 2);

    // Light markers every 22.5°
    for (int i = 1; i <= 16; i++) {
      canvas.drawLine(
        Offset.fromDirection(
            -(angle + 22.5 * i) * pi / 180, size.width / 2 - 40),
        Offset.fromDirection(
            -(angle + 22.5 * i) * pi / 180, size.width / 2 - 20),
        lightMarker,
      );
    }

    // Dark markers every 90°
    for (int i = 1; i <= 3; i++) {
      canvas.drawLine(
        Offset.fromDirection(-(angle + 90 * i) * pi / 180, size.width / 2 - 40),
        Offset.fromDirection(-(angle + 90 * i) * pi / 180, size.width / 2 - 20),
        darkMarker,
      );
    }

    // Draw north indicator
    Paint northIndicator = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    Path path = Path();
    path.moveTo(
      Offset.fromDirection(rotation, size.width / 2 - 15).dx,
      Offset.fromDirection(rotation, size.width / 2 - 15).dy,
    );
    path.lineTo(
      Offset.fromDirection(-(angle + 15) * pi / 180, size.width / 2 - 40).dx,
      Offset.fromDirection(-(angle + 15) * pi / 180, size.width / 2 - 40).dy,
    );
    path.lineTo(
      Offset.fromDirection(-(angle - 15) * pi / 180, size.width / 2 - 40).dx,
      Offset.fromDirection(-(angle - 15) * pi / 180, size.width / 2 - 40).dy,
    );
    path.close();
    canvas.drawPath(path, northIndicator);

    // Draw inner circle with shadow
    canvas.drawCircle(Offset.zero, size.width / 2 - 32, shadowCircle);
    canvas.drawCircle(Offset.zero, size.width / 2 - 35, circle);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Source: https://medium.com/@fnmghaithi/create-a-compass-app-in-flutter-0a06210a0133