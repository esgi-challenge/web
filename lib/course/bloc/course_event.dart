part of 'course_bloc.dart';

@immutable
abstract class CourseEvent {}

class LoadCourses extends CourseEvent {}

class DeleteCourse extends CourseEvent {
  final int id;

  DeleteCourse(this.id);
}

class AddCourse extends CourseEvent {
  final String name;
  final String description;
  final int pathId;
  final int teacherId;

  AddCourse(this.name, this.description, this.pathId, this.teacherId);
}

class UpdateCourse extends CourseEvent {
  final int id;
  final String name;
  final String description;
  final int pathId;
  final int teacherId;

  UpdateCourse(this.id, this.name, this.description, this.pathId, this.teacherId);
}