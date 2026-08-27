import 'package:flutter/material.dart';
import '../models/solar_project.dart';
import '../services/local_project_repository.dart';
import '../theme/pvforge_theme.dart';
import '../widgets/daily_load_chart.dart';
import '../widgets/peak_sun_hour_chart.dart';
import '../widgets/pvforge_components.dart';
import 'result_screen.dart';
import 'summary_screen.dart';
import 'air_conditioner_selection_screen.dart';
import 'location_map_screen.dart';
import 'roof_info_screen.dart';
import 'electrical_system_screen.dart';
import 'site_photos_screen.dart';

class ProjectScreen extends StatefulWidget {
  final SolarProject project;
  final bool openResult;
  final bool openSummary;

  const ProjectScreen({
    super.key,
    required this.project,
    this.openResult = false,
    this.openSummary = false,
  });

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  bool showDetails = false;
  late final TextEditingController customerCtrl;
  late final TextEditingController projectNameCtrl;
  late final TextEditingController phoneCtrl;
  late final TextEditingController addressCtrl;
  late final TextEditingController customerNoteCtrl;
  late final TextEditingController billCtrl;
  late final TextEditingController kwhCtrl;
  late final TextEditingController dayKwhCtrl;
  late final TextEditingController nightKwhCtrl;
  late final TextEditingController roofWidthCtrl;
  late final TextEditingController roofLengthCtrl;
  late final TextEditingController peakSunCtrl;
  late final TextEditingController batteryCapacityCtrl;
  late final TextEditingController backupHoursCtrl;

