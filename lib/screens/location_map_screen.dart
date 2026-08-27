import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/solar_project.dart';
import '../services/local_project_repository.dart';
import '../theme/pvforge_theme.dart';
import '../widgets/pvforge_components.dart';

/// หน้า "สถานที่ติดตั้ง" — กรอกที่อยู่ + ปักหมุดตำแหน่งจริงบนแผนที่
/// ใช้ flutter_map + OpenStreetMap (ไม่ต้องมี API key เหมือน Google Maps)
class LocationMapScreen extends StatefulWidget {
  final SolarProject project;
  const LocationMapScreen({super.key, required this.project});

  @override
  State<LocationMapScreen> createState() => _LocationMapScreenState();
}

class _LocationMapScreenState extends State<LocationMapScreen> {
  late final TextEditingController addressCtrl;
  final mapController = MapController();
  LatLng? picked;

  // กึ่งกลางกรุงเทพฯ ใช้เป็นจุดเริ่มต้นเวลายังไม่เคยปักหมุด
  static const _defaultCenter = LatLng(13.7563, 100.5018);

  @override
  void initState() {
    super.initState();
    addressCtrl =
        TextEditingController(text: widget.project.installationAddress);
    final lat = widget.project.installationLatitude;
    final lng = widget.project.installationLongitude;
    if (lat != null && lng != null) picked = LatLng(lat, lng);
  }

  @override
  void dispose() {
    addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    widget.project.installationAddress = addressCtrl.text.trim();
    if (picked != null) {
      widget.project.installationLatitude = picked!.latitude;
      widget.project.installationLongitude = picked!.longitude;
    }
    await LocalProjectRepository().save(widget.project);
    if (!mounted) return;
    showAppBanner(context, 'บันทึกสถานที่ติดตั้งเรียบร้อย');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('สถานที่ติดตั้ง')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
          children: [
            TextField(
              controller: addressCtrl,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'ที่อยู่ติดตั้ง',
                prefixIcon: Icon(Icons.location_on_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            const Text('แตะบนแผนที่เพื่อปักหมุดตำแหน่งติดตั้งจริง',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 340,
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: picked ?? _defaultCenter,
                    initialZoom: picked != null ? 17 : 6,
                    onTap: (tapPosition, point) =>
                        setState(() => picked = point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'com.cortek.cortek_solar_designer',
                    ),
                    if (picked != null)
                      MarkerLayer(markers: [
                        Marker(
                          point: picked!,
                          width: 44,
                          height: 44,
                          child: const Icon(Icons.location_on,
                              color: PVForgeColors.critical, size: 44),
                        ),
                      ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              picked != null
                  ? 'พิกัด: ${picked!.latitude.toStringAsFixed(6)}, '
                      '${picked!.longitude.toStringAsFixed(6)}'
                  : 'ยังไม่ได้ปักหมุด — แตะบนแผนที่ด้านบนเพื่อปักหมุด',
              style: const TextStyle(
                  fontSize: 12, color: PVForgeColors.secondaryText),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('บันทึกสถานที่ติดตั้ง'),
              ),
            ),
          ],
        ),
      );
}
