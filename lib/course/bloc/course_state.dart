part of 'course_bloc.dart';

@immutable
abstract class CourseState {}

class CourseInitial extends CourseState {}

class CourseLoading extends CourseState {}

class CourseLoaded extends CourseState {
  final List<dynamic> courses;
  final List<dynamic> teachers;
  final List<dynamic> paths;

  CourseLoaded({required this.courses, required this.teachers, required this.paths});
}

class CourseNotFound extends CourseState {
  final List<dynamic> teachers;
  final List<dynamic> paths;

  CourseNotFound({required this.teachers, required this.paths});
}

class CourseError extends CourseState {
  final String errorMessage;

  CourseError({required this.errorMessage});
}