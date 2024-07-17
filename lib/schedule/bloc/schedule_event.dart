part of 'schedule_bloc.dart';

@immutable
abstract class ScheduleEvent {}

class LoadSchedules extends ScheduleEvent {}

class DeleteSchedule extends ScheduleEvent {
  final int id;

  DeleteSchedule(this.id);
}

class LoadSchedule extends ScheduleEvent {
  final int id;

  LoadSchedule(this.id);
}

class LoadScheduleCode extends ScheduleEvent {
  final int id;

  LoadScheduleCode(this.id);
}

class SignSchedule extends ScheduleEvent {
  final int scheduleId;
  final int studentId;
  final String code;

  SignSchedule(
      {required this.scheduleId, required this.studentId, required this.code});
}

class AddSchedule extends ScheduleEvent {
  final int time;
  final int duration;
  final int courseId;
  final int campusId;
  final int classId;
  final bool qrCodeEnabled;

  AddSchedule(
      this.time, this.duration, this.courseId, this.campusId, this.classId, this.qrCodeEnabled);
}

class UpdateSchedule extends ScheduleEvent {
  final int id;
  final int time;
  final int duration;
  final int courseId;
  final int campusId;
  final int classId;
  final bool qrCodeEnabled;

  UpdateSchedule(this.id, this.time, this.duration, this.courseId,
      this.campusId, this.classId, this.qrCodeEnabled);
}
