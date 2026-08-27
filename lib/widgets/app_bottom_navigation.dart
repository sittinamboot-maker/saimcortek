import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/solar_project.dart';
import '../screens/equipment_screen.dart';
import '../screens/project_screen.dart';
import '../screens/projects_screen.dart';

class AppBottomNavigation extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final VoidCallback onSettings;
  const AppBottomNavigation(
      {super.key, required this.navigatorKey, required this.onSettings});

  @override
  State<AppBottomNavigation> createState() => _AppBottomNavigationState();
}

class _AppBottomNavigationState extends State<AppBottomNavigation> {
  int selectedIndex = 0;

  void _select(int index, VoidCallback action) {
    setState(() => selectedIndex = index);
    action();
  }

  void _push(Widget page) {
    widget.navigatorKey.currentState
        ?.push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .58),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x2B0277BD),
                  blurRadius: 16,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Row(
            children: [
              _item(0, _MenuMark.home, 'หน้าหลัก', () {
                widget.navigatorKey.currentState
                    ?.popUntil((route) => route.isFirst);
              }),
              _item(1, _MenuMark.folder, 'โปรเจกต์',
                  () => _push(const ProjectsScreen())),
              _createItem(),
              _item(3, _MenuMark.equipment, 'อุปกรณ์',
                  () => _push(EquipmentScreen(project: SolarProject()))),
              _item(4, _MenuMark.settings, 'ตั้งค่า', widget.onSettings),
            ],
              ),
            ),
          ),
        ),
      );

  Widget _createItem() => Expanded(
        child: InkWell(
          onTap: () =>
              _select(2, () => _push(ProjectScreen(project: SolarProject()))),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: selectedIndex == 2
                      ? const Color(0xFF29B6F6)
                      : const Color(0xFF90A4AE),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x3329B6F6),
                        blurRadius: 8,
                        offset: Offset(0, 3))
                  ]),
              child: const Center(
                child: Icon(Icons.add, color: Colors.white, size: 29),
              ),
            ),
            Text('สร้างโปรเจกต์',
                style: TextStyle(
                    color: selectedIndex == 2
                        ? const Color(0xFF0277BD)
                        : const Color(0xFF607D8B),
                    fontWeight: FontWeight.w600,
                    fontSize: 9.5)),
          ]),
        ),
      );

  Widget _item(int index, _MenuMark mark, String label, VoidCallback onTap) =>
      Expanded(
        child: InkWell(
          onTap: () => _select(index, onTap),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 42,
              height: 32,
              decoration: BoxDecoration(
                color: selectedIndex == index
                    ? const Color(0xFFE1F5FE)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: CustomPaint(
                  size: const Size.square(25),
                  painter: _MenuMarkPainter(
                    mark,
                    selectedIndex == index
                        ? const Color(0xFF0277BD)
                        : const Color(0xFF607D8B),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    color: selectedIndex == index
                        ? const Color(0xFF0277BD)
                        : const Color(0xFF607D8B),
                    fontWeight: selectedIndex == index
                        ? FontWeight.w700
                        : FontWeight.w500,
                    fontSize: 10.5)),
          ]),
        ),
      );
}

enum _MenuMark { home, folder, equipment, settings }

class _MenuMarkPainter extends CustomPainter {
  final _MenuMark mark;
  final Color color;
  const _MenuMarkPainter(this.mark, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final w = size.width;
    final h = size.height;

    switch (mark) {
      case _MenuMark.home:
        final roof = Path()
          ..moveTo(w * .12, h * .48)
          ..lineTo(w * .5, h * .15)
          ..lineTo(w * .88, h * .48);
        final house = Path()
          ..moveTo(w * .22, h * .42)
          ..lineTo(w * .22, h * .86)
          ..lineTo(w * .78, h * .86)
          ..lineTo(w * .78, h * .42);
        canvas.drawPath(roof, paint);
        canvas.drawPath(house, paint);
        canvas.drawRect(
            Rect.fromLTWH(w * .43, h * .61, w * .14, h * .25), paint);
      case _MenuMark.folder:
        final folder = Path()
          ..moveTo(w * .1, h * .31)
          ..lineTo(w * .4, h * .31)
          ..lineTo(w * .48, h * .41)
          ..lineTo(w * .9, h * .41)
          ..lineTo(w * .9, h * .82)
          ..lineTo(w * .1, h * .82)
          ..close();
        canvas.drawPath(folder, paint);
      case _MenuMark.equipment:
        for (final rect in [
          Rect.fromLTWH(w * .12, h * .13, w * .3, h * .3),
          Rect.fromLTWH(w * .58, h * .13, w * .3, h * .3),
          Rect.fromLTWH(w * .12, h * .57, w * .3, h * .3),
          Rect.fromLTWH(w * .58, h * .57, w * .3, h * .3),
        ]) {
          canvas.drawRRect(
              RRect.fromRectAndRadius(rect, const Radius.circular(2)), paint);
        }
      case _MenuMark.settings:
        canvas.drawCircle(Offset(w * .5, h * .5), w * .32, paint);
        canvas.drawCircle(Offset(w * .5, h * .5), w * .11, paint);
        for (var i = 0; i < 8; i++) {
          final angle = i * 3.141592653589793 / 4;
          final start = Offset(w * .5 + w * .34 * math.cos(angle),
              h * .5 + h * .34 * math.sin(angle));
          final end = Offset(w * .5 + w * .45 * math.cos(angle),
              h * .5 + h * .45 * math.sin(angle));
          canvas.drawLine(start, end, paint);
        }
    }
  }

  @override
  bool shouldRepaint(covariant _MenuMarkPainter oldDelegate) =>
      mark != oldDelegate.mark || color != oldDelegate.color;
}
