import 'dart:math';

import 'package:bird_tracker/model/species.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WorldSidePicker extends StatelessWidget {
  const WorldSidePicker(
      {super.key, this.selectedSide, this.onChanged, this.color, this.radius});

  final Direction? selectedSide;
  final Function(dynamic)? onChanged;
  final Color? color;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    double size = ((radius ?? 80.0) + 20) * 2 + 50;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            top: size /4,
            left: size /4,
            child: SvgPicture.asset(
              'assets/icons/compass.svg',
              width: size / 2,
              height: size / 2,
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: CirclePainter(color: color, radius: radius ?? 80.0),
            ),
          ),
          for (int i = 0; i < 16; i++)
            Positioned(
              top: (size / 2) + ((radius ?? 80) + 20) * sin(2 * pi * (i - 4) / 16) - 15,
              left: (size / 2) + ((radius ?? 80) + 20) * cos(2 * pi * (i - 4) / 16) - 15,
              child: GestureDetector(
                onTap: () {
                  if (onChanged != null) {
                    onChanged!(Direction.values[i]);
                  }
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: selectedSide == Direction.values[i]
                        ? color ?? const Color(0xFF0F9D58)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      Direction.values[i].isSub() ? Direction.values[i].toShortString().toLowerCase() : Direction.values[i].toShortString(),
                      style: TextStyle(
                        fontSize: Direction.values[i].isSub() ? 10 :  12,
                        fontWeight: Direction.values[i].isSub() ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 20,
            top: 3,
            child: Container(
              padding: const EdgeInsets.only(left: 5, right: 5),
              color: Colors.white,
              child: Text(Direction.values.first.toString().split('.').first,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  )),
            ),
          ),
          Positioned(
            right: 2,
            top: 3,
            child: Container(
              // padding: const EdgeInsets.only(left: 5, right: 5),
              color: Colors.white,
              child: SizedBox(
                height: 20,
                width: 20,
                child: IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: Colors.red),
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.all(0),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.grey.shade300,
                    ),
                  ),
                  onPressed: () {
                    if (onChanged != null) {
                      onChanged!(null);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  const CirclePainter({this.color, this.radius = 80.0});
  final Color? color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color ?? const Color(0xFF0F9D58)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
