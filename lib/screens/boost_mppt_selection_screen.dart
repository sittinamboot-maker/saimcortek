import 'package:flutter/material.dart';

import '../models/solar_project.dart';
import '../theme/pvforge_theme.dart';
import '../widgets/pvforge_components.dart';
import 'string_checker_screen.dart';

/// หน้าเลือก Boost / MPPT แยกออกมาจากหน้าจัด String โดยเฉพาะ
/// (เดิมทั้งสองเรื่องอยู่หน้าเดียวกันใน string_checker_screen.dart ทำให้
/// ระบบ Off-grid/แอร์โซล่าเซลล์ปนกับการจัด String จึงแยกให้ชัดเจนขึ้น)
class _BoostMpptOption {
  final String name;
  final double kw, maxDc, mpptMin, mpptMax, maxCurrent;
  final int mpptCount;

  const _BoostMpptOption(this.name, this.kw, this.maxDc, this.mpptMin,
      this.mpptMax, this.maxCurrent, this.mpptCount);
}

class BoostMpptSelectionScreen extends StatefulWidget {
  final SolarProject project;
  const BoostMpptSelectionScreen({super.key, required this.project});

  @override
  State<BoostMpptSelectionScreen> createState() =>
      _BoostMpptSelectionScreenState();
}

class _BoostMpptSelectionScreenState extends State<BoostMpptSelectionScreen> {
  final boostOptions = <_BoostMpptOption>[
    const _BoostMpptOption('Boost / MPPT 5 kW', 5, 500, 125, 425, 13, 2),
    const _BoostMpptOption('Boost / MPPT 6 kW', 6, 500, 125, 425, 16, 2),
    const _BoostMpptOption('Boost / MPPT 10 kW', 10, 600, 150, 550, 20, 2),
  ];
  late int selectedBoost;

  @override
  void initState() {
    super.initState();
    selectedBoost = _automaticIndex();
    _applyBoost(boostOptions[selectedBoost]);
  }

  int _automaticIndex() {
    var best = 0;
    var bestScore = double.infinity;
    for (var i = 0; i < boostOptions.length; i++) {
      final score = (boostOptions[i].kw - widget.project.systemKwp).abs();
      if (score < bestScore) {
        bestScore = score;
        best = i;
      }
    }
    return best;
  }

  void _applyBoost(_BoostMpptOption item) {
    final project = widget.project;
    project.inverterModel = item.name;
    project.inverterKw = item.kw;
    project.inverterMaxDcVoltage = item.maxDc;
    project.inverterMpptMin = item.mpptMin;
    project.inverterMpptMax = item.mpptMax;
    project.inverterMaxInputCurrent = item.maxCurrent;
    project.inverterMpptCount = item.mpptCount;
  }

  Future<void> _addBoost() async {
    final name = TextEditingController();
    final kw = TextEditingController(text: '6');
    final maxDc = TextEditingController(text: '500');
    final min = TextEditingController(text: '125');
    final max = TextEditingController(text: '425');
    final current = TextEditingController(text: '16');
    final mppt = TextEditingController(text: '2');
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เพิ่ม Boost / MPPT'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _boostField(name, 'ชื่อ / รุ่น', text: true),
            _boostField(kw, 'กำลังพิกัด', suffix: 'kW'),
            _boostField(maxDc, 'แรงดัน DC สูงสุด', suffix: 'V'),
            Row(children: [
              Expanded(child: _boostField(min, 'MPPT ต่ำสุด', suffix: 'V')),
              const SizedBox(width: 8),
              Expanded(child: _boostField(max, 'MPPT สูงสุด', suffix: 'V')),
            ]),
            _boostField(current, 'กระแสสูงสุด', suffix: 'A'),
            _boostField(mppt, 'จำนวน MPPT', suffix: 'ช่อง'),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ยกเลิก')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('เพิ่ม Boost')),
        ],
      ),
    );
    if (saved == true && name.text.trim().isNotEmpty && mounted) {
      final option = _BoostMpptOption(
        name.text.trim(),
        double.tryParse(kw.text) ?? 0,
        double.tryParse(maxDc.text) ?? 0,
        double.tryParse(min.text) ?? 0,
        double.tryParse(max.text) ?? 0,
        double.tryParse(current.text) ?? 0,
        (int.tryParse(mppt.text) ?? 1).clamp(1, 12).toInt(),
      );
      setState(() {
        boostOptions.add(option);
        selectedBoost = boostOptions.length - 1;
        _applyBoost(option);
      });
    }
    await Future<void>.delayed(kThemeAnimationDuration);
    for (final controller in [name, kw, maxDc, min, max, current, mppt]) {
      controller.dispose();
    }
  }

  Widget _boostField(TextEditingController controller, String label,
          {String? suffix, bool text = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: controller,
          keyboardType: text
              ? TextInputType.text
              : const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: label, suffixText: suffix),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    return Scaffold(
      appBar: AppBar(title: const Text('เลือก Boost / MPPT')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
        children: [
          for (var i = 0; i < boostOptions.length; i++) _optionCard(i),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addBoost,
            icon: const Icon(Icons.add_circle_outline),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 11),
              child: Text('เพิ่ม Boost / MPPT เอง'),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.inverterModel,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                      '${p.inverterKw.toStringAsFixed(1)} kW • ${p.inverterMpptCount} MPPT • '
                      '${p.inverterMpptMin.toStringAsFixed(0)}–${p.inverterMpptMax.toStringAsFixed(0)} V • '
                      '${p.inverterMaxInputCurrent.toStringAsFixed(0)} A'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => StringCheckerScreen(project: p)),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('ถัดไป: จัด String'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionCard(int index) {
    final item = boostOptions[index];
    final selected = selectedBoost == index;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
            color: selected ? const Color(0xFFB3E5FC) : Colors.transparent,
            width: 2),
      ),
      child: ListTile(
        onTap: () => setState(() {
          selectedBoost = index;
          _applyBoost(item);
        }),
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: selected ? const Color(0xFF29B6F6) : Colors.grey,
        ),
        trailing: const GradientIconBadge(
          icon: Icons.bolt,
          color: PVForgeColors.primary,
          size: 38,
        ),
        title: Text(item.name,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          '${item.kw.toStringAsFixed(1)} kW • ${item.mpptCount} MPPT • '
          '${item.mpptMin.toStringAsFixed(0)}–${item.mpptMax.toStringAsFixed(0)} V • '
          '${item.maxCurrent.toStringAsFixed(0)} A',
        ),
      ),
    );
  }
}
