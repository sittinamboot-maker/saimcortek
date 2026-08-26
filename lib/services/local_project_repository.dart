import 'dart:convert';
import 'dart:io';

import '../models/solar_project.dart';
import 'project_repository.dart';

class LocalProjectRepository implements ProjectRepository {
  Future<File> _file() async {
    final base = Platform.environment['APPDATA'] ?? Directory.systemTemp.path;
    final directory =
        Directory('$base${Platform.pathSeparator}CORTek Solar Designer');
    if (!await directory.exists()) await directory.create(recursive: true);
    return File('${directory.path}${Platform.pathSeparator}projects.json');
  }

  @override
  Future<List<SolarProject>> loadAll() async {
    final file = await _file();
    if (!await file.exists()) return [];
    try {
      final raw = await file.readAsString();
      if (raw.isEmpty) return [];
      final items = jsonDecode(raw) as List;
      final projects = items
          .map(
              (e) => SolarProject.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return projects;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> save(SolarProject project) async {
    final projects = await loadAll();
    project.updatedAt = DateTime.now();
    final index = projects.indexWhere((item) => item.id == project.id);
    if (index < 0) {
      projects.insert(0, project);
    } else {
      projects[index] = project;
    }
    final file = await _file();
    await file.writeAsString(
        jsonEncode(projects.map((e) => e.toJson()).toList()),
        flush: true);
  }

  @override
  Future<void> delete(String projectId) async {
    final projects = await loadAll()
      ..removeWhere((item) => item.id == projectId);
    final file = await _file();
    await file.writeAsString(
        jsonEncode(projects.map((e) => e.toJson()).toList()),
        flush: true);
  }

  @override
  Future<void> sync() async {
    // Local repository has nothing to sync. A Firebase implementation can
    // upload/download using the same ProjectRepository contract later.
  }
}
