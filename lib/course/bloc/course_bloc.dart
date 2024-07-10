import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:web/core/services/course_service.dart';
import 'package:web/core/services/path_service.dart';
import 'package:web/core/services/teacher_service.dart';
import 'package:web/shared/toaster.dart';

part 'course_event.dart';
part 'course_state.dart';

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final CourseService courseService;
  final TeacherService teacherService;
  final PathService pathService;
  List<dynamic>? originalCourses;
  List<dynamic>? originalTeachers;
  List<dynamic>? originalPaths;

  CourseBloc(this.courseService, this.teacherService, this.pathService) : super(CourseInitial()) {
    on<LoadCourses>((event, emit) async {
      emit(CourseLoading());
      try {
        final courses = await courseService.getCourses();
        final teachers = await teacherService.getTeachers();
        final paths = await pathService.getPaths();

        if (courses != null && courses.isNotEmpty) {
          originalCourses = courses;
          originalTeachers = teachers;
          originalPaths = paths;
          emit(CourseLoaded(courses: courses, teachers: teachers!, paths: paths!));
        } else if (teachers != null && teachers.isNotEmpty && paths != null && paths.isNotEmpty) {
          originalTeachers = teachers;
          originalPaths = paths;
          emit(CourseNotFound(teachers: teachers, paths: paths));
        } else {
          emit(CourseNotFound(teachers: const [], paths: const []));
        }
      } on Exception catch (e) {
        emit(CourseError(errorMessage: e.toString()));
      }
    });

    on<AddCourse>((event, emit) async {
      emit(CourseLoading());
      try {
        final course = await courseService.addCourse(event.name, event.description, event.pathId, event.teacherId);

        if (course != null) {
          originalCourses ??= [];
          originalCourses!.add(course);
          emit(CourseLoaded(courses: originalCourses!, paths: originalPaths!, teachers: originalTeachers!));
          showSuccessToast("Cours ajoutée avec succès");
        } else {
          showErrorToast("Erreur lors de l'ajout");
          originalCourses ??= [];
          emit(CourseLoaded(courses: originalCourses!, paths: originalPaths!, teachers: originalTeachers!));
        }
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString()}");
        originalCourses ??= [];
        emit(CourseLoaded(courses: originalCourses!, paths: originalPaths!, teachers: originalTeachers!));
      }
    });

    on<UpdateCourse>((event, emit) async {
      emit(CourseLoading());
      try {
        final updatedCourse = await courseService.updateCourse(event.id, event.name, event.description, event.pathId, event.teacherId);

        if (updatedCourse != null) {
          final userIndex = originalCourses!.indexWhere((element) => element["id"] == event.id); 
          originalCourses![userIndex] = updatedCourse;
          emit(CourseLoaded(courses: originalCourses!, paths: originalPaths!, teachers: originalTeachers!));
          showSuccessToast("Cours modifiée avec succès");
        } else {
          showErrorToast("Erreur lors de la modification");
          emit(CourseLoaded(courses: originalCourses!, paths: originalPaths!, teachers: originalTeachers!));
        }
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString()}");
        emit(CourseLoaded(courses: originalCourses!, paths: originalPaths!, teachers: originalTeachers!));
      }
    });

    on<DeleteCourse>((event, emit) async {
      emit(CourseLoading());
      try {
        final isDeleted = await courseService.removeCourse(event.id);

        if (isDeleted){
          originalCourses!.removeWhere((course) => course["id"] == event.id);
          emit(CourseLoaded(courses: originalCourses!, paths: originalPaths!, teachers: originalTeachers!));
          showSuccessToast("Cours supprimée avec succès");
        } else {
          showErrorToast("Erreur lors de la suppression");
          emit(CourseLoaded(courses: originalCourses!, paths: originalPaths!, teachers: originalTeachers!));
        }
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString()}");
        emit(CourseLoaded(courses: originalCourses!, paths: originalPaths!, teachers: originalTeachers!));
      }
    });
  }
}
