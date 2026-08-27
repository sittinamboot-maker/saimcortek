import 'package:flutter/material.dart';

import '../models/solar_project.dart';
import '../services/local_project_repository.dart';
import '../theme/pvforge_theme.dart';
import '../widgets/pvforge_components.dart';

class _RoofTypeOption {
  final String label;
  final IconData icon;
  const _RoofTypeOption(this.label, this.icon);
}

const _roofTypes = [
  _RoofTypeOption('จั่ว', Icons.change_history_outlined),
  _RoofTypeOption('ปั้นหยา', Icons.home_outlined),
  _RoofTypeOption('เพิงหมาแหงน', Icons.trending_up_outlined),
  _RoofTypeOption('แบน (ดาดฟ้า)', Icons.crop_landscape_outlined),
  _RoofTypeOption('มะนิลา', Icons.roofing_outlined),
  _RoofTypeOption('ทรงผสม', Icons.dashboard_customize_outlined),
];

/// หน้า "ข้อมูลหลังคา" — เลือกรูปแบบหลังคาที่ใช้ติดตั้งจริง
/// (ส่วนความกว้าง/ความยาว/พื้นที่หลังคา ยังแก้ไขที่แท็บ "ออกแบบระบบ" ในหน้า
/// สร้างโปรเจกต์เหมือนเดิม เพื่อไม่ให้มีจุดแก้ไขค่าเดียวกันซ้ำซ้อนสองที่)
class RoofInfoScreen extends StatefulWidget {
  final SolarProject project;
  const RoofInfoScreen({super.key, required this.project});

  @override
  State<RoofInfoScreen> createState() => _RoofInfoScreenState();
}

class _RoofInfoScreenState extends State<RoofInfoScreen> {
  Future<void> _select(String type) async {
    setState(() => widget.project.roofType = type);
    await LocalProjectRepository().save(widget.project);
    if (!mounted) return;
    showAppBanner(context, 'บันทึกรูปแบบหลังคา "$type" เรียบร้อย');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('ข้อมูลหลังคา')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
          children: [
            const Text('เลือกรูปแบบหลังคาที่ใช้ติดตั้งจริง',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.35,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _roofTypes.length,
              itemBuilder: (_, i) {
                final option = _roofTypes[i];
                final selected = widget.project.roofType == option.label;
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _select(option.label),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFFFF3E0)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? PVForgeColors.warning
                            : const Color(0xFFDDE3EC),
                        width: selected ? 1.6 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(option.icon,
                            size: 30,
                            color: selected
                                ? PVForgeColors.warning
                                : Colors.black54),
                        const SizedBox(height: 8),
                        Text(option.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: selected
                                    ? PVForgeColors.warning
                                    : Colors.black87)),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            PVForgeCard(
              child: Row(children: [
                const Icon(Icons.info_outline,
                    color: PVForgeColors.secondaryText),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'ส่วนความกว้าง/ความยาว/พื้นที่หลังคาสำหรับคำนวณจำนวนแผง '
                    'ยังแก้ไขได้ที่แท็บ "ออกแบบระบบ" ในหน้าสร้างโปรเจกต์เหมือนเดิม',
                    style: const TextStyle(
                        fontSize: 12, color: PVForgeColors.secondaryText),
                  ),
                ),
              ]),
            ),
          ],
        ),
      );
}
