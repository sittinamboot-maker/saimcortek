import 'package:flutter/material.dart';

import '../models/solar_project.dart';
import '../theme/pvforge_theme.dart';
import '../widgets/pvforge_components.dart';
import 'project_screen.dart';

class DemoScreen extends StatelessWidget {
  const DemoScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('PVForge DEMO')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(children: [
                  Text('DEMO',
                      style: TextStyle(
                          color: Color(0xFF0277BD),
                          fontSize: 28,
                          fontWeight: FontWeight.w900)),
                  SizedBox(height: 8),
                  Text('ทดลองออกแบบระบบโซลาร์เซลล์ครบทุกขั้นตอน',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  SizedBox(height: 6),
                  Text('ข้อมูลในโหมดนี้ใช้เพื่อสาธิตและบันทึกไว้ในเครื่อง',
                      textAlign: TextAlign.center),
                ]),
              ),
            ),
            const SizedBox(height: 14),
            for (final item in const [
              ('01', 'กรอกข้อมูลลูกค้าและพื้นที่หลังคา'),
              ('02', 'คำนวณขนาดแผงและแบตเตอรี่'),
              ('03', 'เลือกแผงและอินเวอร์เตอร์'),
              ('04', 'ตรวจสอบ String / MPPT และสรุป BOQ'),
            ])
              Card(
                child: ListTile(
                  leading: GradientIconBadge(
                      text: item.$1, color: PVForgeColors.primary),
                  title: Text(item.$2),
                ),
              ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProjectScreen(project: SolarProject())),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('เริ่มทดลองออกแบบระบบ'),
              ),
            ),
          ],
        ),
      );
}
