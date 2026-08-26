import 'package:flutter/material.dart';

import '../models/solar_project.dart';
import '../theme/pvforge_theme.dart';
import '../widgets/pvforge_components.dart';

class EquipmentScreen extends StatefulWidget {
  final SolarProject project;

  const EquipmentScreen({super.key, required this.project});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  Future<void> _openEquipmentDialog([CustomEquipment? equipment]) async {
    final nameCtrl = TextEditingController(text: equipment?.name ?? '');
    final quantityCtrl = TextEditingController(
      text: equipment?.quantity.toString() ?? '1',
    );
    final unitCtrl = TextEditingController(text: equipment?.unit ?? 'ชิ้น');
    final noteCtrl = TextEditingController(text: equipment?.note ?? '');
    var category = equipment?.category ?? 'อุปกรณ์อื่น';

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(equipment == null ? 'เพิ่มอุปกรณ์' : 'แก้ไขอุปกรณ์'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'ประเภทอุปกรณ์'),
                items: const [
                  DropdownMenuItem(
                      value: 'อินเวอร์เตอร์', child: Text('อินเวอร์เตอร์')),
                  DropdownMenuItem(
                      value: 'อุปกรณ์อื่น', child: Text('อุปกรณ์อื่น')),
                ],
                onChanged: (value) => category = value ?? 'อุปกรณ์อื่น',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'ชื่ออุปกรณ์'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: quantityCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'จำนวน'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: unitCtrl,
                      decoration: const InputDecoration(labelText: 'หน่วย'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                maxLines: 2,
                decoration:
                    const InputDecoration(labelText: 'รายละเอียด/รุ่น (ถ้ามี)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(context, true);
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );

    if (saved == true) {
      setState(() {
        if (equipment == null) {
          widget.project.customEquipment.add(
            CustomEquipment(
              name: nameCtrl.text.trim(),
              quantity: double.tryParse(quantityCtrl.text) ?? 1,
              unit:
                  unitCtrl.text.trim().isEmpty ? 'ชิ้น' : unitCtrl.text.trim(),
              note: noteCtrl.text.trim(),
              category: category,
            ),
          );
        } else {
          equipment
            ..name = nameCtrl.text.trim()
            ..quantity = double.tryParse(quantityCtrl.text) ?? 1
            ..unit =
                unitCtrl.text.trim().isEmpty ? 'ชิ้น' : unitCtrl.text.trim()
            ..note = noteCtrl.text.trim();
          equipment.category = category;
        }
      });
    }

    nameCtrl.dispose();
    quantityCtrl.dispose();
    unitCtrl.dispose();
    noteCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final equipment = widget.project.customEquipment;
    return Scaffold(
      appBar: AppBar(title: const Text('อินเวอร์เตอร์และอุปกรณ์')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openEquipmentDialog,
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มเครื่องเอง'),
      ),
      body: equipment.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const GradientIconBadge(
                        icon: Icons.inventory_2_outlined,
                        color: PVForgeColors.warning,
                        size: 72),
                    const SizedBox(height: 16),
                    const Text('ยังไม่มีอินเวอร์เตอร์หรืออุปกรณ์เพิ่มเติม'),
                    const SizedBox(height: 6),
                    const Text(
                      'เพิ่มอินเวอร์เตอร์รุ่นที่กำหนดเอง หรืออุปกรณ์ เช่น EV Charger, ตู้ ATS และมิเตอร์',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: equipment.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = equipment[index];
                return Card(
                  child: ListTile(
                    leading: const GradientIconBadge(
                        icon: Icons.electrical_services,
                        color: PVForgeColors.warning),
                    title: Text(item.name),
                    subtitle: Text(
                      '${item.category}\n${item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 1)} '
                      '${item.unit}${item.note.isEmpty ? '' : '\n${item.note}'}',
                    ),
                    isThreeLine: true,
                    onTap: () => _openEquipmentDialog(item),
                    trailing: IconButton(
                      tooltip: 'ลบ',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () =>
                          setState(() => equipment.removeAt(index)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
