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

    on<SearchStudents>((event, emit) async {
      print("test");
      emit(StudentLoading());
        final filteredStudents = originalStudents?.where((student) {
          return student['lastname'].toLowerCase().contains(event.query.toLowerCase());
        }).toList();
        emit(StudentLoaded(students: filteredStudents!));
    });
  }
}
