part of 'student_bloc.dart';

@immutable
abstract class StudentState {}

class StudentInitial extends StudentState {}

class StudentLoading extends StudentState {}

class StudentLoaded extends StudentState {
  final List<dynamic> students;
  final List<dynamic> classes;

  StudentLoaded({required this.students, required this.classes});
}

class StudentNotFound extends StudentState {}

class StudentError extends StudentState {
  final String errorMessage;

  StudentError({required this.errorMessage});
}