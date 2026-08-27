import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../models/solar_project.dart';
import '../services/pdf_report_service.dart';
import '../theme/pvforge_theme.dart';
import '../widgets/pvforge_components.dart';

class SummaryScreen extends StatelessWidget {
  final SolarProject project;
  const SummaryScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final p = project;
    return Scaffold(
      appBar: AppBar(title: const Text('สรุประบบ')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
        children: [
          if (p.customerName.isNotEmpty || p.projectName.isNotEmpty) ...[
            const Text('ข้อมูลลูกค้า',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (p.projectName.isNotEmpty)
                      _customerLine(Icons.home_work_outlined, p.projectName),
                    if (p.customerName.isNotEmpty)
                      _customerLine(Icons.person_outline, p.customerName),
                    if (p.customerPhone.isNotEmpty)
                      _customerLine(Icons.phone_outlined, p.customerPhone),
                    if (p.installationAddress.isNotEmpty)
                      _customerLine(
                          Icons.location_on_outlined, p.installationAddress),
                    if (p.customerNote.isNotEmpty)
                      _customerLine(Icons.notes_outlined, p.customerNote),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat(Icons.bolt, PVForgeColors.primary,
                      p.systemKwp.toStringAsFixed(2), 'kWp'),
                  _stat(Icons.grid_view_rounded, PVForgeColors.battery,
                      '${p.recommendedPanels}', 'แผง'),
                  _stat(Icons.insights, PVForgeColors.warning,
                      p.estimatedDailyProduction.toStringAsFixed(1),
                      'kWh/วัน'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('รายการอุปกรณ์หลัก',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _item('แผงโซลาร์เซลล์',
              '${p.panelModel}\n${p.panelWatt.toStringAsFixed(0)} W × ${p.recommendedPanels} แผง'),
          _item('Inverter',
              '${p.inverterModel}\n${p.inverterKw.toStringAsFixed(1)} kW • ${p.systemType}'),
          if (p.isAirSolarSystem) ...[
            for (var index = 0; index < p.airConditioners.length; index++)
              _item(
                'เครื่องปรับอากาศ ${index + 1}',
                '${p.airConditioners[index].brand} ${p.airConditioners[index].model}\n'
                    '${p.airConditioners[index].btu} BTU/h × ${p.airConditioners[index].quantity} เครื่อง • '
                    '${p.airConditioners[index].dailyKwh.toStringAsFixed(1)} kWh/วัน',
              ),
            _item('พลังงานแอร์รวม',
                '${p.airConditionerDailyKwh.toStringAsFixed(1)} kWh/วัน'),
          ],
          if (p.hasBattery)
            _item(
              'Battery',
              '${p.batteryCapacityKwh.toStringAsFixed(1)} kWh • '
                  'สำรองประมาณ ${p.estimatedBatteryBackupHours.toStringAsFixed(1)} ชม. '
                  '(แนะนำ ${p.recommendedBatteryCapacity.toStringAsFixed(1)} kWh)',
            ),
          _item('DC Cable', 'คำนวณตามกระแสและระยะสายหน้างาน'),
          _item('DC Breaker / Isolator', 'ตรวจตามแรงดันและกระแสระบบ'),
          _item('SPD', 'เลือกตาม DC/AC system voltage'),
          _item('Grounding', 'ตรวจตามมาตรฐานติดตั้งที่ใช้'),
          _item('System Efficiency',
              '${(p.systemEfficiency * 100).toStringAsFixed(1)}%'),
          _item(
              'Total System Loss', '${p.totalSystemLoss.toStringAsFixed(1)}%'),
          _item(
            'การใช้ไฟกลางวัน / กลางคืน',
            '${p.dayKwhPerDay.toStringAsFixed(1)} / '
                '${p.nightKwhPerDay.toStringAsFixed(1)} kWh ต่อวัน',
          ),
          if (p.hasBattery)
            _item(
              'เป้าหมายผลิตไฟต่อวัน',
              '${p.solarDailyEnergyTarget.toStringAsFixed(1)} kWh '
                  '(โหลดกลางวัน + ชาร์จแบตเต็ม)',
            ),
          if (p.customEquipment.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'อุปกรณ์เพิ่มเติมของลูกค้า',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (final equipment in p.customEquipment)
              _item(
                equipment.name,
                '${equipment.quantity.toStringAsFixed(equipment.quantity % 1 == 0 ? 0 : 1)} '
                '${equipment.unit}${equipment.note.isEmpty ? '' : ' • ${equipment.note}'}',
              ),
          ],
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ประมาณการผลิตไฟ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                      '${p.estimatedMonthlyProduction.toStringAsFixed(0)} kWh / เดือน',
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  const Text(
                      'ค่าจริงขึ้นอยู่กับตำแหน่งติดตั้ง มุมเอียง เงาบัง อุณหภูมิ และการสูญเสียของระบบ'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _generatePdf(context),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('สร้างรายงาน PDF'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePdf(BuildContext context) async {
    try {
      await Printing.layoutPdf(
        onLayout: (format) => PdfReportService.buildBoqReport(project),
        name:
            'BOQ_${(project.projectName.isEmpty ? project.customerName : project.projectName).trim().isEmpty ? 'project' : (project.projectName.isEmpty ? project.customerName : project.projectName)}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        showAppBanner(context, 'สร้างรายงาน PDF ไม่สำเร็จ: $e', error: true);
      }
    }
  }

  Widget _customerLine(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF29B6F6)),
            const SizedBox(width: 9),
            Expanded(child: Text(text)),
          ],
        ),
      );

  Widget _stat(IconData icon, Color color, String value, String label) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GradientIconBadge(icon: icon, color: color, size: 34),
          const SizedBox(height: 8),
          Text(value,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: PVForgeColors.secondaryText)),
        ],
      );

  Widget _item(String title, String value) => Card(
        child: ListTile(
          leading: const GradientIconBadge(
              icon: Icons.check_circle_outline, color: PVForgeColors.battery),
          title: Text(title),
          subtitle: Text(value),
        ),
      );
}
