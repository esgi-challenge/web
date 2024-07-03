import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:web/core/services/teacher_service.dart';

part 'teacher_event.dart';
part 'teacher_state.dart';

class TeacherBloc extends Bloc<TeacherEvent, TeacherState> {
  final TeacherService teacherService;
  List<dynamic>? originalTeachers;

  TeacherBloc(this.teacherService) : super(TeacherInitial()) {
    on<LoadTeachers>((event, emit) async {
      emit(TeacherLoading());
      try {
        final teachers = await teacherService.getTeachers();
        if (teachers != null && teachers.isNotEmpty) {
          originalTeachers = teachers;
          emit(TeacherLoaded(teachers: teachers));
        } else {
          emit(TeacherNotFound());
        }
      } on Exception catch (e) {
        emit(TeacherError(errorMessage: e.toString()));
      }
    });

    on<SearchTeachers>((event, emit) {
      emit(TeacherLoading());
      if (originalTeachers == null) return;

      final query = event.query.toLowerCase();
      final filteredTeachers = originalTeachers!.where((teacher) {
        return teacher['lastname'].toLowerCase().startsWith(query);
      }).toList();

      emit(TeacherLoaded(teachers: filteredTeachers));
    });

    on<AddTeacher>((event, emit) async {
      emit(TeacherLoading());
      try {
        final teacher = await teacherService.addTeacher(event.email, event.firstname, event.lastname, event.password);

        if (teacher != null) {
          originalTeachers ??= [];
          originalTeachers!.add(teacher);
          emit(TeacherLoaded(teachers: originalTeachers!));
        } else {
          emit(TeacherError(errorMessage: "Le professeur n'a pas pu être crée"));
        }
      } on Exception catch (e) {
        emit(TeacherError(errorMessage: e.toString()));
      }
    });

    on<UpdateTeacher>((event, emit) async {
      emit(TeacherLoading());
      try {
        final updatedTeacher = await teacherService.updateTeacher(event.id, event.email, event.firstname, event.lastname);

        if (updatedTeacher != null) {
          final userIndex = originalTeachers!.indexWhere((element) => element["id"] == event.id); 
          originalTeachers![userIndex] = updatedTeacher;
          emit(TeacherLoaded(teachers: originalTeachers!));
        } else {
          emit(TeacherError(errorMessage: "Le professeur n'a pas pu être modifié"));
        }
      } on Exception catch (e) {
        emit(TeacherError(errorMessage: e.toString()));
      }
    });

    on<DeleteTeacher>((event, emit) async {
      emit(TeacherLoading());
      try {
        final isDeleted = await teacherService.removeTeacher(event.id);

        if (isDeleted){
          originalTeachers!.removeWhere((teacher) => teacher["id"] == event.id);
          emit(TeacherLoaded(teachers: originalTeachers!));
        } else {
          emit(TeacherError(errorMessage: "Le professeur n'a pas pu être supprimé"));
        }
      } on Exception catch (e) {
        emit(TeacherError(errorMessage: "Le professeur n'a pas pu être supprimé"));
      }
    });
  }
}
