import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:web/core/services/class_service.dart';
import 'package:web/shared/toaster.dart';

part 'class_id_event.dart';
part 'class_id_state.dart';

class ClassIdBloc extends Bloc<ClassIdEvent, ClassIdState> {
  final ClassService classService;
  dynamic classId;
  List<dynamic>? classLessStudents;

  ClassIdBloc(this.classService) : super(ClassIdInitial()) {
    on<LoadClassId>((event, emit) async {
      emit(ClassIdLoading());
      try {
        final classById = await classService.getClassById(event.id);
        final students = await classService.getClassLessStudents();

        if (classById != null && classById.isNotEmpty) {
          classId = classById;
          classLessStudents = students;
          emit(ClassIdLoaded(classId: classId, classLessStudents: classLessStudents));
        } else {
          emit(ClassIdNotFound());
        }
      } on Exception catch (e) {
        emit(ClassIdError(errorMessage: e.toString()));
      }
    });

    on<AddStudent>((event, emit) async {
      emit(ClassIdLoading());
      try {
        final newStudent = await classService.addStudentToClass(classId["id"], event.id);

        if (newStudent != null) {
          classId["students"] ??= [];
          classId["students"]!.add(newStudent);
          classLessStudents!.removeWhere((student) => student["id"] == event.id);

          emit(ClassIdLoaded(classId: classId, classLessStudents: classLessStudents!));
          showSuccessToast("Étudiant ajouté à la classe");
        } else {
          showErrorToast("Erreur lors de l'ajout");
          classId["students"] ??= [];
          emit(ClassIdLoaded(classId: classId, classLessStudents: classLessStudents!));
        }
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString()}");
        classId["students"] ??= [];
          emit(ClassIdLoaded(classId: classId, classLessStudents: classLessStudents!));
      }
    });

    on<SearchStudents>((event, emit) {
      if (classLessStudents == null) return;

      final query = event.query.toLowerCase();
      final filteredStudents = classLessStudents!.where((student) {
        return student['lastname'].toLowerCase().startsWith(query);
      }).toList();

      emit(ClassIdLoaded(classId: classId, classLessStudents: filteredStudents));
    });


    on<RemoveStudent>((event, emit) async {
      emit(ClassIdLoading());
      try {
        final removedStudent = await classService.removeStudentFromClass(classId["id"], event.id);

        if (removedStudent != null) {
          classId["students"]!.removeWhere((student) => student["id"] == event.id);
          classLessStudents ??= [];
          classLessStudents!.add(removedStudent);
          emit(ClassIdLoaded(classId: classId, classLessStudents: classLessStudents!));
          showSuccessToast("Étudiant retiré avec succès");
        } else {
          showErrorToast("Erreur lors du retrait");
          classLessStudents ??= [];
          emit(ClassIdLoaded(classId: classId, classLessStudents: classLessStudents!));
        }
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString()}");
        classLessStudents ??= [];
        emit(ClassIdLoaded(classId: classId, classLessStudents: classLessStudents!));
      }
    });
  }
}