  @override
  void initState() {
    super.initState();
    customerCtrl = TextEditingController(text: widget.project.customerName);
    projectNameCtrl = TextEditingController(text: widget.project.projectName);
    phoneCtrl = TextEditingController(text: widget.project.customerPhone);
    addressCtrl =
        TextEditingController(text: widget.project.installationAddress);
    customerNoteCtrl = TextEditingController(text: widget.project.customerNote);
    billCtrl = TextEditingController(
        text: widget.project.monthlyBill.toStringAsFixed(0));
    kwhCtrl = TextEditingController(
        text: widget.project.monthlyKwh.toStringAsFixed(0));
    dayKwhCtrl = TextEditingController(
      text: widget.project.dayKwhPerDay.toStringAsFixed(1),
    );
    nightKwhCtrl = TextEditingController(
      text: widget.project.nightKwhPerDay.toStringAsFixed(1),
    );
    roofWidthCtrl = TextEditingController(
        text: widget.project.roofWidth.toStringAsFixed(1));
    roofLengthCtrl = TextEditingController(
        text: widget.project.roofLength.toStringAsFixed(1));
    peakSunCtrl = TextEditingController(
        text: widget.project.peakSunHours.toStringAsFixed(1));
    batteryCapacityCtrl = TextEditingController(
      text: widget.project.batteryCapacityKwh.toStringAsFixed(1),
    );
    backupHoursCtrl = TextEditingController(
      text: widget.project.backupHours.toStringAsFixed(0),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.openResult) _saveAndOpenResult();
      if (widget.openSummary) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => SummaryScreen(project: widget.project)),
        );
      }
    });
  }

  void _save() {
    widget.project.customerName = customerCtrl.text.trim();
    widget.project.projectName = projectNameCtrl.text.trim();
    widget.project.customerPhone = phoneCtrl.text.trim();
    widget.project.installationAddress = addressCtrl.text.trim();
    widget.project.customerNote = customerNoteCtrl.text.trim();
    widget.project.monthlyBill = double.tryParse(billCtrl.text) ?? 0;
    widget.project.monthlyKwh = double.tryParse(kwhCtrl.text) ?? 0;
    widget.project.dayKwhPerDay = double.tryParse(dayKwhCtrl.text) ?? 0;
    widget.project.nightKwhPerDay = double.tryParse(nightKwhCtrl.text) ?? 0;
    widget.project.roofWidth = double.tryParse(roofWidthCtrl.text) ?? 0;
    widget.project.roofLength = double.tryParse(roofLengthCtrl.text) ?? 0;
    widget.project.roofArea =
        widget.project.roofWidth * widget.project.roofLength;
    widget.project.peakSunHours =
        (double.tryParse(peakSunCtrl.text) ?? 4.5).clamp(0.1, 24);
    widget.project.batteryCapacityKwh =
        double.tryParse(batteryCapacityCtrl.text) ?? 0;
    widget.project.backupHours = double.tryParse(backupHoursCtrl.text) ?? 0;
  }

  @override
  void dispose() {
    customerCtrl.dispose();
    projectNameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    customerNoteCtrl.dispose();
    billCtrl.dispose();
    kwhCtrl.dispose();
    dayKwhCtrl.dispose();
    nightKwhCtrl.dispose();
    roofWidthCtrl.dispose();
    roofLengthCtrl.dispose();
    peakSunCtrl.dispose();
    batteryCapacityCtrl.dispose();
    backupHoursCtrl.dispose();
    super.dispose();
  }

  double get _dayKwh => double.tryParse(dayKwhCtrl.text) ?? 0;
  double get _nightKwh => double.tryParse(nightKwhCtrl.text) ?? 0;
  double get _peakSunHour => double.tryParse(peakSunCtrl.text) ?? 4.5;
  double get _roofWidth => double.tryParse(roofWidthCtrl.text) ?? 0;
  double get _roofLength => double.tryParse(roofLengthCtrl.text) ?? 0;
  double get _roofArea => _roofWidth * _roofLength;
  double get _monthlyKwh => double.tryParse(kwhCtrl.text) ?? 0;
  double get _monthlyAverageDaily =>
      (_monthlyKwh / 30).clamp(0, double.infinity).toDouble();

  String _energyText(double value) => value.toStringAsFixed(1);

  void _syncFromDay() {
    final total = _monthlyAverageDaily;
    final day = _dayKwh.clamp(0, total).toDouble();
    if (_dayKwh != day) dayKwhCtrl.text = _energyText(day);
    nightKwhCtrl.text = _energyText(total - day);
    setState(() {});
  }

  void _syncFromNight() {
    final total = _monthlyAverageDaily;
    final night = _nightKwh.clamp(0, total).toDouble();
    if (_nightKwh != night) nightKwhCtrl.text = _energyText(night);
    dayKwhCtrl.text = _energyText(total - night);
    setState(() {});
  }

  void _syncFromMonthlyTotal() {
    final total = _monthlyAverageDaily;
    final day = _dayKwh.clamp(0, total).toDouble();
    dayKwhCtrl.text = _energyText(day);
    nightKwhCtrl.text = _energyText(total - day);
    setState(() {});
  }

  Widget _systemChoice(String value, IconData icon, {String? label}) {
    final selected = widget.project.systemType == value;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            widget.project.systemType = value;
            widget.project.hasBattery =
                value != 'On-grid' && value != 'Air solar';
          });
          if (value == 'Air solar') _saveAndOpenResult();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 92,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE1F5FE) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  selected ? const Color(0xFF29B6F6) : const Color(0xFFDDE3EC),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: selected ? const Color(0xFF29B6F6) : Colors.black54),
              const SizedBox(height: 3),
              Text(label ?? value,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    color: selected ? const Color(0xFF29B6F6) : Colors.black87,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveAndOpenResult() async {
    _save();
    widget.project.calculationCompleted = true;
    await LocalProjectRepository().save(widget.project);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => widget.project.isAirSolarSystem
            ? AirConditionerSelectionScreen(project: widget.project)
            : ResultScreen(project: widget.project),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สร้างโปรเจกต์ใหม่')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
        children: [
          Container(
            height: 42,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF0F5),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => showDetails = false),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: showDetails
                            ? Colors.transparent
                            : const Color(0xFF29B6F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('ข้อมูลลูกค้า',
                          style: TextStyle(
                              color:
                                  showDetails ? Colors.black87 : Colors.white,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => showDetails = true),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: showDetails
                            ? const Color(0xFF29B6F6)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('ออกแบบระบบ',
                          style: TextStyle(
                              color:
                                  showDetails ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (!showDetails) ...[
            TextField(
                controller: customerCtrl,
                decoration: const InputDecoration(labelText: 'ชื่อลูกค้า')),
            const SizedBox(height: 12),
            TextField(
              controller: projectNameCtrl,
              decoration: const InputDecoration(
                labelText: 'ชื่อโครงการ',
                hintText: 'เช่น บ้านคุณสมชาย เชียงใหม่',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'เบอร์โทรศัพท์',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 14),
            _detailMenu(Icons.location_on_outlined, 'สถานที่ติดตั้ง',
                color: PVForgeColors.primary,
                onTap: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              LocationMapScreen(project: widget.project)));
                  // ที่อยู่อาจถูกแก้ในหน้าแผนที่ด้วย ต้องรีเฟรชช่องที่อยู่
                  // ในหน้านี้ให้ตรงกัน ไม่งั้นจะเห็นค่าเก่าค้างอยู่
                  addressCtrl.text = widget.project.installationAddress;
                  if (mounted) setState(() {});
                }),
            _detailMenu(Icons.roofing_outlined, 'ข้อมูลหลังคา',
                color: PVForgeColors.warning,
                onTap: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              RoofInfoScreen(project: widget.project)));
                  if (mounted) setState(() {});
                }),
            _detailMenu(Icons.electrical_services_outlined, 'ระบบไฟฟ้า',
                color: PVForgeColors.battery,
                onTap: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              ElectricalSystemScreen(project: widget.project)));
                  if (mounted) setState(() {});
                }),
            _detailMenu(Icons.cable_outlined, 'จุดติดตั้งและระยะสาย',
                color: const Color(0xFF8B5CF6)),
            _detailMenu(Icons.add_a_photo_outlined, 'รูปภาพหน้างาน',
                color: PVForgeColors.critical,
                onTap: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              SitePhotosScreen(project: widget.project)));
                  if (mounted) setState(() {});
                }),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => setState(() => showDetails = true),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('ถัดไป: ออกแบบระบบ'),
              ),
            ),
          ] else ...[
            TextField(
              controller: customerNoteCtrl,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'หมายเหตุ',
                hintText: 'พิมพ์รายละเอียดเพิ่มเติม...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 18),
            const Text('ข้อมูลสำหรับคำนวณระบบ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            const Text('ประเภทระบบ',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Row(
              children: [
                _systemChoice('On-grid', Icons.language),
                const SizedBox(width: 8),
                _systemChoice('Hybrid', Icons.battery_charging_full),
                const SizedBox(width: 8),
                _systemChoice('Off-grid', Icons.wb_sunny_outlined),
                const SizedBox(width: 8),
                _systemChoice('Air solar', Icons.ac_unit,
                    label: 'แอร์โซล่าเซลล์'),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('บ้านมีแบตเตอรี่'),
              subtitle: Text(
                widget.project.systemType == 'On-grid'
                    ? 'ระบบ On-grid ไม่เลือกแบตเตอรี่'
                    : 'คำนวณความจุและระยะเวลาสำรองไฟ',
              ),
              value: widget.project.hasBattery,
              onChanged: widget.project.systemType == 'On-grid' ||
                      widget.project.isAirSolarSystem
                  ? null
                  : (value) =>
                      setState(() => widget.project.hasBattery = value),
            ),
            if (widget.project.hasBattery) ...[
              const SizedBox(height: 8),
              TextField(
                controller: batteryCapacityCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'ความจุแบตเตอรี่ที่มี/ต้องการ',
                  suffixText: 'kWh',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: backupHoursCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'ระยะเวลาสำรองไฟที่ต้องการ',
                  suffixText: 'ชั่วโมง',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'คำนวณที่ DoD ${widget.project.batteryDepthOfDischarge.toStringAsFixed(0)}% '
                'และประสิทธิภาพ ${widget.project.batteryEfficiency.toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: billCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'ค่าไฟเฉลี่ยต่อเดือน', suffixText: 'บาท'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: kwhCtrl,
              keyboardType: TextInputType.number,
              onChanged: (_) => _syncFromMonthlyTotal(),
              decoration: const InputDecoration(
                labelText: 'พลังงานรวมทั้งหมดต่อเดือน',
                suffixText: 'kWh/เดือน',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: dayKwhCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _syncFromDay(),
                    decoration: const InputDecoration(
                      labelText: 'ไฟกลางวัน/วัน',
                      suffixText: 'kWh',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: nightKwhCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _syncFromNight(),
                    decoration: const InputDecoration(
                      labelText: 'ไฟกลางคืน/วัน',
                      suffixText: 'kWh',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'พลังงานรวมต่อวัน ${_monthlyAverageDaily.toStringAsFixed(1)} kWh '
              '• ปรับช่องหนึ่ง อีกช่องจะคำนวณอัตโนมัติ',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            DailyLoadChart(
              totalKwh: _monthlyAverageDaily,
              dayKwh: _dayKwh,
              nightKwh: _nightKwh,
              peakSunHours: _peakSunHour,
              onChanged: (day, night) {
                dayKwhCtrl.text = _energyText(day);
                nightKwhCtrl.text = _energyText(night);
                setState(() {});
              },
            ),
            const SizedBox(height: 12),
            PeakSunHourChart(
              value: _peakSunHour,
              onChanged: (v) => setState(() {
                peakSunCtrl.text = v.toStringAsFixed(1);
              }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: peakSunCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Peak Sun Hour',
                suffixText: 'ชม./วัน',
                helperText: 'ค่าเฉลี่ยชั่วโมงแดดสูงสุดของพื้นที่ติดตั้ง',
              ),
            ),
            if (widget.project.hasBattery) ...[
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('คำนวณแบตเตอรี่จากไฟช่วงกลางคืน'),
                subtitle: Text(
                  'ต้องจ่ายไฟกลางคืนประมาณ ${_nightKwh.toStringAsFixed(1)} kWh/คืน',
                ),
                value: widget.project.sizeBatteryFromNightUsage,
                onChanged: (value) => setState(() {
                  widget.project.sizeBatteryFromNightUsage = value ?? true;
                }),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: roofWidthCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'ความกว้าง',
                      suffixText: 'ม.',
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('×',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: TextField(
                    controller: roofLengthCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'ความยาว',
                      suffixText: 'ม.',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_roofWidth.toStringAsFixed(1)} × ${_roofLength.toStringAsFixed(1)} = ${_roofArea.toStringAsFixed(1)} m²',
                style: const TextStyle(
                    color: Color(0xFF29B6F6), fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE1F5FE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFB3E5FC)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.square_foot_outlined,
                          size: 18, color: Color(0xFF29B6F6)),
                      SizedBox(width: 7),
                      Text('ผลคำนวณพื้นที่หลังคา',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _roofResultRow('พื้นที่ต่อแผง',
                      '${widget.project.panelAreaM2.toStringAsFixed(2)} m²'),
                  _roofResultRow('จำนวนที่วางได้',
                      '${(_roofArea / widget.project.panelAreaM2).floor()} แผง'),
                  _roofResultRow(
                    'กำลังติดตั้งสูงสุด',
                    '${((_roofArea / widget.project.panelAreaM2).floor() * widget.project.panelWatt / 1000).toStringAsFixed(2)} kWp',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saveAndOpenResult,
              icon: const Icon(Icons.calculate),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('คำนวณขนาดระบบ'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailMenu(IconData icon, String title,
          {Color color = PVForgeColors.primary, VoidCallback? onTap}) =>
      Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: GradientIconBadge(icon: icon, color: color, size: 38),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap ??
              // เมนูนี้ยังไม่มีหน้าของตัวเอง (อยู่ระหว่างพิจารณาว่าจะออกแบบ
              // ยังไง) เลยแจ้งชั่วคราวว่ากรอกด้านล่างได้
              () => showAppBanner(
                  context, 'เลือกกรอก$titleได้ในส่วนข้อมูลคำนวณด้านล่าง'),
        ),
      );


  Widget _roofResultRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.black54)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      );
}
