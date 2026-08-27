import 'package:flutter/material.dart';

import '../models/saas_workspace.dart';
import '../services/local_workspace_repository.dart';
import '../theme/pvforge_theme.dart';
import '../widgets/pvforge_components.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key});
  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  final repository = LocalWorkspaceRepository();
  CompanyWorkspace? workspace;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await repository.loadCurrent();
    if (mounted) setState(() => workspace = loaded);
  }

  @override
  Widget build(BuildContext context) {
    final company = workspace;
    return Scaffold(
      appBar: AppBar(title: const Text('Company Workspace')),
      body: company == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
              children: [
                _companyCard(company),
                const SizedBox(height: 12),
                _subscriptionCard(company),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('สมาชิก',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                    Text('${company.members.length}/${company.memberLimit}'),
                  ],
                ),
                const SizedBox(height: 8),
                for (final member in company.members) _memberCard(member),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: company.members.length >= company.memberLimit
                      ? null
                      : () => _invite(company),
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 13),
                    child: Text('เชิญสมาชิก'),
                  ),
                ),
                if (company.members.length >= company.memberLimit) ...[
                  const SizedBox(height: 7),
                  Text(
                    'แพ็กเกจ ${company.plan.label} ใช้จำนวนสมาชิกครบแล้ว',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
    );
  }

  Widget _companyCard(CompanyWorkspace company) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const GradientIconBadge(
                icon: Icons.business,
                color: PVForgeColors.primary,
                size: 54,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(company.name,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w800)),
                    Text('Workspace ID: ${company.id}',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _editCompany(company),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
        ),
      );

  Widget _subscriptionCard(CompanyWorkspace company) {
    final trialDays = company.trialEndsAt?.difference(DateTime.now()).inDays;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _row('แพ็กเกจ', company.plan.label),
            _row('สถานะ', company.subscriptionStatus.label),
            if (trialDays != null && trialDays >= 0)
              _row('ทดลองใช้งานเหลือ', '$trialDays วัน'),
            const Divider(),
            SegmentedButton<SubscriptionPlan>(
              segments: SubscriptionPlan.values
                  .map((plan) =>
                      ButtonSegment(value: plan, label: Text(plan.label)))
                  .toList(),
              selected: {company.plan},
              onSelectionChanged: (selected) async {
                setState(() => company.plan = selected.first);
                await repository.save(company);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _memberCard(CompanyMember member) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: GradientIconBadge(
            text: member.name.isEmpty
                ? '?'
                : member.name.substring(0, 1).toUpperCase(),
            color: const Color(0xFF8B5CF6),
          ),
          title: Text(member.name,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('${member.email}\n${member.role.label}'),
          isThreeLine: true,
          trailing: Chip(label: Text(member.status.name.toUpperCase())),
        ),
      );

  Future<void> _invite(CompanyWorkspace company) async {
    final email = TextEditingController();
    var role = CompanyRole.designer;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('เชิญสมาชิก'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'อีเมล'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CompanyRole>(
                initialValue: role,
                decoration: const InputDecoration(labelText: 'บทบาท'),
                items: CompanyRole.values
                    .where((item) => item != CompanyRole.owner)
                    .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item.label)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setDialogState(() => role = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('ยกเลิก')),
            FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('ส่งคำเชิญ')),
          ],
        ),
      ),
    );
    if (result == true && email.text.contains('@')) {
      try {
        await repository.inviteMember(
            workspace: company, email: email.text, role: role);
        if (mounted) setState(() {});
      } on StateError catch (error) {
        if (mounted) {
          showAppBanner(context, error.message, error: true);
        }
      }
    }
    email.dispose();
  }

  Future<void> _editCompany(CompanyWorkspace company) async {
    final name = TextEditingController(text: company.name);
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('แก้ไขชื่อบริษัท'),
        content: TextField(
            controller: name,
            decoration: const InputDecoration(labelText: 'ชื่อบริษัท')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('ยกเลิก')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('บันทึก')),
        ],
      ),
    );
    if (saved == true && name.text.trim().isNotEmpty) {
      company.name = name.text.trim();
      await repository.save(company);
      if (mounted) setState(() {});
    }
    name.dispose();
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      );
}
