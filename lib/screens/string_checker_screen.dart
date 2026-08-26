import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../models/solar_project.dart';
import 'summary_screen.dart';

/// หน้าจัดเรียง String / ตรวจสอบ MPPT เท่านั้น — การเลือก Boost / MPPT
/// (หรือ Inverter สำหรับระบบ On-grid/Hybrid) ถูกแยกไปเป็นหน้าของตัวเองแล้ว
/// ก่อนถึงหน้านี้ (ดู boost_mppt_selection_screen.dart และ
/// inverter_selection_screen.dart) เพื่อไม่ให้ปนกัน
class StringCheckerScreen extends StatefulWidget {
  final SolarProject project;
  const StringCheckerScreen({super.key, required this.project});

  @override
  State<StringCheckerScreen> createState() => _StringCheckerScreenState();
}

class _StringCheckerScreenState extends State<StringCheckerScreen> {
  late int panelsPerString;
  late int strings;
  late int totalPanels;

  @override
  void initState() {
    super.initState();
    totalPanels = widget.project.recommendedPanels;
    final minimumPanels = math.max(
      1,
      (widget.project.inverterMpptMin / widget.project.panelVmp).ceil(),
    );
    strings = totalPanels >= minimumPanels * 2
        ? math.min(2, widget.project.inverterMpptCount)
        : 1;
    panelsPerString = (totalPanels / strings).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final voc = p.panelVoc * panelsPerString;
    final vmp = p.panelVmp * panelsPerString;
    final currentPerMppt = p.panelImp;
    final coldVoc = voc * 1.12;

    final vocOk = coldVoc <= p.inverterMaxDcVoltage;
    final vmpOk = vmp >= p.inverterMpptMin && vmp <= p.inverterMpptMax;
    final currentOk = currentPerMppt <= p.inverterMaxInputCurrent;
    final allOk = vocOk && vmpOk && currentOk;

    return Scaffold(
      appBar: AppBar(title: const Text('จัดเรียง String / ตรวจสอบ MPPT')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.inverterModel,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('${p.inverterKw.toStringAsFixed(1)} kW • ${p.inverterMpptCount} MPPT • '
                    '${p.inverterMpptMin.toStringAsFixed(0)}–${p.inverterMpptMax.toStringAsFixed(0)} V • '
                    '${p.inverterMaxInputCurrent.toStringAsFixed(0)} A'),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: _numberPicker(
                              'แผง / String',
                              panelsPerString,
                              1,
                              30,
                              (v) => _updateDiagram(() {
                                    panelsPerString = v;
                                    totalPanels = v * strings;
                                  }))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _numberPicker(
                              'จำนวน String',
                              strings,
                              1,
                              math.min(widget.project.inverterMpptCount,
                                  math.max(1, totalPanels)),
                              (v) => _updateDiagram(() {
                                    strings = v;
                                    panelsPerString =
                                        (totalPanels / strings).ceil();
                                  }))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'จัดอัตโนมัติจากผลคำนวณ $totalPanels แผง: ${_distributionText()}',
                    style: const TextStyle(
                        color: Color(0xFF29B6F6),
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  AnimatedStringDiagram(
                    panelsPerString: panelsPerString,
                    strings: strings,
                    totalPanels: totalPanels,
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, size: 9, color: Color(0xFF29B6F6)),
                      SizedBox(width: 5),
                      Text('จุดเคลื่อนที่แสดงทิศทางพลังงาน DC',
                          style:
                              TextStyle(fontSize: 11, color: Colors.black54)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _check('Voc String (STC)', voc, p.inverterMaxDcVoltage,
              voc <= p.inverterMaxDcVoltage),
          _check('Cold Voc (+12%)', coldVoc, p.inverterMaxDcVoltage, vocOk),
          _checkRange(
              'Vmp String', vmp, p.inverterMpptMin, p.inverterMpptMax, vmpOk),
          _check('กระแสต่อ MPPT', currentPerMppt, p.inverterMaxInputCurrent,
              currentOk,
              unit: 'A'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: allOk ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: allOk ? Colors.green : Colors.red),
            ),
            child: Row(
              children: [
                Icon(allOk ? Icons.check_circle : Icons.warning_amber,
                    color: allOk ? Colors.green : Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    allOk
                        ? 'PASS — อยู่ในช่วงการทำงานของ Inverter'
                        : 'WARNING — ตรวจสอบการจัด String',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: allOk
                            ? Colors.green.shade800
                            : Colors.red.shade800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SummaryScreen(project: p)),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('สรุประบบ / BOQ'),
            ),
          ),
        ],
      ),
    );
  }

