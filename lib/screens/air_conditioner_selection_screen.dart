import 'package:flutter/material.dart';

import '../models/solar_project.dart';
import 'panel_selection_screen.dart';

class AirConditionerSelectionScreen extends StatefulWidget {
  final SolarProject project;

  const AirConditionerSelectionScreen({super.key, required this.project});

  @override
  State<AirConditionerSelectionScreen> createState() =>
      _AirConditionerSelectionScreenState();
}

class _AirConditionerSelectionScreenState
    extends State<AirConditionerSelectionScreen> {
  static const _powerByBtu = <int, double>{
    9000: .8,
    12000: 1.1,
    18000: 1.7,
    24000: 2.2,
  };

  static const _catalog = <int, ({String brand, String model, String image})>{
    9000: (
      brand: 'Daikin',
      model: 'FTKQ09UV2S',
      image: 'assets/products/air_conditioners/daikin_ftkq09uv2s.jpg',
    ),
    12000: (
      brand: 'Carrier',
      model: '42TVEB013 / 38TVEB013',
      image: 'assets/products/air_conditioners/carrier_42tveb013.jpg',
    ),
    18000: (
      brand: 'Mitsubishi Electric',
      model: 'MSZ/MUZ-HT50VF',
      image: 'assets/products/air_conditioners/mitsubishi_msz_muz_ht50vf.jpg',
    ),
    24000: (
      brand: 'LG',
      model: 'ICL24M DUALCOOL Pro',
      image: 'assets/products/air_conditioners/lg_icl24m.jpg',
    ),
  };

  late final TextEditingController _countController;
  late final TextEditingController _powerController;
  late final TextEditingController _hoursController;

  List<AirConditionerModelOption> _modelsForBtu(int btu) {
    final defaultModel = _catalog[btu]!;
    return [
      AirConditionerModelOption(
        brand: defaultModel.brand,
        model: defaultModel.model,
        btu: btu,
        powerKw: _powerByBtu[btu]!,
        imageUrl: defaultModel.image,
      ),
      ...widget.project.customAirConditionerModels
          .where((model) => model.btu == btu),
    ];
  }

  @override
  void initState() {
    super.initState();
    final project = widget.project;
    _countController =
        TextEditingController(text: project.airConditionerCount.toString());
    _powerController = TextEditingController(
        text: project.airConditionerPowerKw.toStringAsFixed(2));
    _hoursController = TextEditingController(
        text: project.airConditionerHoursPerDay.toStringAsFixed(1));
    if (project.airConditioners.isEmpty) {
      project.airConditioners.add(AirConditionerUnit(
        brand: project.airConditionerBrand,
        model: project.airConditionerModel,
        btu: project.airConditionerBtu,
        quantity: project.airConditionerCount,
        powerKw: project.airConditionerPowerKw,
        hoursPerDay: project.airConditionerHoursPerDay,
        imageUrl: project.airConditionerImageUrl,
      ));
    }
  }

  @override
  void dispose() {
    _countController.dispose();
    _powerController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  void _addCatalogAir(AirConditionerModelOption product) {
    final btu = product.btu;
    setState(() {
      widget.project.airConditionerBtu = btu;
      _powerController.text = product.powerKw.toStringAsFixed(2);
      widget.project.airConditionerBrand = product.brand;
      widget.project.airConditionerModel = product.model;
      widget.project.airConditionerImageUrl = product.imageUrl;
      _countController.text = '1';
      _hoursController.text = '8.0';
      final selectedUnit = AirConditionerUnit(
        brand: product.brand,
        model: product.model,
        btu: btu,
        quantity: 1,
        powerKw: product.powerKw,
        hoursPerDay: 8,
        imageUrl: product.imageUrl,
      );
      widget.project.airConditioners.add(selectedUnit);
    });
  }

  Future<void> _showModelsForBtu(int btu) async {
    final models = _modelsForBtu(btu);
    var selected = models.first;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('เพิ่มแอร์ในหัวข้อ ${btu.toStringAsFixed(0)} BTU/h',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            for (final product in models)
              RadioListTile<AirConditionerModelOption>(
                value: product,
                groupValue: selected,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) => setDialogState(() => selected = value!),
                secondary: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(product.imageUrl,
                      width: 56,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(
                          width: 56, height: 48, child: Icon(Icons.air))),
                ),
                title: Text('${product.brand} ${product.model}'),
                subtitle: Text(
                    '${product.btu} BTU/h • ${product.powerKw.toStringAsFixed(2)} kW'),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showAddBrandOption(btu);
                },
                icon: const Icon(Icons.add),
                label: const Text('เพิ่มยี่ห้อ / รุ่นเอง'),
              ),
            ),
          ]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            FilledButton(
              onPressed: () {
                _addCatalogAir(selected);
                Navigator.pop(context);
              },
              child: const Text('เพิ่มแอร์รุ่นนี้'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddBrandOption(int btu) async {
    final brand = TextEditingController();
    final model = TextEditingController();
    final power =
        TextEditingController(text: _powerByBtu[btu]!.toStringAsFixed(2));
    final added = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('เพิ่มยี่ห้อ / รุ่น $btu BTU/h'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _dialogField(brand, 'ยี่ห้อ', text: true),
          _dialogField(model, 'รุ่น', text: true),
          _dialogField(power, 'กำลังไฟ', suffix: 'kW'),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ยกเลิก')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('บันทึกรุ่น')),
        ],
      ),
    );
    if (added == true &&
        brand.text.trim().isNotEmpty &&
        model.text.trim().isNotEmpty) {
      setState(() => widget.project.customAirConditionerModels.add(
            AirConditionerModelOption(
              brand: brand.text.trim(),
              model: model.text.trim(),
              btu: btu,
              powerKw: double.tryParse(power.text) ?? 0,
              imageUrl: _catalog[btu]!.image,
            ),
          ));
      await _showModelsForBtu(btu);
    }
    await Future<void>.delayed(kThemeAnimationDuration);
    for (final controller in [brand, model, power]) {
      controller.dispose();
    }
  }

  Future<void> _addCustomAirConditioner() async {
    final project = widget.project;
    final brand = TextEditingController(text: project.airConditionerBrand);
    final model = TextEditingController(text: project.airConditionerModel);
    final count = TextEditingController(text: _countController.text);
    final power = TextEditingController(text: _powerController.text);
    final hours = TextEditingController(text: _hoursController.text);
    var selectedBtu = project.airConditionerBtu;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('เพิ่มแอร์เอง'),
          content: SizedBox(
            width: 360,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                _dialogField(brand, 'ยี่ห้อ', text: true),
                _dialogField(model, 'รุ่น', text: true),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('ขนาดความเย็น',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _powerByBtu.keys
                      .map((btu) => ChoiceChip(
                            label: Text('${btu.toStringAsFixed(0)} BTU/h'),
                            selected: selectedBtu == btu,
                            onSelected: (_) =>
                                setDialogState(() => selectedBtu = btu),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1F5FE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'รายการนี้จะบันทึกในหัวข้อ ${selectedBtu.toStringAsFixed(0)} BTU/h',
                    style: const TextStyle(
                        color: Color(0xFF0277BD), fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: _dialogField(count, 'จำนวน', suffix: 'เครื่อง')),
                  const SizedBox(width: 10),
                  Expanded(child: _dialogField(power, 'กำลังไฟ', suffix: 'kW')),
                ]),
                _dialogField(hours, 'ชั่วโมงใช้งาน', suffix: 'ชม./วัน'),
              ]),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('ยกเลิก')),
            FilledButton(
              onPressed: () {
                if (brand.text.trim().isEmpty || model.text.trim().isEmpty)
                  return;
                Navigator.pop(context, true);
              },
              child: const Text('เพิ่มแอร์'),
            ),
          ],
        ),
      ),
    );

    if (saved == true && mounted) {
      setState(() {
        project.airConditioners.add(AirConditionerUnit(
          brand: brand.text.trim(),
          model: model.text.trim(),
          btu: selectedBtu,
          quantity: (int.tryParse(count.text) ?? 1).clamp(1, 100).toInt(),
          powerKw: (double.tryParse(power.text) ?? 0).clamp(0, 100).toDouble(),
          hoursPerDay:
              (double.tryParse(hours.text) ?? 0).clamp(0, 24).toDouble(),
          imageUrl: _catalog[selectedBtu]!.image,
        ));
      });
    }
    // The dialog route is still disposing while its close animation runs.
    // Keep the controllers alive until its TextFields are fully detached.
    await Future<void>.delayed(kThemeAnimationDuration);
    for (final controller in [brand, model, count, power, hours]) {
      controller.dispose();
    }
  }

  Widget _dialogField(TextEditingController controller, String label,
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

  void _saveAndContinue() {
    final project = widget.project;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PanelSelectionScreen(project: project)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final selectedModelCount = project.airConditioners.length;
    final selectedUnitCount = project.airConditioners
        .fold<int>(0, (sum, unit) => sum + unit.quantity);
    final totalPowerKw = project.airConditioners
        .fold<double>(0, (sum, unit) => sum + unit.powerKw * unit.quantity);
    final totalAirEnergy = project.airConditionerDailyKwh;
    return Scaffold(
      appBar: AppBar(title: const Text('เลือกขนาดเครื่องปรับอากาศ')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
        children: [
          const Text('ระบบแอร์โซล่าเซลล์',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('เลือกขนาดแอร์และบันทึกข้อมูลพลังงาน ก่อนเลือกขนาดแผง',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _powerByBtu.entries.map((entry) {
              final selected = project.airConditionerBtu == entry.key;
              final addedCount = project.airConditioners
                  .where((unit) => unit.btu == entry.key)
                  .fold<int>(0, (sum, unit) => sum + unit.quantity);
              return SizedBox(
                width: (MediaQuery.sizeOf(context).width - 42) / 2,
                child: ChoiceChip(
                  selected: selected,
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${entry.key.toStringAsFixed(0)} BTU/h'),
                        if (addedCount > 0)
                          Text('เพิ่มแล้ว $addedCount เครื่อง',
                              style: const TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                  onSelected: (_) => _showModelsForBtu(entry.key),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('เครื่องปรับอากาศ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          for (final btu in _powerByBtu.keys) ...[
            if (project.airConditioners.any((unit) => unit.btu == btu)) ...[
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 6),
                child: Text('${btu.toStringAsFixed(0)} BTU/h',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              for (final entry in project.airConditioners.indexed
                  .where((entry) => entry.$2.btu == btu))
                _airConditionerCard(entry.$2, entry.$1),
            ],
          ],
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: _summaryField(
                  'จำนวนแอร์ที่เลือก', '$selectedUnitCount', 'เครื่อง'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryField(
                  'กำลังไฟรวม', totalPowerKw.toStringAsFixed(2), 'kW'),
            ),
          ]),
          const SizedBox(height: 12),
          _summaryField('พลังงานแอร์รวมต่อวัน',
              totalAirEnergy.toStringAsFixed(1), 'kWh/วัน'),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.bolt, color: Color(0xFF29B6F6)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                        'พลังงานแอร์รวม $selectedModelCount รุ่น • $selectedUnitCount เครื่อง\n'
                        '${totalAirEnergy.toStringAsFixed(1)} kWh/วัน',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _saveAndContinue,
            icon: const Icon(Icons.solar_power),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('ถัดไป: เลือกขนาดแผง'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _airConditionerCard(AirConditionerUnit unit, int index) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(unit.imageUrl,
                width: 76,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(
                    width: 76, height: 56, child: Icon(Icons.air))),
          ),
          title: Text(
              '${index + 1}. ${unit.btu.toStringAsFixed(0)} BTU/h • ${unit.brand} ${unit.model}'),
          subtitle: Text(
              '${unit.btu} BTU/h × ${unit.quantity} เครื่อง • ${unit.powerKw.toStringAsFixed(2)} kW • ${unit.hoursPerDay.toStringAsFixed(1)} ชม./วัน'),
          isThreeLine: true,
          trailing: IconButton(
            tooltip: 'ลบรายการ',
            icon: const Icon(Icons.delete_outline),
            onPressed: () =>
                setState(() => widget.project.airConditioners.removeAt(index)),
          ),
        ),
      );

  Widget _summaryField(String label, String value, String suffix) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .42),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 4),
          Row(children: [
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700)),
            ),
            Text(suffix, style: const TextStyle(color: Colors.black54)),
          ]),
        ]),
      );
}
