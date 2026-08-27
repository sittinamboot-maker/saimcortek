import 'package:flutter/material.dart';

import '../models/solar_project.dart';
import '../services/local_project_repository.dart';
import '../theme/pvforge_theme.dart';
import '../widgets/pvforge_components.dart';
import 'empty_projects_screen.dart';
import 'project_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});
  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final repository = LocalProjectRepository();
  List<SolarProject> projects = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await repository.loadAll();
    if (!mounted) return;
    setState(() {
      projects = loaded;
      loading = false;
    });
  }

  Future<void> _deleteProject(SolarProject project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบโปรเจกต์?'),
        content: Text(
          'ต้องการลบโปรเจกต์ของ ${project.customerName.isEmpty ? 'ลูกค้ารายนี้' : project.customerName} ใช่หรือไม่? การลบไม่สามารถย้อนกลับได้',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบโปรเจกต์'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await repository.delete(project.id);
    await _load();
    if (!mounted) return;
    showAppBanner(context, 'ลบโปรเจกต์แล้ว');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('โปรเจกต์ของฉัน')),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : projects.isEmpty
                ? EmptyProjectsView(
                    onCreate: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                ProjectScreen(project: SolarProject())),
                      );
                      await _load();
                    },
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
                    itemCount: projects.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 9),
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      return Card(
                          child: ListTile(
                        leading: const GradientIconBadge(
                            icon: Icons.person_outline,
                            color: PVForgeColors.primary),
                        title: Text(
                            project.customerName.isEmpty
                                ? 'ไม่ระบุชื่อลูกค้า'
                                : project.customerName,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'ลบโปรเจกต์',
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () => _deleteProject(project),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      ProjectScreen(project: project)));
                          await _load();
                        },
                      ));
                    },
                  ),
      );
}
