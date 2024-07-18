part of 'project_bloc.dart';

@immutable
abstract class ProjectEvent {}

class LoadProjects extends ProjectEvent {}

class DeleteProject extends ProjectEvent {
  final int id;

  DeleteProject(this.id);
}

class AddProject extends ProjectEvent {
  final String title;
  final double endDate;
  final int courseId;
  final int classId;
  final int documentId;

  AddProject(
      this.title, this.endDate, this.courseId, this.classId, this.documentId);
}

class UpdateProject extends ProjectEvent {
  final int id;
  final String title;
  final double endDate;
  final int courseId;
  final int classId;
  final int documentId;

  UpdateProject(this.id, this.title, this.endDate, this.courseId, this.classId,
      this.documentId);
}
