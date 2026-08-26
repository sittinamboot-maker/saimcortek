import 'package:flutter/material.dart';

import '../models/solar_project.dart';
import 'string_checker_screen.dart';

class _InverterOption {
  final String name, type;
  final double kw, maxDc, mpptMin, mpptMax, maxCurrent;
  final int mpptCount;
  const _InverterOption(this.name, this.type, this.kw, this.maxDc, this.mpptMin,
      this.mpptMax, this.maxCurrent, this.mpptCount);
}

class InverterSelectionScreen extends StatefulWidget {
  final SolarProject project;
  const InverterSelectionScreen({super.key, required this.project});
  @override
  State<InverterSelectionScreen> createState() =>
      _InverterSelectionScreenState();
}

class _InverterSelectionScreenState extends State<InverterSelectionScreen> {
  final options = <_InverterOption>[
    _InverterOption(
        'Deye SUN-5K-SG03LP1-EU', 'Hybrid', 5, 500, 150, 425, 13, 2),
    _InverterOption(
        'Deye SUN-6K-SG03LP1-EU', 'Hybrid', 6, 500, 150, 425, 16, 2),
    _InverterOption('Sungrow SG5.0RS', 'On-grid', 5, 600, 40, 560, 16, 2),
    _InverterOption('Sungrow SG6.0RS', 'On-grid', 6, 600, 40, 560, 16, 2),
    _InverterOption(
        'Huawei SUN2000-6KTL-L1', 'Hybrid', 6, 600, 90, 560, 12.5, 2),
    _InverterOption(
        'Growatt MIN 6000TL-X', 'On-grid', 6, 550, 80, 500, 13.5, 2),
  ];
  late int selected;

  @override
  void initState() {
    super.initState();
    selected = _automaticIndex();
    _apply(options[selected]);
  }

  int _automaticIndex() {
    var best = 0;
    var bestScore = double.infinity;
    for (var i = 0; i < options.length; i++) {
      final item = options[i];
      final compatible = widget.project.systemType == 'On-grid'
          ? item.type == 'On-grid'
          : item.type == 'Hybrid';
      final score =
          (compatible ? 0 : 1000) + (item.kw - widget.project.systemKwp).abs();
      if (score < bestScore) {
        bestScore = score;
        best = i;
      }
    }
    return best;
  }

  void _apply(_InverterOption item) {
    final p = widget.project;
    p.inverterModel = item.name;
    p.inverterKw = item.kw;
    p.inverterMaxDcVoltage = item.maxDc;
    p.inverterMpptMin = item.mpptMin;
    p.inverterMpptMax = item.mpptMax;
    p.inverterMaxInputCurrent = item.maxCurrent;
    p.inverterMpptCount = item.mpptCount;
  }

