import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:web/core/services/student_service.dart';

part 'student_event.dart';
part 'student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentService studentService;

  StudentBloc(this.studentService) : super(StudentInitial()) {
    on<LoadStudents>((event, emit) async {
      emit(StudentLoading());
      try {
        print("GETTING STUDENTS INSIDE BLOC");
        final students = await studentService.getStudents();
        print("THESE ARE STUDENT");
        print(students);
        if (students != null && students.isNotEmpty) {
          emit(StudentLoaded(students: students));
        } else {
          emit(StudentNotFound());
        }
      } on Exception catch (e) {
        emit(StudentError(errorMessage: e.toString()));
      }
    });

    on<SearchStudents>((event, emit) async {
      emit(StudentLoading());
      try {
        final students = await studentService.getStudents();
        if (students != null && students.isNotEmpty) {
          final filteredStudents = students.where((student) {
            return student['lastname'].toLowerCase().contains(event.query.toLowerCase());
          }).toList();
          if (filteredStudents.isNotEmpty) {
            emit(StudentLoaded(students: filteredStudents));
          } else {
            emit(StudentNotFound());
          }
        } else {
          emit(StudentNotFound());
        }
      } on Exception catch (e) {
        emit(StudentError(errorMessage: e.toString()));
      }
    });
  }
}
