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
      if (originalStudents == null) return;

      final query = event.query.toLowerCase();
      final filteredStudents = originalStudents!.where((student) {
        return student['lastname'].toLowerCase().startsWith(query);
      }).toList();

      emit(StudentLoaded(students: filteredStudents));
    });
  }
}
