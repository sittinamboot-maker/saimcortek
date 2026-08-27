import 'package:flutter/material.dart';

import '../theme/pvforge_theme.dart';

/// วงกลมไอคอนไล่สีมาตรฐานของแอป ใช้แทน CircleAvatar/ไอคอนสีเทาแบบเดิม
/// เพื่อให้ทุกหน้าดูเป็นดีไซน์ภาษาเดียวกัน — ใส่ได้ทั้งไอคอนหรือข้อความสั้น ๆ
/// (เช่น ตัวอักษรย่อ) อย่างใดอย่างหนึ่ง
class GradientIconBadge extends StatelessWidget {
  final IconData? icon;
  final String? text;
  final Color color;
  final double size;
  const GradientIconBadge({
    super.key,
    this.icon,
    this.text,
    required this.color,
    this.size = 40,
  }) : assert(icon != null || text != null,
            'ต้องใส่ icon หรือ text อย่างใดอย่างหนึ่ง');

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withValues(alpha: .82), color],
          ),
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: .32),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: icon != null
            ? Icon(icon, color: Colors.white, size: size * .5)
            : Text(text!,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: size * .4)),
      );
}

class PVForgeCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  const PVForgeCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(18),
      this.backgroundColor});
  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white.withValues(alpha: .42),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
                color: Color(0x260277BD),
                blurRadius: 22,
                spreadRadius: 1,
                offset: Offset(0, 8)),
          ],
        ),
        child: child,
      );
}

class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const StatusPill(
      {super.key, required this.label, this.color = PVForgeColors.battery});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(99)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ]),
      );
}

class MetricCard extends StatelessWidget {
  final String value, unit, label;
  final IconData icon;
  final Color color;
  final bool compact;
  final bool transparent;
  const MetricCard(
      {super.key,
      required this.value,
      required this.unit,
      required this.label,
      required this.icon,
      required this.color,
      this.compact = false,
      this.transparent = false});
  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 34 : 40,
          height: compact ? 34 : 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withValues(alpha: .82), color],
            ),
            boxShadow: [
              BoxShadow(
                  color: color.withValues(alpha: .32),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: compact ? 17 : 20),
        ),
        SizedBox(width: compact ? 8 : 10),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: compact ? 20 : 24,
                      fontWeight: FontWeight.w800,
                      height: 1)),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 3),
                Text(unit,
                    style: TextStyle(
                        fontSize: compact ? 10 : 11,
                        fontWeight: FontWeight.w600,
                        color: PVForgeColors.secondaryText)),
              ],
            ],
          ),
        ),
      ],
    );

    // จัดชิดซ้ายเสมอ (ไม่ใช้ Center) เพื่อให้ไอคอนของทุกการ์ดในกริดอยู่ตำแหน่ง
    // เดียวกัน/ระยะย่อหน้าเท่ากัน ไม่ขยับตามความยาวของตัวเลขแต่ละการ์ด
    const alignment = Alignment.centerLeft;

    // การ์ดแบบโปร่งใส (ใช้บนพื้นหลังไล่สี/รูปของหน้าแรก) ไม่ต้องมีกรอบขาว
    // หรือเงาใด ๆ เลย ให้กลืนไปกับพื้นหลัง
    if (transparent) {
      return Tooltip(
        message: label,
        child: Padding(
          padding: EdgeInsets.all(compact ? 6 : 9),
          child: Align(alignment: alignment, child: content),
        ),
      );
    }

    return Tooltip(
      message: label,
      child: PVForgeCard(
        padding: EdgeInsets.all(compact ? 10 : 14),
        child: Align(alignment: alignment, child: content),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeader(this.title, {super.key, this.trailing});
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    shadows: [
                      Shadow(
                          color: Color(0x1F0277BD),
                          blurRadius: 6,
                          offset: Offset(0, 2))
                    ]))),
        if (trailing != null) trailing!,
      ]);
}

/// แสดงข้อความแจ้งเตือนที่ด้านบนของจอ (MaterialBanner) แทน SnackBar (ด้านล่าง)
/// เพราะด้านล่างจอโดนแถบเมนูลอย (AppBottomNavigation) บังข้อความจนอ่านไม่ออก —
/// ใช้ตัวเดียวกันนี้ทุกหน้า (บันทึก/แก้ไข/ลบ) ให้พฤติกรรมเหมือนกันหมดทั้งแอป
/// พื้นหลังโปร่งแสง (ไม่ทึบ) ให้เข้าชุดกับดีไซน์กระจกฝ้าของแอป แทนสีทึบเดิม
void showAppBanner(BuildContext context, String message,
    {bool error = false}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearMaterialBanners();
  final color = error ? PVForgeColors.critical : const Color(0xFF2E7D32);
  messenger.showMaterialBanner(
    MaterialBanner(
      backgroundColor: color.withValues(alpha: .55),
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          shadows: [
            Shadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
      ),
      leading: Icon(error ? Icons.error_outline : Icons.check_circle,
          color: Colors.white),
      actions: [
        TextButton(
          onPressed: messenger.hideCurrentMaterialBanner,
          child: const Text('ปิด',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
  Future.delayed(const Duration(seconds: 2), () {
    messenger.hideCurrentMaterialBanner();
  });
}

class RealtimeIndicator extends StatefulWidget {
  const RealtimeIndicator({super.key});
  @override
  State<RealtimeIndicator> createState() => _RealtimeIndicatorState();
}

class _RealtimeIndicatorState extends State<RealtimeIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
      opacity: Tween(begin: .4, end: 1.0).animate(controller),
      child: const StatusPill(label: 'Real-time'));
}
