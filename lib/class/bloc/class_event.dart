part of 'class_bloc.dart';

@immutable
abstract class ClassEvent {}

class LoadClasses extends ClassEvent {}

class DeleteClass extends ClassEvent {
  final int id;

  DeleteClass(this.id);
}

class AddClass extends ClassEvent {
  final String name;
  final int pathId;

  AddClass(this.name, this.pathId);
}

class UpdateClass extends ClassEvent {
  final int id;
  final String name;
  final int pathId;

  UpdateClass(this.id, this.name, this.pathId);
}