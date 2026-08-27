import 'package:flutter/material.dart';
import '../models/solar_project.dart';
import '../services/local_project_repository.dart';
import '../widgets/pvforge_components.dart';

class EfficiencyLossScreen extends StatefulWidget {
  final SolarProject project;
  const EfficiencyLossScreen({super.key, required this.project});

  @override
  State<EfficiencyLossScreen> createState() => _EfficiencyLossScreenState();
}

class _EfficiencyLossScreenState extends State<EfficiencyLossScreen> {
  late final Map<String, TextEditingController> c;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    c = {
      'panelEfficiency':
          TextEditingController(text: p.panelEfficiency.toString()),
      'tempCoeffVoc':
          TextEditingController(text: p.panelTempCoeffVoc.toString()),
      'degradation': TextEditingController(text: p.panelDegradation.toString()),
      'inverterEfficiency':
          TextEditingController(text: p.inverterEfficiency.toString()),
      'mpptEfficiency':
          TextEditingController(text: p.mpptEfficiency.toString()),
      'temperatureLoss':
          TextEditingController(text: p.temperatureLoss.toString()),
      'soilingLoss': TextEditingController(text: p.soilingLoss.toString()),
      'dcCableLoss': TextEditingController(text: p.dcCableLoss.toString()),
      'acCableLoss': TextEditingController(text: p.acCableLoss.toString()),
      'mismatchLoss': TextEditingController(text: p.mismatchLoss.toString()),
      'shadingLoss': TextEditingController(text: p.shadingLoss.toString()),
      'otherLoss': TextEditingController(text: p.otherLoss.toString()),
    };
  }

  double _v(String key, double fallback) =>
      double.tryParse(c[key]!.text) ?? fallback;

  // อัปเดตค่าลง object ของโปรเจกต์ในหน่วยความจำเฉย ๆ เพื่อให้ผลรวมระบบ
  // ด้านล่าง (System Efficiency / พลังงานที่คาดการณ์ ฯลฯ) รีเฟรชสด ๆ ทันทีที่
  // พิมพ์ — ยังไม่ได้บันทึกลงไฟล์ ต้องกดปุ่ม "บันทึกและคำนวณใหม่" ก่อน
  void _applyFields() {
    final p = widget.project;
    p.panelEfficiency = _v('panelEfficiency', p.panelEfficiency);
    p.panelTempCoeffVoc = _v('tempCoeffVoc', p.panelTempCoeffVoc);
    p.panelDegradation = _v('degradation', p.panelDegradation);
    p.inverterEfficiency = _v('inverterEfficiency', p.inverterEfficiency);
    p.mpptEfficiency = _v('mpptEfficiency', p.mpptEfficiency);
    p.temperatureLoss = _v('temperatureLoss', p.temperatureLoss);
    p.soilingLoss = _v('soilingLoss', p.soilingLoss);
    p.dcCableLoss = _v('dcCableLoss', p.dcCableLoss);
    p.acCableLoss = _v('acCableLoss', p.acCableLoss);
    p.mismatchLoss = _v('mismatchLoss', p.mismatchLoss);
    p.shadingLoss = _v('shadingLoss', p.shadingLoss);
    p.otherLoss = _v('otherLoss', p.otherLoss);
    setState(() {});
  }

  // กดปุ่ม "บันทึกและคำนวณใหม่" ถึงจะเขียนค่าลงไฟล์โปรเจกต์จริง ๆ (เดิมปุ่มนี้
  // เขียนว่า "บันทึก" แต่ไม่เคยเรียก repository เลย แก้ไขให้บันทึกจริงตามชื่อปุ่ม)
  Future<void> _save() async {
    _applyFields();
    await LocalProjectRepository().save(widget.project);
    if (!mounted) return;
    showAppBanner(context, 'บันทึกค่าประสิทธิภาพเรียบร้อย');
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    return Scaffold(
      appBar: AppBar(title: const Text('Efficiency & Losses')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
        children: [
          _section('ประสิทธิภาพแผง', [
            _field('Panel Efficiency', 'panelEfficiency', '%'),
            _field('Temperature Coefficient Voc', 'tempCoeffVoc', '%/°C'),
            _field('Degradation / Year', 'degradation', '%/year'),
          ]),
          const SizedBox(height: 12),
          _section('ประสิทธิภาพ Inverter', [
            _field('Inverter Efficiency', 'inverterEfficiency', '%'),
            _field('MPPT Efficiency', 'mpptEfficiency', '%'),
          ]),
          const SizedBox(height: 12),
          _section('System Losses', [
            _field('Temperature Loss', 'temperatureLoss', '%'),
            _field('Soiling / Dust', 'soilingLoss', '%'),
            _field('DC Cable Loss', 'dcCableLoss', '%'),
            _field('AC Cable Loss', 'acCableLoss', '%'),
            _field('Mismatch Loss', 'mismatchLoss', '%'),
            _field('Shading Loss', 'shadingLoss', '%'),
            _field('Other Loss', 'otherLoss', '%'),
          ]),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('บันทึกและคำนวณใหม่'),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ผลรวมระบบ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  _result('System Efficiency',
                      '${(p.systemEfficiency * 100).toStringAsFixed(1)}%'),
                  _result('Total System Loss',
                      '${p.totalSystemLoss.toStringAsFixed(1)}%'),
                  _result('Estimated Energy',
                      '${p.estimatedDailyProduction.toStringAsFixed(1)} kWh/day'),
                  _result('Estimated Monthly',
                      '${p.estimatedMonthlyProduction.toStringAsFixed(0)} kWh/month'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'หมายเหตุ: Panel Efficiency ใช้ประกอบข้อมูลด้านพื้นที่และประสิทธิภาพของแผง ไม่ถูกหักซ้ำจากค่า Wp ของแผง',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      );

  Widget _field(String label, String key, String suffix) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: c[key],
          keyboardType: const TextInputType.numberWithOptions(
              decimal: true, signed: true),
          decoration: InputDecoration(labelText: label, suffixText: suffix),
          onChanged: (_) => _applyFields(),
        ),
      );

  Widget _result(String a, String b) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(a),
            Text(b, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
}
