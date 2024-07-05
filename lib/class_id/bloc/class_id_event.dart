part of 'class_id_bloc.dart';

@immutable
abstract class ClassIdEvent {}

class LoadClassId extends ClassIdEvent {
  final int id;

  LoadClassId(this.id);
}

class RemoveStudent extends ClassIdEvent {
  final int id;

  RemoveStudent(this.id);
}

class AddStudent extends ClassIdEvent {
  final int id;

  AddStudent(this.id);
}

class SearchStudents extends ClassIdEvent {
  final String query;

  SearchStudents(this.query);
}