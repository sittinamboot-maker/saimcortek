import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/solar_project.dart';
import '../services/local_project_repository.dart';
import '../theme/pvforge_theme.dart';
import '../widgets/pvforge_components.dart';

/// หน้า "รูปภาพหน้างาน" — ถ่ายภาพด้วยกล้อง หรือเลือกจากคลังภาพ แล้วเก็บไฟล์
/// ไว้ในเครื่อง ผูกกับโปรเจกต์นี้ ดูภาพทั้งหมดและลบทิ้งได้
///
/// หมายเหตุ: ฟังก์ชันกล้อง/คลังภาพ (image_picker) รองรับเฉพาะ Android/iOS
/// เท่านั้น บน Windows (ตอนทดสอบด้วย `flutter run -d windows`) จะไม่มีกล้อง
/// ให้ใช้งาน ปุ่มจะแจ้งเตือนแทนการ crash
class SitePhotosScreen extends StatefulWidget {
  final SolarProject project;
  const SitePhotosScreen({super.key, required this.project});

  @override
  State<SitePhotosScreen> createState() => _SitePhotosScreenState();
}

class _SitePhotosScreenState extends State<SitePhotosScreen> {
  bool busy = false;

  bool get _cameraSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> _addPhoto(ImageSource source) async {
    if (!_cameraSupported) {
      showAppBanner(
          context, 'ฟังก์ชันนี้ใช้ได้เฉพาะบนมือถือ (Android/iOS) เท่านั้น',
          error: true);
      return;
    }
    setState(() => busy = true);
    try {
      final picked =
          await ImagePicker().pickImage(source: source, imageQuality: 85);
      if (picked == null) return;
      final docsDir = await getApplicationDocumentsDirectory();
      final photosDir =
          Directory('${docsDir.path}/site_photos_${widget.project.id}');
      if (!await photosDir.exists()) await photosDir.create(recursive: true);
      final fileName =
          'photo_${DateTime.now().microsecondsSinceEpoch}.jpg';
      final savedPath = '${photosDir.path}/$fileName';
      await File(picked.path).copy(savedPath);
      setState(() => widget.project.sitePhotoPaths.add(savedPath));
      await LocalProjectRepository().save(widget.project);
      if (!mounted) return;
      showAppBanner(context, 'เพิ่มรูปภาพหน้างานเรียบร้อย');
    } catch (e) {
      if (mounted) showAppBanner(context, 'เกิดข้อผิดพลาด: $e', error: true);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _removePhoto(String path) async {
    setState(() => widget.project.sitePhotoPaths.remove(path));
    await LocalProjectRepository().save(widget.project);
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
    if (!mounted) return;
    showAppBanner(context, 'ลบรูปภาพแล้ว');
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.project.sitePhotoPaths;
    return Scaffold(
      appBar: AppBar(title: const Text('รูปภาพหน้างาน')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
        children: [
          Row(children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: busy ? null : () => _addPhoto(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('ถ่ายภาพ'),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    busy ? null : () => _addPhoto(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('เลือกจากคลังภาพ'),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          if (photos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(children: [
                  Icon(Icons.image_outlined,
                      size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text('ยังไม่มีรูปภาพหน้างาน',
                      style: TextStyle(color: Colors.grey.shade600)),
                ]),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: photos.length,
              itemBuilder: (_, i) {
                final path = photos[i];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(fit: StackFit.expand, children: [
                    Image.file(File(path),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.broken_image_outlined),
                            )),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: InkWell(
                        onTap: () => _removePhoto(path),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ]),
                );
              },
            ),
        ],
      ),
    );
  }
}
