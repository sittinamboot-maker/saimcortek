import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/solar_project.dart';

/// สร้างรายงาน PDF สรุประบบ / BOQ จากข้อมูลโปรเจกต์จริงทั้งหมด (ไม่มีข้อมูล
/// ตัวอย่าง/สมมติ) — ใช้ฟอนต์ NotoSansThai ที่มีอยู่แล้วในแอป เพื่อให้
/// ข้อความภาษาไทยแสดงผลถูกต้องใน PDF (ฟอนต์ default ของ PDF ไม่รองรับไทย)
class PdfReportService {
  static Future<Uint8List> buildBoqReport(SolarProject p) async {
    final fontData =
        await rootBundle.load('assets/fonts/NotoSansThai-Variable.ttf');
    final thaiFont = pw.Font.ttf(fontData);
    final theme = pw.ThemeData.withFont(base: thaiFont, bold: thaiFont);
    final generatedAt = DateTime.now();

    // โหลดไฟล์รูปภาพหน้างานทั้งหมดล่วงหน้า (อ่านไฟล์เป็น async ต้อง await
    // ก่อนเข้าสู่ build widget tree แบบ sync ด้านล่าง) ข้ามรูปที่ไฟล์หาย/
    // อ่านไม่ได้เงียบ ๆ ไม่ให้ทั้งรายงานพังเพราะรูปเดียว
    final sitePhotoImages = <pw.MemoryImage>[];
    for (final path in p.sitePhotoPaths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          sitePhotoImages.add(pw.MemoryImage(await file.readAsBytes()));
        }
      } catch (_) {}
    }

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('สรุประบบ / Bill of Quantity (BOQ)',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 2),
            pw.Text('CORTek Solar Designer',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
            pw.SizedBox(height: 6),
            pw.Divider(color: PdfColors.grey400),
          ],
        ),
        footer: (context) => pw.Column(
          children: [
            pw.Divider(color: PdfColors.grey400),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'สร้างเมื่อ ${generatedAt.day.toString().padLeft(2, '0')}/'
                  '${generatedAt.month.toString().padLeft(2, '0')}/'
                  '${generatedAt.year} '
                  '${generatedAt.hour.toString().padLeft(2, '0')}:'
                  '${generatedAt.minute.toString().padLeft(2, '0')}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
                pw.Text('หน้า ${context.pageNumber}/${context.pagesCount}',
                    style:
                        const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
              ],
            ),
          ],
        ),
        build: (context) => [
          if (p.customerName.isNotEmpty || p.projectName.isNotEmpty) ...[
            _sectionTitle('ข้อมูลลูกค้า'),
            _infoTable([
              if (p.projectName.isNotEmpty) ('โครงการ', p.projectName),
              if (p.customerName.isNotEmpty) ('ลูกค้า', p.customerName),
              if (p.customerPhone.isNotEmpty) ('เบอร์โทร', p.customerPhone),
              if (p.installationAddress.isNotEmpty)
                ('ที่อยู่ติดตั้ง', p.installationAddress),
              if (p.installationLatitude != null &&
                  p.installationLongitude != null)
                (
                  'พิกัด GPS',
                  '${p.installationLatitude!.toStringAsFixed(6)}, '
                      '${p.installationLongitude!.toStringAsFixed(6)}',
                ),
              if (p.roofType.isNotEmpty) ('รูปแบบหลังคา', p.roofType),
              ('ระบบไฟฟ้า', p.electricalPhase),
              if (p.customerNote.isNotEmpty) ('หมายเหตุ', p.customerNote),
            ]),
            pw.SizedBox(height: 14),
          ],
          _sectionTitle('ภาพรวมระบบ'),
          _infoTable([
            ('ประเภทระบบ', p.isAirSolarSystem ? 'แอร์โซล่าเซลล์' : p.systemType),
            ('ขนาดระบบ', '${p.systemKwp.toStringAsFixed(2)} kWp'),
            ('จำนวนแผง', '${p.recommendedPanels} แผง'),
            ('พื้นที่ที่ใช้โดยประมาณ',
                '${p.estimatedRoofArea.toStringAsFixed(1)} m² (หลังคามี ${p.roofArea.toStringAsFixed(1)} m²)'),
            ('ผลผลิตไฟประมาณ',
                '${p.estimatedDailyProduction.toStringAsFixed(1)} kWh/วัน '
                    '(${p.estimatedMonthlyProduction.toStringAsFixed(0)} kWh/เดือน)'),
            ('ประสิทธิภาพระบบรวม',
                '${(p.systemEfficiency * 100).toStringAsFixed(1)}% '
                    '(Loss รวม ${p.totalSystemLoss.toStringAsFixed(1)}%)'),
          ]),
          pw.SizedBox(height: 14),
          _sectionTitle('รายการอุปกรณ์หลัก (BOQ)'),
          _boqTable(_boqRows(p)),
          if (p.hasBattery) ...[
            pw.SizedBox(height: 14),
            _sectionTitle('ระบบแบตเตอรี่'),
            _infoTable([
              ('แบตเตอรี่ที่มี', '${p.batteryCapacityKwh.toStringAsFixed(1)} kWh'),
              ('ฐานคำนวณ',
                  '${p.sizeBatteryFromNightUsage ? 'ไฟกลางคืน' : 'ชั่วโมงสำรอง'} '
                      '${p.batteryEnergyTarget.toStringAsFixed(1)} kWh'),
              ('ความจุแนะนำ',
                  '${p.recommendedBatteryCapacity.toStringAsFixed(1)} kWh'),
              ('สำรองไฟได้ประมาณ',
                  '${p.estimatedBatteryBackupHours.toStringAsFixed(1)} ชั่วโมง'),
              ('ครอบคลุมไฟกลางคืน',
                  '${p.estimatedNightCoveragePercent.toStringAsFixed(0)}%'),
            ]),
          ],
          if (p.customEquipment.isNotEmpty) ...[
            pw.SizedBox(height: 14),
            _sectionTitle('อุปกรณ์เพิ่มเติมของลูกค้า'),
            _infoTable(p.customEquipment
                .map((e) => (
                      e.name,
                      '${e.quantity.toStringAsFixed(e.quantity % 1 == 0 ? 0 : 1)} '
                          '${e.unit}${e.note.isEmpty ? '' : ' • ${e.note}'}',
                    ))
                .toList()),
          ],
          if (sitePhotoImages.isNotEmpty) ...[
            pw.SizedBox(height: 14),
            _sectionTitle('รูปภาพหน้างาน (${sitePhotoImages.length} รูป)'),
            pw.Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sitePhotoImages
                  .map((img) => pw.Container(
                        width: 110,
                        height: 110,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                        ),
                        child: pw.Image(img, fit: pw.BoxFit.cover),
                      ))
                  .toList(),
            ),
          ],
          pw.SizedBox(height: 18),
          pw.Text(
            'ค่าจริงขึ้นอยู่กับตำแหน่งติดตั้ง มุมเอียง เงาบัง อุณหภูมิ และการสูญเสียของระบบหน้างานจริง',
            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _sectionTitle(String title) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Text(title,
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
      );

  static pw.Widget _infoTable(List<(String, String)> rows) => pw.Table(
        columnWidths: const {
          0: pw.FlexColumnWidth(1.3),
          1: pw.FlexColumnWidth(2),
        },
        children: rows
            .map((row) => pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 3),
                    child: pw.Text(row.$1,
                        style: const pw.TextStyle(
                            color: PdfColors.grey700, fontSize: 10)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 3),
                    child: pw.Text(row.$2, style: const pw.TextStyle(fontSize: 10)),
                  ),
                ]))
            .toList(),
      );

  static List<(String, String)> _boqRows(SolarProject p) {
    final rows = <(String, String)>[
      (
        'แผงโซลาร์เซลล์',
        '${p.panelModel}\n${p.panelWatt.toStringAsFixed(0)} W × ${p.recommendedPanels} แผง',
      ),
      (
        'Inverter / Boost-MPPT',
        '${p.inverterModel}\n${p.inverterKw.toStringAsFixed(1)} kW • ${p.systemType}',
      ),
    ];
    if (p.isAirSolarSystem) {
      for (var i = 0; i < p.airConditioners.length; i++) {
        final ac = p.airConditioners[i];
        rows.add((
          'เครื่องปรับอากาศ ${i + 1}',
          '${ac.brand} ${ac.model}\n${ac.btu} BTU/h × ${ac.quantity} เครื่อง • '
              '${ac.dailyKwh.toStringAsFixed(1)} kWh/วัน',
        ));
      }
      if (p.airConditioners.isNotEmpty) {
        rows.add((
          'พลังงานแอร์รวม',
          '${p.airConditionerDailyKwh.toStringAsFixed(1)} kWh/วัน',
        ));
      }
    }
    if (p.hasBattery) {
      rows.add((
        'Battery',
        '${p.batteryCapacityKwh.toStringAsFixed(1)} kWh • '
            'สำรองประมาณ ${p.estimatedBatteryBackupHours.toStringAsFixed(1)} ชม. '
            '(แนะนำ ${p.recommendedBatteryCapacity.toStringAsFixed(1)} kWh)',
      ));
    }
    rows.addAll([
      ('DC Cable', 'คำนวณตามกระแสและระยะสายหน้างาน'),
      ('DC Breaker / Isolator', 'ตรวจตามแรงดันและกระแสระบบ'),
      ('SPD', 'เลือกตาม DC/AC system voltage'),
      ('Grounding', 'ตรวจตามมาตรฐานติดตั้งที่ใช้'),
    ]);
    return rows;
  }

  static pw.Widget _boqTable(List<(String, String)> rows) => pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey300, width: .5),
        columnWidths: const {
          0: pw.FlexColumnWidth(1.1),
          1: pw.FlexColumnWidth(2),
        },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.blue50),
            children: [
              _cell('รายการ', bold: true),
              _cell('รายละเอียด', bold: true),
            ],
          ),
          ...rows.map((row) => pw.TableRow(children: [
                _cell(row.$1),
                _cell(row.$2),
              ])),
        ],
      );

  static pw.Widget _cell(String text, {bool bold = false}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: pw.Text(text,
            style: pw.TextStyle(
                fontSize: 9.5,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      );
}
