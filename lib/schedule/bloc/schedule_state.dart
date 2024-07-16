part of 'schedule_bloc.dart';

@immutable
abstract class ScheduleState {}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleCode extends ScheduleState {
  final String code;

  ScheduleCode({required this.code});
}

class ScheduleLoaded extends ScheduleState {
  final List<dynamic> schedules;
  final List<dynamic> courses;
  final List<dynamic> campuses;
  final List<dynamic> classes;

  ScheduleLoaded(
      {required this.schedules,
      required this.courses,
      required this.campuses,
      required this.classes});
}

class ScheduleNotFound extends ScheduleState {
  final List<dynamic> courses;
  final List<dynamic> campuses;
  final List<dynamic> classes;

  ScheduleNotFound(
      {required this.courses, required this.campuses, required this.classes});
}

class ScheduleError extends ScheduleState {
  final String errorMessage;

  ScheduleError({required this.errorMessage});
}