  String _distributionText() {
    final base = totalPanels ~/ strings;
    final remainder = totalPanels % strings;
    return List.generate(strings, (i) => '${base + (i < remainder ? 1 : 0)}')
        .join(' + ');
  }

  Widget _numberPicker(
      String label, int value, int min, int max, ValueChanged<int> onChanged) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (int i = min; i <= max; i++)
          DropdownMenuItem(value: i, child: Text('$i'))
      ],
      onChanged: (v) => onChanged(v ?? value),
    );
  }

  void _updateDiagram(VoidCallback update) {
    // Dropdown changes can arrive while Windows is still updating mouse
    // annotations. Defer the layout change to the next frame to avoid a nested
    // MouseTracker device update in Flutter desktop debug mode.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        update();
        // บันทึกจำนวนแผงที่ผู้ใช้ปรับเอง (แผง/String หรือจำนวน String) กลับ
        // เข้า project ด้วย ไม่งั้นหน้าอื่น (สรุประบบ/BOQ, kWp, พื้นที่หลังคา
        // ฯลฯ) จะยังใช้ค่าที่คำนวณอัตโนมัติเดิม ไม่ตรงกับที่จัดไว้จริง
        widget.project.manualPanelCount = totalPanels;
      });
    });
  }

  Widget _check(String label, double value, double max, bool ok,
          {String unit = 'V'}) =>
      Card(
        child: ListTile(
          title: Text(label),
          subtitle: Text(
              '${value.toStringAsFixed(1)} $unit / Limit ${max.toStringAsFixed(0)} $unit'),
          trailing: Icon(ok ? Icons.check_circle : Icons.cancel,
              color: ok ? Colors.green : Colors.red),
        ),
      );

  Widget _checkRange(
          String label, double value, double min, double max, bool ok) =>
      Card(
        child: ListTile(
          title: Text(label),
          subtitle: Text(
              '${value.toStringAsFixed(1)} V / MPPT ${min.toStringAsFixed(0)}–${max.toStringAsFixed(0)} V'),
          trailing: Icon(ok ? Icons.check_circle : Icons.cancel,
              color: ok ? Colors.green : Colors.red),
        ),
      );
}

class AnimatedStringDiagram extends StatefulWidget {
  final int panelsPerString;
  final int strings;
  final int totalPanels;

  const AnimatedStringDiagram({
    super.key,
    required this.panelsPerString,
    required this.strings,
    required this.totalPanels,
  });

  @override
  State<AnimatedStringDiagram> createState() => _AnimatedStringDiagramState();
}

class _AnimatedStringDiagramState extends State<AnimatedStringDiagram>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = math.max(180.0, widget.strings * 62.0 + 54);
    return SizedBox(
      width: double.infinity,
      height: height,
      child: IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(
            isComplex: true,
            willChange: true,
            painter: _StringFlowPainter(
              panelsPerString: widget.panelsPerString,
              strings: widget.strings,
              totalPanels: widget.totalPanels,
              animation: _controller,
            ),
          ),
        ),
      ),
    );
  }
}

class _StringFlowPainter extends CustomPainter {
  final int panelsPerString;
  final int strings;
  final int totalPanels;
  final Animation<double> animation;

  static const _stringColors = [
    Color(0xFF29B6F6),
    Color(0xFF16A36A),
    Color(0xFFE97716),
    Color(0xFF8B5CF6),
    Color(0xFFE83E68),
    Color(0xFF0891B2),
  ];

