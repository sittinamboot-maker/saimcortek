import '../models/solar_project.dart';

/// Contract shared by local storage and a future Firebase/Cloud implementation.
abstract interface class ProjectRepository {
  Future<List<SolarProject>> loadAll();
  Future<void> save(SolarProject project);
  Future<void> delete(String projectId);
  Future<void> sync();
}
