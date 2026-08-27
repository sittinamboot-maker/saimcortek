import 'package:flutter/material.dart';

import '../models/solar_project.dart';
import '../services/local_project_repository.dart';
import '../theme/pvforge_theme.dart';
import '../widgets/pvforge_components.dart';

/// หน้า "ระบบไฟฟ้า" — บันทึกว่าระบบไฟฟ้าหน้างานเป็น 1 เฟส หรือ 3 เฟส
/// (ข้อมูลนี้ช่วยผู้ติดตั้งเลือกรุ่นอินเวอร์เตอร์/สายไฟให้ตรงกับระบบไฟจริง)
class ElectricalSystemScreen extends StatefulWidget {
  final SolarProject project;
  const ElectricalSystemScreen({super.key, required this.project});

  @override
  State<ElectricalSystemScreen> createState() =>
      _ElectricalSystemScreenState();
}

class _ElectricalSystemScreenState extends State<ElectricalSystemScreen> {
  Future<void> _select(String phase) async {
    setState(() => widget.project.electricalPhase = phase);
    await LocalProjectRepository().save(widget.project);
    if (!mounted) return;
    showAppBanner(context, 'บันทึกระบบไฟฟ้า "$phase" เรียบร้อย');
  }

  Widget _phaseCard(String phase, String voltage, String note) {
    final selected = widget.project.electricalPhase == phase;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _select(phase),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? PVForgeColors.battery : const Color(0xFFDDE3EC),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(children: [
          GradientIconBadge(
            icon: Icons.electrical_services_outlined,
            color: selected ? PVForgeColors.battery : const Color(0xFF90A4AE),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(phase,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('$voltage · $note',
                    style: const TextStyle(
                        fontSize: 12, color: PVForgeColors.secondaryText)),
              ],
            ),
          ),
          if (selected)
            const Icon(Icons.check_circle, color: PVForgeColors.battery),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('ระบบไฟฟ้า')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
          children: [
            const Text('เลือกระบบไฟฟ้าที่ใช้งานจริงหน้างาน',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            _phaseCard('1 เฟส', '220V', 'บ้านพักอาศัยทั่วไป'),
            _phaseCard('3 เฟส', '380V', 'โรงงาน/อาคารพาณิชย์ หรือโหลดสูง'),
          ],
        ),
      );
}
