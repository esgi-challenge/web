part of 'student_bloc.dart';

@immutable
abstract class StudentEvent {}

class LoadStudents extends StudentEvent {}

class SearchStudents extends StudentEvent {
  final String query;

  SearchStudents(this.query);
}