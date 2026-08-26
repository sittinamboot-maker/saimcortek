import 'dart:math' as math;
import 'package:flutter/material.dart';

class DailyLoadChart extends StatefulWidget {
  final double totalKwh;
  final double dayKwh;
  final double nightKwh;
  // ชั่วโมงแดดสูงสุด (Peak Sun Hour) ใช้วาดเป็นกราฟรูปโดมสีส้ม กึ่งกลางที่
  // เวลา 12:00 แล้วขยายออกสองข้างเท่า ๆ กันตามค่านี้ ทับอยู่บนกราฟการใช้ไฟ
  final double peakSunHours;
  final void Function(double day, double night) onChanged;
  const DailyLoadChart(
      {super.key,
      required this.totalKwh,
      required this.dayKwh,
      required this.nightKwh,
      required this.peakSunHours,
      required this.onChanged});
  @override
  State<DailyLoadChart> createState() => _DailyLoadChartState();
}

class _DailyLoadChartState extends State<DailyLoadChart> {
  late List<double> values;
  int selectedHour = 12;

  @override
  void initState() {
    super.initState();
    _resetValues();
  }

  @override
  void didUpdateWidget(covariant DailyLoadChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // เมื่อค่าไฟกลางวัน/กลางคืนถูกแก้จากช่องกรอกตัวเลขด้านนอก (ไม่ใช่จากการ
    // ลากกราฟ) ให้รีเซ็ตรูปกราฟใหม่ตามค่าล่าสุด ไม่งั้นกราฟจะค้างรูปเดิม
    if (oldWidget.dayKwh != widget.dayKwh ||
        oldWidget.nightKwh != widget.nightKwh) {
      _resetValues();
    }
  }

  void _resetValues() {
    values = List.generate(24,
        (h) => h >= 6 && h < 18 ? widget.dayKwh / 12 : widget.nightKwh / 12);
  }

  void _changeHour(double newValue) {
    final total = widget.totalKwh;
    if (total <= 0) return;
    final old = values[selectedHour];
    final remainderBefore = values.fold<double>(0, (a, b) => a + b) - old;
    final clamped = newValue.clamp(0, total * .7).toDouble();
    final remainderTarget = total - clamped;
    setState(() {
      values[selectedHour] = clamped;
      for (var i = 0; i < values.length; i++) {
        if (i == selectedHour) continue;
        values[i] = remainderBefore <= 0
            ? remainderTarget / 23
            : values[i] / remainderBefore * remainderTarget;
      }
    });
    final day = List.generate(12, (i) => values[i + 6])
        .fold<double>(0, (a, b) => a + b);
    widget.onChanged(day, total - day);
  }

  int _hourFromDx(double dx, double width) =>
      (dx / width * 24).floor().clamp(0, 23);

  double _valueFromDy(double dy, double height) {
    const topPadding = 8.0;
    const bottomPadding = 8.0;
    final chartHeight = height - topPadding - bottomPadding;
    final maxRange = math.max(.1, widget.totalKwh * .7);
    final clampedY = dy.clamp(topPadding, topPadding + chartHeight);
    final fraction = 1 - (clampedY - topPadding) / chartHeight;
    return (fraction * maxRange).clamp(0, maxRange).toDouble();
  }

  // แตะ/ลากตรงไหนบนกราฟ ก็ปรับค่าไฟของชั่วโมงนั้นได้ทันที (แทนแถบเลื่อนเดิม
  // ที่แยกอยู่ด้านล่าง) ค่าที่ได้จะถูกรวมเป็นไฟกลางวัน/กลางคืนแล้วส่งออกผ่าน
  // widget.onChanged ทุกครั้ง
  void _handleTouch(Offset local, Size box) {
    setState(() {
      selectedHour = _hourFromDx(local.dx, box.width);
    });
    _changeHour(_valueFromDy(local.dy, box.height));
  }

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('กราฟการใช้ไฟ 24 ชั่วโมง',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('แตะและลากบนกราฟเพื่อปรับค่าไฟกลางวัน/กลางคืนโดยตรง',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Row(children: [
              const _ChartLegend(
                  color: Color(0xFF81D4FA), label: 'ช่วงเช้า 06:01–17:59 น.'),
              const SizedBox(width: 16),
              const _ChartLegend(
                  color: Color(0xFF0288D1), label: 'ช่วงเย็น 18:01–05:59 น.'),
              const SizedBox(width: 16),
              _ChartLegend(
                  color: const Color(0xFFFFA726),
                  label:
                      'Peak Sun Hour ${widget.peakSunHours.toStringAsFixed(1)} ชม.'),
            ]),
            const SizedBox(height: 8),
            SizedBox(
              height: 125,
              width: double.infinity,
              child: LayoutBuilder(builder: (context, box) {
                final size = Size(box.maxWidth, box.maxHeight);
                return GestureDetector(
                  onTapDown: (d) => _handleTouch(d.localPosition, size),
                  onPanStart: (d) => _handleTouch(d.localPosition, size),
                  onPanUpdate: (d) => _handleTouch(d.localPosition, size),
                  child: CustomPaint(
                      painter: _LoadChartPainter(
                          values, selectedHour, widget.peakSunHours)),
                );
              }),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('00:00'),
                  Text('06:00'),
                  Text('12:00'),
                  Text('18:00'),
                  Text('24:00')
                ]),
            const SizedBox(height: 5),
            Text(
                'เวลา ${selectedHour.toString().padLeft(2, '0')}:00  ${values[selectedHour].toStringAsFixed(2)} kWh',
                style: const TextStyle(
                    color: Color(0xFF29B6F6), fontWeight: FontWeight.w700)),
          ]),
        ),
      );
}

