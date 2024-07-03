part of 'student_bloc.dart';

@immutable
abstract class StudentEvent {}

class LoadStudents extends StudentEvent {}

class DeleteStudent extends StudentEvent {
  final int id;

  DeleteStudent(this.id);
}

class AddStudent extends StudentEvent {
  final String email;
  final String firstname;
  final String lastname;
  final String password;

  AddStudent(this.email, this.firstname, this.lastname, this.password);
}

class UpdateStudent extends StudentEvent {
  final int id;
  final String email;
  final String firstname;
  final String lastname;

  UpdateStudent(this.id, this.email, this.firstname, this.lastname);
}

class SearchStudents extends StudentEvent {
  final String query;

  SearchStudents(this.query);
}