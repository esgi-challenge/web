import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:web/core/services/student_service.dart';

part 'student_event.dart';
part 'student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentService studentService;
  List<dynamic>? originalStudents;

  StudentBloc(this.studentService) : super(StudentInitial()) {
    on<LoadStudents>((event, emit) async {
      emit(StudentLoading());
      try {
        final students = await studentService.getStudents();
        if (students != null && students.isNotEmpty) {
          originalStudents = students;
          emit(StudentLoaded(students: students));
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

      emit(StudentLoaded(students: filteredStudents));
    });

    on<AddStudent>((event, emit) async {
      emit(StudentLoading());
      try {
        final student = await studentService.addStudent(event.email, event.firstname, event.lastname, event.password);

        if (student != null) {
          originalStudents ??= [];
          originalStudents!.add(student);
          emit(StudentLoaded(students: originalStudents!));
        } else {
          emit(StudentError(errorMessage: "L'élève n'a pas pu être crée"));
        }
      } on Exception catch (e) {
        emit(StudentError(errorMessage: e.toString()));
      }
    });

    on<UpdateStudent>((event, emit) async {
      emit(StudentLoading());
      try {
        final updatedStudent = await studentService.updateStudent(event.id, event.email, event.firstname, event.lastname);

        if (updatedStudent != null) {
          final userIndex = originalStudents!.indexWhere((element) => element["id"] == event.id); 
          originalStudents![userIndex] = updatedStudent;
          emit(StudentLoaded(students: originalStudents!));
        } else {
          emit(StudentError(errorMessage: "L'élève n'a pas pu être modifié"));
        }
      } on Exception catch (e) {
        emit(StudentError(errorMessage: e.toString()));
      }
    });

    on<DeleteStudent>((event, emit) async {
      emit(StudentLoading());
      try {
        final isDeleted = await studentService.removeStudent(event.id);

        if (isDeleted){
          originalStudents!.removeWhere((student) => student["id"] == event.id);
          emit(StudentLoaded(students: originalStudents!));
        } else {
          emit(StudentError(errorMessage: "L'élève n'a pas pu être supprimé"));
        }
      } on Exception catch (e) {
        emit(StudentError(errorMessage: "L'élève n'a pas pu être supprimé"));
      }
    });
  }
}
