import 'package:flutter/material.dart';

import '../data/panel_catalog.dart';
import '../models/solar_project.dart';
import 'boost_mppt_selection_screen.dart';
import 'inverter_selection_screen.dart';

class PanelSelectionScreen extends StatefulWidget {
  final SolarProject project;

  const PanelSelectionScreen({super.key, required this.project});

  @override
  State<PanelSelectionScreen> createState() => _PanelSelectionScreenState();
}

class _PanelSelectionScreenState extends State<PanelSelectionScreen> {
  late final List<SolarPanelProduct> _panels;

  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    _panels = [...solarPanelCatalog, ...userSolarPanelCatalog];
    selectedIndex = _automaticPanelIndex();
    _applyPanel(_panels[selectedIndex]);
  }

  int _panelCount(SolarPanelProduct panel) {
    final dailyPerPanel = panel.watt /
        1000 *
        widget.project.peakSunHours *
        widget.project.systemEfficiency;
    return dailyPerPanel <= 0
        ? 0
        : (widget.project.solarDailyEnergyTarget / dailyPerPanel).ceil();
  }

  int _automaticPanelIndex() {
    var bestIndex = 0;
    var bestScore = double.infinity;
    for (var i = 0; i < _panels.length; i++) {
      final count = _panelCount(_panels[i]);
      final roofCapacity =
          (widget.project.roofArea / _panels[i].areaM2).floor();
      final fits = count <= roofCapacity;
      final score = (fits ? 0 : 100000) + count * _panels[i].areaM2;
      if (score < bestScore) {
        bestScore = score;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  void _applyPanel(SolarPanelProduct panel) {
    final p = widget.project;
    // เปลี่ยนรุ่นแผงใหม่ทุกครั้ง ต้องล้างจำนวนแผงที่เคยปรับเองในหน้าจัด
    // String ทิ้ง เพื่อให้คำนวณจำนวนแผงที่แนะนำใหม่ตามรุ่นที่เพิ่งเลือก
    p.manualPanelCount = null;
    p.panelModel = panel.displayName;
    p.panelAreaM2 = panel.areaM2;
    p.panelWatt = panel.watt;
    p.panelVoc = panel.voc;
    p.panelVmp = panel.vmp;
    p.panelIsc = panel.isc;
    p.panelImp = panel.imp;
    p.panelEfficiency = panel.efficiency;
  }

  void _select(int index) {
    setState(() {
      selectedIndex = index;
      _applyPanel(_panels[index]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final fitsRoof = p.estimatedRoofArea <= p.roofArea;
    return Scaffold(
      appBar: AppBar(title: const Text('เลือกแผงโซลาร์เซลล์')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
        children: [
          OutlinedButton.icon(
            onPressed: _showAddPanelDialog,
            icon: const Icon(Icons.add_circle_outline),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 11),
              child: Text('เพิ่มแผงโซลาร์เซลล์เอง'),
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < _panels.length; i++) _panelCard(i),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _resultRow('จำนวนแผง', '${p.recommendedPanels} แผง'),
                  _resultRow(
                      'กำลังติดตั้ง', '${p.systemKwp.toStringAsFixed(2)} kWp'),
                  _resultRow('พื้นที่ที่ใช้',
                      '${p.estimatedRoofArea.toStringAsFixed(1)} / ${p.roofArea.toStringAsFixed(1)} m²'),
                  _resultRow(
                      'พื้นที่หลังคา', fitsRoof ? 'เพียงพอ' : 'ไม่เพียงพอ',
                      color: fitsRoof ? Colors.green : Colors.red),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => p.isAirSolarSystem
                    ? BoostMpptSelectionScreen(project: p)
                    : InverterSelectionScreen(project: p),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(p.isAirSolarSystem
                  ? 'ถัดไป: เลือก Boost / MPPT'
                  : 'ถัดไป: เลือก Inverter'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddPanelDialog() async {
    final brand = TextEditingController();
    final model = TextEditingController();
    final watt = TextEditingController();
    final voc = TextEditingController();
    final vmp = TextEditingController();
    final isc = TextEditingController();
    final imp = TextEditingController();
    final efficiency = TextEditingController();
    final length = TextEditingController();
    final width = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final panel = await showDialog<SolarPanelProduct>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('เพิ่มข้อมูลแผง'),
        content: SizedBox(
          width: 340,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogField(brand, 'ยี่ห้อ', numeric: false),
                  _dialogField(model, 'รุ่น', numeric: false),
                  _dialogField(watt, 'กำลังแผง (W)'),
                  Row(children: [
                    Expanded(child: _dialogField(voc, 'Voc (V)')),
                    const SizedBox(width: 8),
                    Expanded(child: _dialogField(vmp, 'Vmp (V)')),
                  ]),
                  Row(children: [
                    Expanded(child: _dialogField(isc, 'Isc (A)')),
                    const SizedBox(width: 8),
                    Expanded(child: _dialogField(imp, 'Imp (A)')),
                  ]),
                  _dialogField(efficiency, 'ประสิทธิภาพ (%)'),
                  Row(children: [
                    Expanded(child: _dialogField(length, 'ยาว (mm)')),
                    const SizedBox(width: 8),
                    Expanded(child: _dialogField(width, 'กว้าง (mm)')),
                  ]),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              Navigator.pop(
                dialogContext,
                SolarPanelProduct(
                  brand: brand.text.trim(),
                  model: model.text.trim(),
                  technology: 'กำหนดเอง',
                  watt: double.parse(watt.text),
                  voc: double.parse(voc.text),
                  vmp: double.parse(vmp.text),
                  isc: double.parse(isc.text),
                  imp: double.parse(imp.text),
                  efficiency: double.parse(efficiency.text),
                  lengthMm: double.parse(length.text).round(),
                  widthMm: double.parse(width.text).round(),
                ),
              );
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );

    for (final controller in [
      brand,
      model,
      watt,
      voc,
      vmp,
      isc,
      imp,
      efficiency,
      length,
      width
    ]) {
      controller.dispose();
    }
    if (panel == null || !mounted) return;
    setState(() {
      userSolarPanelCatalog.add(panel);
      _panels.add(panel);
      selectedIndex = _panels.length - 1;
      _applyPanel(panel);
    });
  }

  Widget _dialogField(TextEditingController controller, String label,
      {bool numeric = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: numeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'กรุณากรอกข้อมูล';
          if (numeric && (double.tryParse(value) ?? 0) <= 0) {
            return 'ค่าต้องมากกว่า 0';
          }
          return null;
        },
      ),
    );
  }

  Widget _panelCard(int index) {
    final panel = _panels[index];
    final selected = selectedIndex == index;
    final count = _panelCount(panel);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
            color: selected ? const Color(0xFFB3E5FC) : Colors.transparent,
            width: 2),
      ),
      child: ListTile(
        onTap: () => _select(index),
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: selected ? const Color(0xFF29B6F6) : Colors.grey,
        ),
        trailing: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _PanelThumbnail(imageAsset: panel.imageAsset),
        ),
        title: Text(panel.displayName,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          '${panel.watt.toStringAsFixed(0)} W • ${panel.efficiency.toStringAsFixed(1)}% • '
          '${panel.lengthMm}×${panel.widthMm} mm\n'
          '${panel.technology} • แนะนำ $count แผง',
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _resultRow(String label, String value, {Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value,
                style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      );
}

/// รูปตัวอย่างแผงที่เก็บในแอป จึงไม่ต้องรอการเชื่อมต่ออินเทอร์เน็ต
/// ถ้ายังไม่มีรูปจริงของรุ่นนั้น ๆ (ไม่ว่าจะเป็นแผงในแคตตาล็อกที่ยังไม่มีรูป
/// หรือแผงที่ผู้ใช้เพิ่มเอง) จะโชว์รูปตัวแทนเดียวกันทั้งหมด ให้ดูเป็นชุด
/// เดียวกัน แทนที่จะสุ่มสีต่างกันไปตามยี่ห้อ
class _PanelThumbnail extends StatelessWidget {
  final String imageAsset;

  const _PanelThumbnail({required this.imageAsset});

  static const _size = 38.0;
  static const _height = 58.0;
  static const _placeholderColor = Color(0xFF0277BD);

  Widget _placeholder() => SizedBox(
        width: _size,
        height: _height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _placeholderColor.withValues(alpha: .78),
                _placeholderColor,
              ],
            ),
          ),
          child: const Center(
            child: Icon(Icons.solar_power_outlined,
                color: Colors.white, size: 22),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (imageAsset.isEmpty) return _placeholder();
    return SizedBox(
      width: _size,
      height: _height,
      child: Image.asset(
        imageAsset,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      ),
    );
  }
}
