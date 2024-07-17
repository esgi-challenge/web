import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:web/core/services/class_service.dart';
import 'package:web/core/services/student_service.dart';
import 'package:web/shared/toaster.dart';

part 'student_event.dart';
part 'student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentService studentService;
  final ClassService classService;
  List<dynamic>? originalStudents;
  List<dynamic>? originalClasses;

  StudentBloc(this.studentService, this.classService)
      : super(StudentInitial()) {
    on<LoadStudents>((event, emit) async {
      emit(StudentLoading());
      try {
        final students = await studentService.getStudents();
        final classes = await classService.getClasses();

        if (students != null && students.isNotEmpty) {
          originalStudents = students;
          originalClasses = classes;
          emit(StudentLoaded(students: students, classes: classes!));
        } else {
          emit(StudentNotFound());
        }
      } on Exception catch (e) {
        emit(StudentError(errorMessage: e.toString()));
      }
    });

    on<SearchStudents>((event, emit) {
      emit(StudentLoading());
      if (originalStudents == null) return;

      final query = event.query.toLowerCase();
      final filteredStudents = originalStudents!.where((student) {
        return student['lastname'].toLowerCase().startsWith(query);
      }).toList();

      emit(
          StudentLoaded(students: filteredStudents, classes: originalClasses!));
    });

    on<AddStudent>((event, emit) async {
      emit(StudentLoading());
      try {
        final student = await studentService.addStudent(
            event.email, event.firstname, event.lastname, event.password);

        if (student != null) {
          originalStudents ??= [];
          originalStudents!.add(student);
          originalClasses ??= [];
          emit(StudentLoaded(
              students: originalStudents!, classes: originalClasses!));
          showSuccessToast("Étudiant ajouté avec succès");
        } else {
          showErrorToast("Erreur lors de l'ajout");
          originalStudents ??= [];
          originalClasses ??= [];
          emit(StudentLoaded(
              students: originalStudents!, classes: originalClasses!));
        }
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString().replaceAll('Exception: ', '')}");
        originalStudents ??= [];
        originalClasses ??= [];
        emit(StudentLoaded(
            students: originalStudents!, classes: originalClasses!));
      }
    });

    on<InviteStudent>((event, emit) async {
      emit(StudentLoading());
      try {
        final student = await studentService.inviteUser(
            event.email, event.firstname, event.lastname);

        if (student != null) {
          originalStudents ??= [];
          originalStudents!.add(student);
          originalClasses ??= [];
          emit(StudentLoaded(
              students: originalStudents!, classes: originalClasses!));
          showSuccessToast("Étudiant ajouté avec succès");
        } else {
          showErrorToast("Erreur lors de l'ajout");
          originalStudents ??= [];
          originalClasses ??= [];
          emit(StudentLoaded(
              students: originalStudents!, classes: originalClasses!));
        }
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString()}");
        originalStudents ??= [];
        originalClasses ??= [];
        emit(StudentLoaded(
            students: originalStudents!, classes: originalClasses!));
      }
    });

    on<UpdateStudent>((event, emit) async {
      emit(StudentLoading());
      try {
        final updatedStudent = await studentService.updateStudent(
            event.id, event.email, event.firstname, event.lastname);

        if (updatedStudent != null) {
          final userIndex = originalStudents!
              .indexWhere((element) => element["id"] == event.id);
          originalStudents![userIndex] = updatedStudent;
          emit(StudentLoaded(
              students: originalStudents!, classes: originalClasses!));
          showSuccessToast("Étudiant modifié avec succès");
        } else {
          showErrorToast("Erreur lors de la modification");
          emit(StudentLoaded(
              students: originalStudents!, classes: originalClasses!));
        }
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString()}");
        emit(StudentLoaded(
            students: originalStudents!, classes: originalClasses!));
      }
    });

    on<DeleteStudent>((event, emit) async {
      emit(StudentLoading());
      try {
        final isDeleted = await studentService.removeStudent(event.id);

        if (isDeleted) {
          originalStudents!.removeWhere((student) => student["id"] == event.id);
          emit(StudentLoaded(
              students: originalStudents!, classes: originalClasses!));
          showSuccessToast("Étudiant supprimé avec succès");
        } else {
          showErrorToast("Erreur lors de la suppression");
          emit(StudentLoaded(
              students: originalStudents!, classes: originalClasses!));
        }
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString()}");
        emit(StudentLoaded(
            students: originalStudents!, classes: originalClasses!));
      }
    });
  }
}
