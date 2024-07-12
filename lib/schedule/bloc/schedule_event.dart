part of 'schedule_bloc.dart';

@immutable
abstract class ScheduleEvent {}

class LoadSchedules extends ScheduleEvent {}

class DeleteSchedule extends ScheduleEvent {
  final int id;

  DeleteSchedule(this.id);
}

class AddSchedule extends ScheduleEvent {
  final int time;
  final int duration;
  final int courseId;
  final int campusId;
  final int classId;

  AddSchedule(this.time, this.duration, this.courseId, this.campusId, this.classId);
}

class UpdateSchedule extends ScheduleEvent {
  final int id;
  final int time;
  final int duration;
  final int courseId;
  final int campusId;
  final int classId;

  UpdateSchedule(this.id, this.time, this.duration, this.courseId, this.campusId, this.classId);
}