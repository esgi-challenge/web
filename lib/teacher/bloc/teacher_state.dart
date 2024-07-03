part of 'teacher_bloc.dart';

@immutable
abstract class TeacherState {}

class TeacherInitial extends TeacherState {}

class TeacherLoading extends TeacherState {}

class TeacherLoaded extends TeacherState {
  final List<dynamic> teachers;

  TeacherLoaded({required this.teachers});
}

class TeacherNotFound extends TeacherState {}

class TeacherError extends TeacherState {
  final String errorMessage;

  TeacherError({required this.errorMessage});
}