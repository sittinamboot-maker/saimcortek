import 'package:flutter/material.dart';

import '../theme/pvforge_theme.dart';
import 'pvforge_components.dart';

/// กราฟแท่งแนวนอนสำหรับ Peak Sun Hour ลากปรับค่าได้โดยตรงบนแท่งกราฟ
/// (เดิมมีแค่ช่องกรอกตัวเลขเปล่า ๆ ไม่มีภาพประกอบ)
class PeakSunHourChart extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  static const double maxScale = 8.0;

  const PeakSunHourChart({
    super.key,
    required this.value,
    required this.onChanged,
  });

  double _valueFromDx(double dx, double width) =>
      (dx / width * maxScale).clamp(0, maxScale).toDouble();

  @override
  Widget build(BuildContext context) {
    final fraction = (value / maxScale).clamp(0, 1).toDouble();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const GradientIconBadge(
                  icon: Icons.wb_sunny_rounded,
                  color: PVForgeColors.warning,
                  size: 30,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Peak Sun Hour',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                Text('${value.toStringAsFixed(1)} ชม./วัน',
                    style: const TextStyle(
                        color: PVForgeColors.warning,
                        fontWeight: FontWeight.w800,
                        fontSize: 16)),
              ],
            ),
            const SizedBox(height: 6),
            Text('ลากแถบด้านล่างเพื่อปรับค่าเฉลี่ยชั่วโมงแดดสูงสุดของพื้นที่ติดตั้ง',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 14),
            LayoutBuilder(builder: (context, box) {
              void handle(double dx) => onChanged(_valueFromDx(dx, box.maxWidth));
              return GestureDetector(
                onTapDown: (d) => handle(d.localPosition.dx),
                onPanStart: (d) => handle(d.localPosition.dx),
                onPanUpdate: (d) => handle(d.localPosition.dx),
                child: SizedBox(
                  height: 26,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: fraction,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFB74D), Color(0xFFEF6C00)],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment(fraction * 2 - 1, 0),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                                color: const Color(0xFFEF6C00), width: 2.4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .14),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                5,
                (i) => Text(
                    (i * maxScale / 4).toStringAsFixed(0),
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
