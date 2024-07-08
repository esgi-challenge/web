part of 'class_bloc.dart';

@immutable
abstract class ClassState {}

class ClassInitial extends ClassState {}

class ClassLoading extends ClassState {}

class ClassLoaded extends ClassState {
  final List<dynamic> classes;
  final List<dynamic> paths;

  ClassLoaded({required this.classes, required this.paths});
}

class ClassNotFound extends ClassState {
  final List<dynamic> paths;

  ClassNotFound({required this.paths});
}

class ClassError extends ClassState {
  final String errorMessage;

  ClassError({required this.errorMessage});
}