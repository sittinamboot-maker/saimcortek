import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../models/solar_project.dart';
import '../theme/pvforge_theme.dart';
import '../widgets/pvforge_components.dart';
import 'panel_selection_screen.dart';

class ResultScreen extends StatefulWidget {
  final SolarProject project;
  const ResultScreen({super.key, required this.project});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ModernGaugePainter extends CustomPainter {
  final double value;

  const _ModernGaugePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    const startAngle = math.pi * .75;
    const totalSweep = math.pi * 1.5;
    final center = Offset(size.width / 2, size.height / 2 - 2);
    final radius = math.min(size.width, size.height) / 2 - 18;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      rect,
      startAngle,
      totalSweep,
      false,
      Paint()
        ..color = const Color(0xFFE1F5FE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round,
    );
    if (value <= 0) return;

    canvas.drawArc(
      rect,
      startAngle,
      totalSweep * value,
      false,
      Paint()
        ..shader = const SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + totalSweep,
          colors: [
            Color(0xFFB3E5FC),
            Color(0xFF29B6F6),
            Color(0xFF0277BD),
          ],
          stops: [0, .52, 1],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ModernGaugePainter oldDelegate) =>
      oldDelegate.value != value;
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final targetCoverage = p.solarDailyEnergyTarget <= 0
        ? 0.0
        : (p.estimatedDailyProduction / p.solarDailyEnergyTarget)
            .clamp(0, 1)
            .toDouble();
    return Scaffold(
      appBar: AppBar(title: const Text('ผลการคำนวณระบบ')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('ผลการคำนวณ',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 16),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: targetCoverage),
                    duration: const Duration(milliseconds: 1100),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedCoverage, _) => SizedBox(
                      width: 190,
                      height: 172,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _ModernGaugePainter(animatedCoverage),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('ขนาดระบบแนะนำ',
                                  style: TextStyle(
                                      color: Color(0xFF0277BD), fontSize: 11)),
                              Text(p.systemKwp.toStringAsFixed(2),
                                  style: const TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w900)),
                              const Text('kWp'),
                              const SizedBox(height: 3),
                              Text(
                                'ครอบคลุม ${(animatedCoverage * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                    color: Color(0xFF29B6F6),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const Positioned(
                            left: 4,
                            bottom: 4,
                            child: Text('0%',
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 10)),
                          ),
                          const Positioned(
                            right: 0,
                            bottom: 4,
                            child: Text('100%',
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 10)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                      'ผลิตไฟประมาณ ${p.estimatedDailyProduction.toStringAsFixed(1)} kWh/วัน'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text('รายละเอียดการคำนวณ',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          ),
          _row('พลังงานรวมต่อเดือน', '${p.monthlyKwh.toStringAsFixed(1)} kWh'),
          if (p.isAirSolarSystem) ...[
            _row('ระบบที่ออกแบบ', 'แอร์โซล่าเซลล์'),
            _row('เครื่องปรับอากาศ',
                '${p.airConditionerBtu.toString()} BTU/h × ${p.airConditionerCount} เครื่อง'),
            _row('พลังงานแอร์',
                '${p.airConditionerDailyKwh.toStringAsFixed(1)} kWh/วัน'),
          ],
          _row('พลังงานรวมต่อวัน', '${p.dailyKwh.toStringAsFixed(1)} kWh'),
          _row('ไฟช่วงกลางวัน', '${p.dayKwhPerDay.toStringAsFixed(1)} kWh/วัน'),
          _row('ไฟช่วงกลางคืน',
              '${p.nightKwhPerDay.toStringAsFixed(1)} kWh/คืน'),
          _row('Peak Sun Hour', '${p.peakSunHours.toStringAsFixed(1)} ชม./วัน',
              onTap: _editPeakSunHour),
          _row('System Loss', '${p.totalSystemLoss.toStringAsFixed(0)}%'),
          _row('จำนวนแผงแนะนำ', '${p.recommendedPanels} แผง'),
          if (p.hasBattery)
            _row('เป้าหมายผลิตไฟของแผง',
                '${p.solarDailyEnergyTarget.toStringAsFixed(1)} kWh/วัน'),
          if (p.hasBattery)
            _row('พลังงานชาร์จแบตเต็ม',
                '${p.batteryDailyChargeEnergy.toStringAsFixed(1)} kWh/วัน'),
          _row('กำลังแผง', '${p.panelWatt.toStringAsFixed(0)} W'),
          _row('พื้นที่ที่ใช้โดยประมาณ',
              '${p.estimatedRoofArea.toStringAsFixed(1)} m²'),
          if (p.hasBattery) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        GradientIconBadge(
                            icon: Icons.battery_charging_full,
                            color: PVForgeColors.battery,
                            size: 34),
                        SizedBox(width: 10),
                        Text('ระบบแบตเตอรี่',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                        'แบตเตอรี่ที่มี ${p.batteryCapacityKwh.toStringAsFixed(1)} kWh'),
                    Text(
                      'ฐานคำนวณ: ${p.sizeBatteryFromNightUsage ? 'ไฟกลางคืน' : 'ชั่วโมงสำรอง'} '
                      '${p.batteryEnergyTarget.toStringAsFixed(1)} kWh',
                    ),
                    Text(
                        'ความจุแนะนำ ${p.recommendedBatteryCapacity.toStringAsFixed(1)} kWh'),
                    Text(
                        'สำรองไฟได้ประมาณ ${p.estimatedBatteryBackupHours.toStringAsFixed(1)} ชั่วโมง'),
                    Text(
                        'ครอบคลุมไฟกลางคืน ${p.estimatedNightCoveragePercent.toStringAsFixed(0)}%'),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => PanelSelectionScreen(project: p)),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('ถัดไป: เลือกแผงอัตโนมัติ'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editPeakSunHour() async {
    final controller = TextEditingController(
        text: widget.project.peakSunHours.toStringAsFixed(1));
    final value = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ปรับ Peak Sun Hour'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Peak Sun Hour',
            suffixText: 'ชม./วัน',
            helperText: 'กำหนดได้ตั้งแต่ 0.1–24 ชั่วโมง',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () {
              final parsed = double.tryParse(controller.text);
              if (parsed == null || parsed < 0.1 || parsed > 24) return;
              Navigator.pop(dialogContext, parsed);
            },
            child: const Text('บันทึกและคำนวณใหม่'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null || !mounted) return;
    setState(() => widget.project.peakSunHours = value);
  }

  Widget _row(String a, String b, {VoidCallback? onTap}) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: InkWell(
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(a),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(b,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (onTap != null) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.edit_outlined,
                          size: 17, color: Color(0xFF29B6F6)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
