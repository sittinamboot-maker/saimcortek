import 'package:flutter/material.dart';

/// สถานะตอนยังไม่มีโปรเจกต์ที่บันทึกไว้ — ใช้เป็น body ของ ProjectsScreen
/// (เดิมเป็น Scaffold เปล่า ๆ ไม่มีเนื้อหาอะไรเลย ไม่เคยถูกเรียกใช้จริง)
class EmptyProjectsView extends StatelessWidget {
  final VoidCallback onCreate;
  const EmptyProjectsView({super.key, required this.onCreate});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFD8EBFF), Color(0xFF8BC2FF)],
                  ),
                ),
                child: const Icon(Icons.folder_off_outlined,
                    color: Colors.white, size: 44),
              ),
              const SizedBox(height: 20),
              const Text('ยังไม่มีโปรเจกต์',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                'เริ่มสร้างโปรเจกต์แรกของคุณ เพื่อคำนวณขนาดระบบโซลาร์เซลล์และดูรายงานได้ทันที',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  child: Text('สร้างโปรเจกต์ใหม่'),
                ),
              ),
            ],
          ),
        ),
      );
}
