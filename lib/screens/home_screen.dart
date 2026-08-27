import 'package:flutter/material.dart';

import '../models/solar_project.dart';
import '../services/local_project_repository.dart';
import '../theme/pvforge_theme.dart';
import '../widgets/pvforge_components.dart';
import 'boost_mppt_selection_screen.dart';
import 'equipment_screen.dart';
import 'project_screen.dart';
import 'projects_screen.dart';
import 'string_checker_screen.dart';
import 'summary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<SolarProject> projects = [];
  SolarProject get latest => projects.isEmpty ? SolarProject() : projects.first;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final loaded = await LocalProjectRepository().loadAll();
      if (mounted) setState(() => projects = loaded);
    } catch (_) {}
  }

  Future<void> _open(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    await _load();
  }

  Widget _stringOrBoostScreen(SolarProject p) =>
      p.isAirSolarSystem ? BoostMpptSelectionScreen(project: p) : StringCheckerScreen(project: p);

  // เดิมหน้านี้มีพื้นหลังรูปภาพ + ไล่สีของตัวเองซ้อนอยู่ในหน้านี้อีกชั้น
  // (นอกเหนือจากพื้นหลังไล่สีขาวไปฟ้าที่ตั้งไว้ระดับแอปใน main.dart) — เอาออก
  // ให้ใช้พื้นหลังเดียวจาก main.dart ทั้งแอป จะได้ไม่ซ้อนกันและโหลดเร็วขึ้น
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: _load,
            child: LayoutBuilder(builder: (context, constraints) {
              final compact = constraints.maxHeight < 800;
              final width = constraints.maxWidth >= 800
                  ? 760.0
                  : constraints.maxWidth;
              return ListView(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                Center(
                    child: SizedBox(
                        width: width,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _hero(height: compact ? 145 : 275),
                              Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 0, 16, 28),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _createProjectBanner(
                                            compact: compact),
                                        SizedBox(height: compact ? 12 : 20),
                                        SectionHeader('โปรเจกต์ล่าสุด',
                                            trailing: TextButton(
                                                onPressed: () => _open(
                                                    const ProjectsScreen()),
                                                child: const Text(
                                                    'ดูทั้งหมด  ›'))),
                                        SizedBox(height: compact ? 6 : 9),
                                        _latestProject(compact: compact),
                                      ])),
                            ]))),
              ]);
            }),
          )),
      );

  Widget _hero({required double height}) => SizedBox(
      height: height,
      child: Stack(children: [
        Positioned.fill(
          child: Image.asset(
            'assets/branding/pvforge_home_solar_hero.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            filterQuality: FilterQuality.high,
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white.withValues(alpha: .72),
                  Colors.white.withValues(alpha: .22),
                  Colors.transparent,
                ],
                stops: const [0, .55, 1],
              ),
            ),
          ),
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(22, height < 200 ? 8 : 18, 22,
                height < 200 ? 8 : 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Image.asset(
                  'assets/branding/pvforge_hero_logo.png',
                  width: height < 200 ? 105 : 145,
                  height: height < 200 ? 46 : 70,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                  filterQuality: FilterQuality.high,
                ),
                const Spacer(),
                Stack(children: [
                  Icon(Icons.notifications_none_rounded,
                      size: height < 200 ? 24 : 29),
                  Positioned(
                      right: 1,
                      top: 1,
                      child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                              color: PVForgeColors.critical,
                              shape: BoxShape.circle))),
                ]),
              ]),
              const Spacer(),
              Text(
                  'สวัสดี, ${latest.customerName.isEmpty ? 'ผู้ใช้งาน' : latest.customerName} 👋',
                  style: TextStyle(
                      fontSize: height < 200 ? 20 : 27,
                      fontWeight: FontWeight.w800)),
              SizedBox(height: height < 200 ? 2 : 5),
              Text('พร้อมออกแบบระบบโซลาร์เซลล์',
                  style: TextStyle(
                      fontSize: height < 200 ? 12 : 15,
                      color: PVForgeColors.secondaryText)),
              SizedBox(height: height < 200 ? 2 : 8),
            ])),
      ]));

  Widget _createProjectBanner({required bool compact}) => InkWell(
        onTap: () => _open(ProjectScreen(project: SolarProject())),
        borderRadius: BorderRadius.circular(22),
        child: Container(
            height: compact ? 100 : 118,
            padding: EdgeInsets.all(compact ? 14 : 18),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                    colors: [Color(0xFF1269ED), Color(0xFF4C91FF)]),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x443478F6),
                      blurRadius: 20,
                      offset: Offset(0, 8))
                ]),
            child: Row(children: [
              Container(
                  width: compact ? 56 : 66,
                  height: compact ? 56 : 66,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: Icon(Icons.add,
                      color: PVForgeColors.primary, size: compact ? 32 : 38)),
              SizedBox(width: compact ? 12 : 17),
              Expanded(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('สร้างโปรเจกต์ใหม่',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: compact ? 17 : 20,
                            fontWeight: FontWeight.w800)),
                    SizedBox(height: 3),
                    Text('เริ่มออกแบบระบบโซลาร์เซลล์ของคุณ',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ])),
              Container(
                  width: compact ? 34 : 40,
                  height: compact ? 34 : 40,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.chevron_right,
                      color: PVForgeColors.primary)),
            ])),
      );

  Widget _latestProject({required bool compact}) {
    if (projects.isEmpty) {
      return PVForgeCard(
          backgroundColor: Colors.white.withValues(alpha: .42),
          child: SizedBox(
              height: compact ? 72 : 95,
              child: Center(
                  child: Text('ยังไม่มีโปรเจกต์ที่บันทึก',
                      style: TextStyle(color: Colors.grey.shade600)))));
    }
    final p = latest;
    return InkWell(
        onTap: () => _open(ProjectScreen(project: p)),
        borderRadius: BorderRadius.circular(22),
        child: PVForgeCard(
            padding: EdgeInsets.all(compact ? 9 : 12),
            backgroundColor: Colors.white.withValues(alpha: .42),
            child: Row(children: [
              Container(
                  width: compact ? 68 : 92,
                  height: compact ? 62 : 86,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                          colors: [Color(0xFFD8EBFF), Color(0xFF8BC2FF)])),
                  child: Icon(Icons.home_work_outlined,
                      color: Colors.white, size: compact ? 34 : 46)),
              SizedBox(width: compact ? 9 : 13),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                        p.projectName.isNotEmpty
                            ? p.projectName
                            : p.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: compact ? 14 : 17,
                            fontWeight: FontWeight.w800)),
                    SizedBox(height: compact ? 4 : 9),
                    Wrap(spacing: 9, runSpacing: 4, children: [
                      Text('⚡ ${p.systemKwp.toStringAsFixed(2)} kWp'),
                      Text('▦ ${p.recommendedPanels} แผง'),
                      Text(
                          '▣ ${p.inverterKw.toStringAsFixed(0)} อินเวอร์เตอร์'),
                    ]),
                    if (!compact) ...[
                      const SizedBox(height: 8),
                      const Text('แก้ไขล่าสุดเมื่อไม่นานนี้',
                          style: TextStyle(
                              fontSize: 10,
                              color: PVForgeColors.secondaryText)),
                    ],
                  ])),
              const Icon(Icons.chevron_right),
            ])));
  }

  Widget _continueCard() => PVForgeCard(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Container(
            width: 82,
            height: 78,
            decoration: BoxDecoration(
                color: const Color(0xFFE5F2FF),
                borderRadius: BorderRadius.circular(16)),
            child: const Center(
                child: Text('✓',
                    style: TextStyle(
                        color: PVForgeColors.primary,
                        fontSize: 38,
                        fontWeight: FontWeight.w900)))),
        const SizedBox(width: 13),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('ออกแบบ String / MPPT ยังไม่เสร็จ',
              style: TextStyle(fontWeight: FontWeight.w800)),
          Text(
              'โปรเจกต์: ${latest.projectName.isEmpty ? latest.customerName : latest.projectName}',
              style:
                  const TextStyle(fontSize: 11, color: PVForgeColors.primary)),
          const Text('เหลือขั้นตอนตรวจสอบระบบ',
              style:
                  TextStyle(fontSize: 10, color: PVForgeColors.secondaryText)),
        ])),
        FilledButton(
            onPressed: () => _open(_stringOrBoostScreen(latest)),
            child: const Text('ทำต่อ  ›')),
      ]));

  Widget _tools() {
    final tools = [
      (
        Icons.calculate_outlined,
        'คำนวณขนาดระบบ',
        () => _open(ProjectScreen(project: SolarProject()))
      ),
      (
        Icons.cable,
        'String / MPPT',
        () => _open(_stringOrBoostScreen(latest))
      ),
      (Icons.inventory_2_outlined, 'อุปกรณ์',
          () => _open(EquipmentScreen(project: latest))),
      (Icons.description_outlined, 'รายงาน / BOQ',
          () => _open(SummaryScreen(project: latest))),
      (Icons.help_outline, 'คู่มือ & เคล็ดลับ', () {}),
    ];
    return SizedBox(
        height: 105,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: tools.length,
          separatorBuilder: (_, __) => const SizedBox(width: 9),
          itemBuilder: (_, i) {
            final item = tools[i];
            return SizedBox(
                width: 112,
                child: InkWell(
                    onTap: item.$3,
                    borderRadius: BorderRadius.circular(18),
                    child: PVForgeCard(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFEAF3FF),
                                      borderRadius: BorderRadius.circular(12)),
                                  alignment: Alignment.center,
                                  child: Icon(item.$1,
                                      color: PVForgeColors.primary, size: 22)),
                              const SizedBox(height: 7),
                              Text(item.$2,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600)),
                            ]))));
          },
        ));
  }
}
