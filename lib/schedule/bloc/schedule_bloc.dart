import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:web/core/services/campus_service.dart';
import 'package:web/core/services/class_service.dart';
import 'package:web/core/services/course_service.dart';
import 'package:web/core/services/schedule_service.dart';
import 'package:web/shared/toaster.dart';

part 'schedule_event.dart';
part 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final ScheduleService scheduleService;
  final CourseService courseService;
  final CampusService campusService;
  final ClassService classService;
  List<dynamic>? originalSchedules;
  List<dynamic>? originalCourses;
  List<dynamic>? originalCampuses;
  List<dynamic>? originalClasses;

  ScheduleBloc(this.scheduleService, this.courseService, this.campusService,
      this.classService)
      : super(ScheduleInitial()) {
    on<LoadSchedules>((event, emit) async {
      emit(ScheduleLoading());
      try {
        final schedules = await scheduleService.getSchedules();
        final courses = await courseService.getCourses();
        final campuses = await campusService.getCampus();
        final classes = await classService.getClasses();

        if (schedules != null && schedules.isNotEmpty) {
          originalSchedules = schedules;
          originalCourses = courses;
          originalCampuses = campuses;
          originalClasses = classes;
          emit(ScheduleLoaded(
              schedules: schedules,
              courses: courses!,
              campuses: campuses!,
              classes: classes!));
        } else if (courses != null &&
            courses.isNotEmpty &&
            campuses != null &&
            campuses.isNotEmpty &&
            classes != null &&
            classes.isNotEmpty) {
          originalCourses = courses;
          originalCampuses = campuses;
          originalClasses = classes;
          emit(ScheduleNotFound(
              courses: courses, campuses: campuses, classes: classes));
        } else {
          emit(ScheduleNotFound(
              courses: const [], campuses: const [], classes: const []));
        }
      } on Exception catch (e) {
        emit(ScheduleError(errorMessage: e.toString()));
      }
    });

    on<AddSchedule>((event, emit) async {
      emit(ScheduleLoading());
      try {
        final schedule = await scheduleService.addSchedule(
            event.time,
            event.duration,
            event.courseId,
            event.campusId,
            event.classId,
            event.qrCodeEnabled);

        if (schedule != null) {
          originalSchedules ??= [];
          originalSchedules!.add(schedule);
          emit(ScheduleLoaded(
              schedules: originalSchedules!,
              courses: originalCourses!,
              campuses: originalCampuses!,
              classes: originalClasses!));
          showSuccessToast("Créneau ajouté avec succès");
        } else {
          showErrorToast("Erreur lors de l'ajout");
          originalSchedules ??= [];
          emit(ScheduleLoaded(
              schedules: originalSchedules!,
              courses: originalCourses!,
              campuses: originalCampuses!,
              classes: originalClasses!));
        }
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString().replaceAll('Exception: ', '')}");
        originalSchedules ??= [];
        emit(ScheduleLoaded(
            schedules: originalSchedules!,
            courses: originalCourses!,
            campuses: originalCampuses!,
            classes: originalClasses!));
      }
    });

    on<UpdateSchedule>((event, emit) async {
      emit(ScheduleLoading());
      try {
        final updatedSchedule = await scheduleService.updateSchedule(
            event.id,
            event.time,
            event.duration,
            event.courseId,
            event.campusId,
            event.classId,
            event.qrCodeEnabled);

        if (updatedSchedule != null) {
          final userIndex = originalSchedules!
              .indexWhere((element) => element["id"] == event.id);
          originalSchedules![userIndex] = updatedSchedule;
          emit(ScheduleLoaded(
              schedules: originalSchedules!,
              courses: originalCourses!,
              campuses: originalCampuses!,
              classes: originalClasses!));
          showSuccessToast("Créneau modifié avec succès");
        } else {
          showErrorToast("Erreur lors de la modification");
          emit(ScheduleLoaded(
              schedules: originalSchedules!,
              courses: originalCourses!,
              campuses: originalCampuses!,
              classes: originalClasses!));
        }
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString()}");
        emit(ScheduleLoaded(
            schedules: originalSchedules!,
            courses: originalCourses!,
            campuses: originalCampuses!,
            classes: originalClasses!));
      }
    });

    on<DeleteSchedule>((event, emit) async {
      emit(ScheduleLoading());
      try {
        final isDeleted = await scheduleService.removeSchedule(event.id);

        if (isDeleted) {
          originalSchedules!
              .removeWhere((schedule) => schedule["id"] == event.id);
          emit(ScheduleLoaded(
              schedules: originalSchedules!,
              courses: originalCourses!,
              campuses: originalCampuses!,
              classes: originalClasses!));
          showSuccessToast("Créneau supprimé avec succès");
        } else {
          showErrorToast("Erreur lors de la suppression");
          emit(ScheduleLoaded(
              schedules: originalSchedules!,
              courses: originalCourses!,
              campuses: originalCampuses!,
              classes: originalClasses!));
        }
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString()}");
        emit(ScheduleLoaded(
            schedules: originalSchedules!,
            courses: originalCourses!,
            campuses: originalCampuses!,
            classes: originalClasses!));
      }
    });

    on<LoadScheduleCode>((event, emit) async {
      emit(ScheduleLoading());
      try {
        final code = await scheduleService.getCode(event.id);
        emit(ScheduleCode(code: code!));
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString()}");
        emit(ScheduleLoaded(
            schedules: originalSchedules!,
            courses: originalCourses!,
            campuses: originalCampuses!,
            classes: originalClasses!));
      }
    });

    on<LoadSchedule>((event, emit) async {
      emit(ScheduleLoading());
      try {
        final signatures = await scheduleService.getSignatures(event.id);
        final code = await scheduleService.getCode(event.id);
        emit(ScheduleSignatures(signatures: signatures, code: code!));
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString()}");
        emit(ScheduleLoaded(
            schedules: originalSchedules!,
            courses: originalCourses!,
            campuses: originalCampuses!,
            classes: originalClasses!));
      }
    });

    on<SignSchedule>((event, emit) async {
      emit(ScheduleLoading());
      try {
        await scheduleService.sign(
            event.scheduleId, event.studentId, event.code);
        final signatures =
            await scheduleService.getSignatures(event.scheduleId);
        final code = await scheduleService.getCode(event.scheduleId);
        emit(ScheduleSignatures(signatures: signatures, code: code!));
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString()}");
        emit(ScheduleLoaded(
            schedules: originalSchedules!,
            courses: originalCourses!,
            campuses: originalCampuses!,
            classes: originalClasses!));
      }
    });
  }
}