  _StringFlowPainter({
    required this.panelsPerString,
    required this.strings,
    required this.totalPanels,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    const labelWidth = 43.0;
    const inverterWidth = 65.0;
    final busX = size.width - inverterWidth - 13;
    final inverterLeft = size.width - inverterWidth;
    final top = 30.0;
    final rowHeight = (size.height - top - 18) / strings;
    final firstY = top + rowHeight / 2;
    final lastY = top + rowHeight * (strings - .5);

    final inverterRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(inverterLeft, firstY - 27, inverterWidth - 2,
          math.max(62, lastY - firstY + 54)),
      const Radius.circular(9),
    );
    canvas.drawRRect(inverterRect, Paint()..color = const Color(0xFF2F3440));
    _text(canvas, 'INVERTER', Offset(inverterLeft + 7, firstY - 12),
        Colors.white, 8, FontWeight.bold);
    _text(canvas, 'MPPT', Offset(inverterLeft + 16, firstY + 2),
        const Color(0xFF59B5FF), 9, FontWeight.bold);

    for (var stringIndex = 0; stringIndex < strings; stringIndex++) {
      final basePanels = totalPanels ~/ strings;
      final rowPanels =
          basePanels + (stringIndex < totalPanels % strings ? 1 : 0);
      final color = _stringColors[stringIndex % _stringColors.length];
      final y = top + rowHeight * (stringIndex + .5);
      _text(canvas, 'S${stringIndex + 1}',
          const Offset(4, 0) + Offset(0, y - 6), color, 10, FontWeight.bold);

      final panelStart = labelWidth;
      final panelEnd = busX - 9;
      const gap = 2.0;
      final available = panelEnd - panelStart;
      final panelWidth = math.min(
        20.0,
        math.max(3.0, (available - gap * (rowPanels - 1)) / rowPanels),
      );
      final usedWidth = panelWidth * rowPanels + gap * (rowPanels - 1);
      final startX = panelStart + math.max(0, available - usedWidth);

      for (var panel = 0; panel < rowPanels; panel++) {
        final x = startX + panel * (panelWidth + gap);
        final rect = RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(x + panelWidth / 2, y),
              width: panelWidth,
              height: 31),
          const Radius.circular(2.5),
        );
        canvas.drawRRect(rect, Paint()..color = const Color(0xFF81D4FA));
        if (panelWidth >= 8) {
          final gridPaint = Paint()
            ..color = Colors.white54
            ..strokeWidth = .5;
          canvas.drawLine(Offset(x + panelWidth / 2, y - 12),
              Offset(x + panelWidth / 2, y + 12), gridPaint);
          canvas.drawLine(
              Offset(x + 2, y), Offset(x + panelWidth - 2, y), gridPaint);
        }
        if (panel > 0) {
          canvas.drawLine(
            Offset(x - gap, y),
            Offset(x, y),
            Paint()
              ..color = color
              ..strokeWidth = 1.5,
          );
        }
      }

      final lineStartX = startX + usedWidth;
      final path = Path()
        ..moveTo(lineStartX, y)
        ..lineTo(busX, y)
        ..lineTo(inverterLeft, y);
      canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke);

      for (var particle = 0; particle < 3; particle++) {
        final progress =
            (animation.value + particle / 3 + stringIndex * .08) % 1;
        final x = lineStartX + (inverterLeft - lineStartX) * progress;
        canvas.drawCircle(
          Offset(x, y),
          3.2,
          Paint()..color = const Color(0xFF29B6F6),
        );
      }
    }
  }

  void _text(Canvas canvas, String text, Offset offset, Color color,
      double size, FontWeight weight) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: size, fontWeight: weight),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _StringFlowPainter oldDelegate) =>
      oldDelegate.panelsPerString != panelsPerString ||
      oldDelegate.strings != strings ||
      oldDelegate.totalPanels != totalPanels;
}
