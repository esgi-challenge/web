part of 'class_id_bloc.dart';

@immutable
abstract class ClassIdState {}

class ClassIdInitial extends ClassIdState {}

class ClassIdLoading extends ClassIdState {}

class ClassIdLoaded extends ClassIdState {
  final dynamic classId;
  final dynamic classLessStudents;

  ClassIdLoaded({required this.classId, required this.classLessStudents});
}

class ClassIdNotFound extends ClassIdState {}

class ClassIdError extends ClassIdState {
  final String errorMessage;

  ClassIdError({required this.errorMessage});
}