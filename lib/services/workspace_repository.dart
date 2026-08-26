import '../models/saas_workspace.dart';

abstract interface class WorkspaceRepository {
  Future<CompanyWorkspace> loadCurrent();
  Future<void> save(CompanyWorkspace workspace);
  Future<void> inviteMember({
    required CompanyWorkspace workspace,
    required String email,
    required CompanyRole role,
  });
}
