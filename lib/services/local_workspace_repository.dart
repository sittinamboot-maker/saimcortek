import 'dart:convert';
import 'dart:io';

import '../models/saas_workspace.dart';
import 'workspace_repository.dart';

class LocalWorkspaceRepository implements WorkspaceRepository {
  Future<File> _file() async {
    final base = Platform.environment['APPDATA'] ?? Directory.systemTemp.path;
    final directory =
        Directory('$base${Platform.pathSeparator}CORTek Solar Designer');
    if (!await directory.exists()) await directory.create(recursive: true);
    return File('${directory.path}${Platform.pathSeparator}workspace.json');
  }

  CompanyWorkspace _defaultWorkspace() => CompanyWorkspace(
        id: 'local-company',
        name: 'บริษัท Solar ของฉัน',
        plan: SubscriptionPlan.free,
        trialEndsAt: DateTime.now().add(const Duration(days: 14)),
        members: [
          CompanyMember(
            id: 'local-owner',
            name: 'เจ้าของ Workspace',
            email: 'owner@company.local',
            role: CompanyRole.owner,
            status: MemberStatus.active,
          ),
        ],
      );

  @override
  Future<CompanyWorkspace> loadCurrent() async {
    final file = await _file();
    if (!await file.exists()) return _defaultWorkspace();
    try {
      return CompanyWorkspace.fromJson(
          Map<String, dynamic>.from(jsonDecode(await file.readAsString())));
    } catch (_) {
      return _defaultWorkspace();
    }
  }

  @override
  Future<void> save(CompanyWorkspace workspace) async {
    workspace.updatedAt = DateTime.now();
    final file = await _file();
    await file.writeAsString(jsonEncode(workspace.toJson()), flush: true);
  }

  @override
  Future<void> inviteMember({
    required CompanyWorkspace workspace,
    required String email,
    required CompanyRole role,
  }) async {
    if (workspace.members.length >= workspace.memberLimit) {
      throw StateError('แพ็กเกจ ${workspace.plan.label} สมาชิกเต็มแล้ว');
    }
    final normalized = email.trim().toLowerCase();
    if (workspace.members
        .any((item) => item.email.toLowerCase() == normalized)) {
      throw StateError('อีเมลนี้อยู่ใน Workspace แล้ว');
    }
    workspace.members.add(CompanyMember(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: normalized.split('@').first,
      email: normalized,
      role: role,
      status: MemberStatus.invited,
    ));
    await save(workspace);
  }
}
