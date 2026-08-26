import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/solar_project.dart';
import '../theme/pvforge_theme.dart';
import 'pvforge_components.dart';

class EnergyFlowCard extends StatefulWidget {
  final SolarProject project;
  const EnergyFlowCard({super.key, required this.project});
  @override
  State<EnergyFlowCard> createState() => _EnergyFlowCardState();
}

class _EnergyFlowCardState extends State<EnergyFlowCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1700))
      ..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final pv = p.systemKwp * p.systemEfficiency;
    final load = math.max(.3, p.dailyKwh / 8);
    final inverter = pv * p.inverterEfficiency / 100;
    final batteryPower = p.hasBattery
        ? math.min(1.5, math.max(0, inverter - load)).toDouble()
        : 0.0;
    final grid = inverter - load - batteryPower;
    final soc = p.hasBattery
        ? math.max(0, math.min(100, p.estimatedNightCoveragePercent)).toDouble()
        : 0.0;
    return PVForgeCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader('Energy Flow', trailing: RealtimeIndicator()),
        const SizedBox(height: 12),
        AspectRatio(
            aspectRatio: 1.42,
            child: LayoutBuilder(builder: (context, box) {
              return Stack(children: [
                Positioned.fill(
                    child: AnimatedBuilder(
                        animation: controller,
                        builder: (_, __) => CustomPaint(
                            painter: _FlowPainter(controller.value,
                                pvActive: pv > 0,
                                batteryActive: batteryPower > 0,
                                gridActive: grid.abs() > .01)))),
                _node(
                    box,
                    .5,
                    .08,
                    Icons.solar_power,
                    'PV ARRAY',
                    pv,
                    'kW',
                    PVForgeColors.solar,
                    () => _details('PV Detail', [
                          ('PV Power', '${pv.toStringAsFixed(2)} kW'),
                          ('Voc', '${p.panelVoc.toStringAsFixed(1)} V'),
                          ('Vmp', '${p.panelVmp.toStringAsFixed(1)} V'),
                          (
                            'PV Performance',
                            '${(p.systemEfficiency * 100).toStringAsFixed(1)}%'
                          )
                        ])),
                _node(
                    box,
                    .5,
                    .43,
                    Icons.electrical_services,
                    'INVERTER',
                    inverter,
                    'kW',
                    PVForgeColors.primary,
                    () => _details('Inverter Detail', [
                          ('DC Input', '${pv.toStringAsFixed(2)} kW'),
                          ('AC Output', '${inverter.toStringAsFixed(2)} kW'),
                          (
                            'Efficiency',
                            '${p.inverterEfficiency.toStringAsFixed(1)}%'
                          ),
                          (
                            'System Loss',
                            '${p.totalSystemLoss.toStringAsFixed(1)}%'
                          )
                        ])),
                _node(
                    box,
                    .5,
                    .78,
                    Icons.home_outlined,
                    'LOAD',
                    load,
                    'kW',
                    PVForgeColors.load,
                    () => _details('Load Detail', [
                          (
                            'Current Consumption',
                            '${load.toStringAsFixed(2)} kW'
                          ),
                          (
                            'Energy Today',
                            '${p.dailyKwh.toStringAsFixed(1)} kWh'
                          )
                        ])),
                _node(
                    box,
                    .13,
                    .65,
                    Icons.battery_charging_full,
                    'BATTERY',
                    soc,
                    '%',
                    _socColor(soc),
                    () => _details('Battery Detail', [
                          ('SOC', '${soc.toStringAsFixed(0)}%'),
                          ('Power', '${batteryPower.toStringAsFixed(2)} kW'),
                          (
                            'Capacity',
                            '${p.batteryCapacityKwh.toStringAsFixed(1)} kWh'
                          )
                        ])),
                _node(
                    box,
                    .87,
                    .65,
                    Icons.power,
                    'GRID',
                    grid.abs(),
                    'kW',
                    PVForgeColors.grid,
                    () => _details('Grid Detail', [
                          (
                            grid >= 0 ? 'Export Power' : 'Import Power',
                            '${grid.abs().toStringAsFixed(2)} kW'
                          )
                        ])),
              ]);
            })),
      ]),
    );
  }

  Color _socColor(double soc) => soc < 15
      ? PVForgeColors.critical
      : soc <= 30
          ? PVForgeColors.warning
          : PVForgeColors.battery;

  Widget _node(
      BoxConstraints box,
      double x,
      double y,
      IconData icon,
      String label,
      double value,
      String unit,
      Color color,
      VoidCallback onTap) {
    const width = 82.0, height = 64.0;
    return Positioned(
      left: box.maxWidth * x - width / 2,
      top: box.maxHeight * y,
      width: width,
      height: height,
      child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: .45)),
                  boxShadow: [
                    BoxShadow(
                        color: color.withValues(alpha: .13), blurRadius: 12)
                  ]),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 17, color: color),
                    Text(label,
                        style: const TextStyle(
                            fontSize: 8, fontWeight: FontWeight.w700)),
                    Text('${value.toStringAsFixed(value >= 10 ? 0 : 2)} $unit',
                        style: TextStyle(
                            fontSize: 11,
                            color: color,
                            fontWeight: FontWeight.w800)),
                  ]))),
    );
  }

  void _details(String title, List<(String, String)> rows) {
    showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      for (final row in rows)
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(row.$1),
                                  Text(row.$2,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700))
                                ])),
                    ]))));
  }
}

class _FlowPainter extends CustomPainter {
  final double progress;
  final bool pvActive, batteryActive, gridActive;
  _FlowPainter(this.progress,
      {required this.pvActive,
      required this.batteryActive,
      required this.gridActive});
  @override
  void paint(Canvas canvas, Size size) {
    final paths = <(Offset, Offset, Color, bool)>[
      (
        Offset(size.width * .5, size.height * .29),
        Offset(size.width * .5, size.height * .43),
        PVForgeColors.solar,
        pvActive
      ),
      (
        Offset(size.width * .5, size.height * .66),
        Offset(size.width * .5, size.height * .78),
        PVForgeColors.load,
        pvActive
      ),
      (
        Offset(size.width * .43, size.height * .62),
        Offset(size.width * .22, size.height * .68),
        PVForgeColors.battery,
        batteryActive
      ),
      (
        Offset(size.width * .57, size.height * .62),
        Offset(size.width * .78, size.height * .68),
        PVForgeColors.grid,
        gridActive
      ),
    ];
    for (final item in paths) {
      final paint = Paint()
        ..color =
            item.$4 ? item.$3.withValues(alpha: .45) : PVForgeColors.divider
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(item.$1, item.$2, paint);
      if (!item.$4) continue;
      for (var i = 0; i < 3; i++) {
        final t = (progress + i / 3) % 1;
        canvas.drawCircle(
            Offset.lerp(item.$1, item.$2, t)!, 3, Paint()..color = item.$3);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FlowPainter oldDelegate) => true;
}