class _LoadChartPainter extends CustomPainter {
  final List<double> values;
  final int selected;
  final double peakSunHours;
  _LoadChartPainter(this.values, this.selected, this.peakSunHours);
  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = math.max(.1, values.reduce(math.max));
    const topPadding = 8.0;
    const bottomPadding = 8.0;
    final chartHeight = size.height - topPadding - bottomPadding;
    final points = List.generate(24, (i) {
      final x = i / 23 * size.width;
      final y = topPadding + chartHeight * (1 - values[i] / maxValue);
      return Offset(x, y);
    });

    // กราฟโดม Peak Sun Hour: กึ่งกลางเวลา 12:00 แล้วขยายออกสองข้างเท่า ๆ กัน
    // ตามจำนวนชั่วโมงแดด วาดเป็นพื้นหลังไว้ใต้กราฟการใช้ไฟ
    _drawSunDome(canvas, size);

    final gridPaint = Paint()
      ..color = const Color(0xFFD8EEF8)
      ..strokeWidth = 1;
    for (var row = 0; row < 4; row++) {
      final y = topPadding + chartHeight * row / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    _drawSection(canvas, points.sublist(0, 7), const Color(0xFF0288D1),
        topPadding + chartHeight);
    _drawSection(canvas, points.sublist(6, 19), const Color(0xFF81D4FA),
        topPadding + chartHeight);
    _drawSection(canvas, points.sublist(18), const Color(0xFF0288D1),
        topPadding + chartHeight);

    final selectedPoint = points[selected];
    canvas.drawLine(
      Offset(selectedPoint.dx, topPadding),
      Offset(selectedPoint.dx, topPadding + chartHeight),
      Paint()
        ..color = const Color(0xFF0277BD).withValues(alpha: .28)
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(selectedPoint, 6, Paint()..color = Colors.white);
    canvas.drawCircle(
      selectedPoint,
      4.2,
      Paint()
        ..color = selected >= 6 && selected < 18
            ? const Color(0xFF81D4FA)
            : const Color(0xFF0288D1),
    );
  }

  void _drawSunDome(Canvas canvas, Size size) {
    final double half = peakSunHours.clamp(0.0, 24.0).toDouble() / 2;
    final double startHour = (12 - half).clamp(0.0, 24.0).toDouble();
    final double endHour = (12 + half).clamp(0.0, 24.0).toDouble();
    if (endHour <= startHour) return;

    final double startX = startHour / 24 * size.width;
    final double endX = endHour / 24 * size.width;
    final double peakX = size.width / 2;

    // ใช้ padding/เส้นฐานเดียวกับกราฟการใช้ไฟด้านล่าง เพื่อให้ยอดโดมสูงเท่ากับ
    // ระดับที่ "ค่าสูงสุดในแต่ละวัน" ของกราฟใช้ไฟไปถึงพอดี (topPadding)
    const double topPadding = 8.0;
    const double bottomPadding = 8.0;
    final double chartHeight = size.height - topPadding - bottomPadding;
    final double baseY = topPadding + chartHeight;
    final double apexY = topPadding;
    // วาดเป็นครึ่งวงรีจริง (ไม่ใช่เบซิเยร์ควอดราติก) เพราะเบซิเยร์ควอดราติก
    // จะโค้งไปพีคแค่ครึ่งทางระหว่างเส้นฐานกับจุดควบคุมเท่านั้น ทำให้ยอดโดม
    // เตี้ยกว่าที่ตั้งใจไว้จริง — ครึ่งวงรีให้ยอดสูงตรงตาม apexY เป๊ะ
    final radiusY = baseY - apexY;
    final ellipseRect =
        Rect.fromLTRB(startX, apexY, endX, baseY + radiusY);

    final fill = Path()
      ..addArc(ellipseRect, math.pi, math.pi)
      ..lineTo(startX, baseY)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            const Color(0xFFFFB74D).withValues(alpha: .03),
            const Color(0xFFFFB74D).withValues(alpha: .24),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    final outline = Path()..addArc(ellipseRect, math.pi, math.pi);
    canvas.drawPath(
      outline,
      Paint()
        ..color = const Color(0xFFFFA726).withValues(alpha: .85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // ตำแหน่งพระอาทิตย์ที่ยอดโดมจริง (เที่ยงวัน 12:00) สูงเท่ากับค่าสูงสุด
    canvas.drawCircle(
      Offset(peakX, apexY),
      5,
      Paint()..color = const Color(0xFFFFA726),
    );
    canvas.drawCircle(
      Offset(peakX, apexY),
      8,
      Paint()..color = const Color(0xFFFFA726).withValues(alpha: .22),
    );
  }

  void _drawSection(
      Canvas canvas, List<Offset> points, Color color, double baseY) {
    final fill = Path()..moveTo(points.first.dx, baseY);
    for (final point in points) {
      fill.lineTo(point.dx, point.dy);
    }
    fill
      ..lineTo(points.last.dx, baseY)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..color = color.withValues(alpha: .13)
        ..style = PaintingStyle.fill,
    );

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      line.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _LoadChartPainter old) => true;
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _ChartLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Row(children: [
          Container(
            width: 18,
            height: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ]),
      );
}
