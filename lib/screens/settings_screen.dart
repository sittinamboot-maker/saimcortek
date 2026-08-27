import 'package:flutter/material.dart';

import '../models/solar_project.dart';
import '../services/local_project_repository.dart';
import '../theme/pvforge_theme.dart';
import '../widgets/pvforge_components.dart';
import 'demo_screen.dart';
import 'efficiency_loss_screen.dart';
import 'workspace_screen.dart';

/// หน้า "ตั้งค่า" — เดิมเป็น modal bottom sheet ลอยขึ้นมา เปลี่ยนเป็นหน้าเต็ม
/// จอเหมือนเมนูอื่น ๆ (หน้าหลัก/โปรเจกต์/อุปกรณ์) ตามที่ขอ
class SettingsScreen extends StatelessWidget {
  final AppVisualMode currentMode;
  final ValueChanged<AppVisualMode> onModeChanged;
  const SettingsScreen({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  Widget _themeChoice(
          BuildContext context, AppVisualMode value, String label) =>
      ListTile(
        leading: Icon(currentMode == value
            ? Icons.radio_button_checked
            : Icons.radio_button_off),
        title: Text(label),
        onTap: () => onModeChanged(value),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('ตั้งค่า')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
          children: [
            ListTile(
              leading: const GradientIconBadge(
                  icon: Icons.business_outlined, color: PVForgeColors.primary),
              title: const Text('Company Workspace'),
              subtitle: const Text('บริษัท แพ็กเกจ และสมาชิก'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const WorkspaceScreen())),
            ),
            const Divider(),
            ListTile(
              leading: const GradientIconBadge(
                  text: 'D', color: PVForgeColors.warning),
              title: const Text('DEMO'),
              subtitle: const Text('ทดลองออกแบบระบบด้วยข้อมูลตัวอย่าง'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const DemoScreen())),
            ),
            const Divider(),
            ListTile(
              leading: const GradientIconBadge(
                  icon: Icons.speed_outlined, color: PVForgeColors.battery),
              title: const Text('ประสิทธิภาพแผง & Inverter'),
              subtitle:
                  const Text('ปรับค่าประสิทธิภาพแผง, Inverter และการสูญเสียระบบ'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final projects = await LocalProjectRepository().loadAll();
                final project =
                    projects.isNotEmpty ? projects.first : SolarProject();
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EfficiencyLossScreen(project: project)),
                );
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text('เลือกโทนสีแอป',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            _themeChoice(context, AppVisualMode.warm, 'ธีมมาตรฐาน PVForge'),
            _themeChoice(context, AppVisualMode.monochrome, 'ขาวดำ'),
          ],
        ),
      );
}
