part of 'teacher_bloc.dart';

@immutable
abstract class TeacherEvent {}

class LoadTeachers extends TeacherEvent {}

class DeleteTeacher extends TeacherEvent {
  final int id;

  DeleteTeacher(this.id);
}

class AddTeacher extends TeacherEvent {
  final String email;
  final String firstname;
  final String lastname;
  final String password;

  AddTeacher(this.email, this.firstname, this.lastname, this.password);
}

class UpdateTeacher extends TeacherEvent {
  final int id;
  final String email;
  final String firstname;
  final String lastname;

  UpdateTeacher(this.id, this.email, this.firstname, this.lastname);
}

class SearchTeachers extends TeacherEvent {
  final String query;

  SearchTeachers(this.query);
}