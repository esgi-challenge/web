import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:web/core/services/class_service.dart';

part 'class_id_event.dart';
part 'class_id_state.dart';

class ClassIdBloc extends Bloc<ClassIdEvent, ClassIdState> {
  final ClassService classService;
  dynamic classId;

  ClassIdBloc(this.classService) : super(ClassIdInitial()) {
    on<LoadClassId>((event, emit) async {
      emit(ClassIdLoading());
      try {
        final classById = await classService.getClassById(event.id);

        if (classById != null && classById.isNotEmpty) {
          classId = classById;
          print(classId);
          emit(ClassIdLoaded(classId: classId));
        } else {
          emit(ClassIdNotFound());
        }
      } on Exception catch (e) {
        emit(ClassIdError(errorMessage: e.toString()));
      }
    });

    on<RemoveStudent>((event, emit) async {
      emit(ClassIdLoading());
      try {
        print(event.id);
      } on Exception catch (e) {
        emit(ClassIdError(errorMessage: e.toString()));
      }
    });
  }
}