  Future<void> _addCustomInverter() async {
    final nameCtrl = TextEditingController();
    final kwCtrl = TextEditingController(
        text: widget.project.systemKwp.toStringAsFixed(1));
    final maxDcCtrl = TextEditingController(text: '500');
    final mpptMinCtrl = TextEditingController(text: '125');
    final mpptMaxCtrl = TextEditingController(text: '425');
    final currentCtrl = TextEditingController(text: '16');
    final mpptCountCtrl = TextEditingController(text: '2');
    var type = widget.project.systemType == 'On-grid' ? 'On-grid' : 'Hybrid';

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('เพิ่ม Inverter เอง'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration:
                    const InputDecoration(labelText: 'ยี่ห้อ / รุ่น Inverter'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'ประเภทระบบ'),
                items: const [
                  DropdownMenuItem(value: 'On-grid', child: Text('On-grid')),
                  DropdownMenuItem(value: 'Hybrid', child: Text('Hybrid')),
                  DropdownMenuItem(value: 'Off-grid', child: Text('Off-grid')),
                ],
                onChanged: (value) =>
                    setDialogState(() => type = value ?? 'On-grid'),
              ),
              const SizedBox(height: 10),
              _numberField(kwCtrl, 'กำลังพิกัด', 'kW'),
              const SizedBox(height: 10),
              _numberField(maxDcCtrl, 'แรงดัน DC สูงสุด', 'V'),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _numberField(mpptMinCtrl, 'MPPT ต่ำสุด', 'V')),
                const SizedBox(width: 8),
                Expanded(child: _numberField(mpptMaxCtrl, 'MPPT สูงสุด', 'V')),
              ]),
              const SizedBox(height: 10),
              _numberField(currentCtrl, 'กระแส Input สูงสุด', 'A'),
              const SizedBox(height: 10),
              _numberField(mpptCountCtrl, 'จำนวน MPPT', 'ช่อง'),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('ยกเลิก')),
            FilledButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                Navigator.pop(dialogContext, true);
              },
              child: const Text('เพิ่มและเลือกใช้'),
            ),
          ],
        ),
      ),
    );

    if (saved == true && mounted) {
      final item = _InverterOption(
        nameCtrl.text.trim(),
        type,
        double.tryParse(kwCtrl.text) ?? 0,
        double.tryParse(maxDcCtrl.text) ?? 0,
        double.tryParse(mpptMinCtrl.text) ?? 0,
        double.tryParse(mpptMaxCtrl.text) ?? 0,
        double.tryParse(currentCtrl.text) ?? 0,
        (int.tryParse(mpptCountCtrl.text) ?? 1).clamp(1, 12).toInt(),
      );
      setState(() {
        options.add(item);
        selected = options.length - 1;
        _apply(item);
      });
    }

    nameCtrl.dispose();
    kwCtrl.dispose();
    maxDcCtrl.dispose();
    mpptMinCtrl.dispose();
    mpptMaxCtrl.dispose();
    currentCtrl.dispose();
    mpptCountCtrl.dispose();
  }

  Widget _numberField(
          TextEditingController controller, String label, String suffix) =>
      TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, suffixText: suffix),
      );

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    return Scaffold(
      appBar: AppBar(title: const Text('เลือก Inverter')),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 112), children: [
        OutlinedButton.icon(
          onPressed: _addCustomInverter,
          icon: const Text('+',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('เพิ่ม Inverter เอง'),
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < options.length; i++) _optionCard(i),
        const SizedBox(height: 8),
        Card(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  _row('ขนาดระบบแผง', '${p.systemKwp.toStringAsFixed(2)} kWp'),
                  _row(
                      'ขนาด Inverter', '${p.inverterKw.toStringAsFixed(1)} kW'),
                  _row('แรงดัน DC สูงสุด',
                      '${p.inverterMaxDcVoltage.toStringAsFixed(0)} V'),
                  _row('ช่วง MPPT',
                      '${p.inverterMpptMin.toStringAsFixed(0)}–${p.inverterMpptMax.toStringAsFixed(0)} V'),
                  _row('จำนวน MPPT', '${p.inverterMpptCount} ช่อง'),
                ]))),
        const SizedBox(height: 14),
        FilledButton(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => StringCheckerScreen(project: p))),
          child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('ถัดไป: จัด String / ตรวจ MPPT')),
        ),
      ]),
    );
  }

  Widget _optionCard(int index) {
    final item = options[index];
    final isSelected = selected == index;
    final compatible = widget.project.systemType == 'On-grid'
        ? item.type == 'On-grid'
        : item.type == 'Hybrid';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
              color: isSelected ? const Color(0xFFB3E5FC) : Colors.transparent,
              width: 2)),
      child: ListTile(
        onTap: () => setState(() {
          selected = index;
          _apply(item);
        }),
        leading: Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: isSelected ? const Color(0xFF29B6F6) : Colors.grey),
        title: Text(item.name,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
            '${item.kw.toStringAsFixed(1)} kW • ${item.type} • ${item.mpptCount} MPPT • ${item.mpptMin.toStringAsFixed(0)}–${item.mpptMax.toStringAsFixed(0)} V'),
        trailing: Icon(compatible ? Icons.check_circle : Icons.info_outline,
            color: compatible ? Colors.green : const Color(0xFF29B6F6)),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold))
            ]),
      );
}
