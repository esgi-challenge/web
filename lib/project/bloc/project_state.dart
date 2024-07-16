part of 'project_bloc.dart';

@immutable
abstract class ProjectState {}

class ProjectInitial extends ProjectState {}

class ProjectLoading extends ProjectState {}

class ProjectLoaded extends ProjectState {
  final List<dynamic> projects;
  final List<dynamic> courses;
  final List<dynamic> classes;
  final List<dynamic> documents;

  ProjectLoaded({required this.projects, required this.courses, required this.classes, required this.documents});
}

class ProjectNotFound extends ProjectState {
  final List<dynamic> courses;
  final List<dynamic> classes;
  final List<dynamic> documents;

  ProjectNotFound({required this.courses, required this.classes, required this.documents});
}

class ProjectError extends ProjectState {
  final String errorMessage;

  ProjectError({required this.errorMessage});
}