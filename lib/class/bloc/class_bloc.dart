import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:web/core/services/class_service.dart';
import 'package:web/core/services/path_service.dart';
import 'package:web/shared/toaster.dart';

part 'class_event.dart';
part 'class_state.dart';

class ClassBloc extends Bloc<ClassEvent, ClassState> {
  final ClassService classService;
  final PathService pathService;
  List<dynamic>? originalClasses;
  List<dynamic>? originalPaths;

  ClassBloc(this.classService, this.pathService) : super(ClassInitial()) {
    on<LoadClasses>((event, emit) async {
      emit(ClassLoading());
      try {
        final classes = await classService.getClasses();
        final paths = await pathService.getPaths();

        if (classes != null && classes.isNotEmpty) {
          originalClasses = classes;
          originalPaths = paths;
          emit(ClassLoaded(classes: classes, paths: paths!));
        } else if (paths != null && paths.isNotEmpty) {
          originalPaths = paths;
          emit(ClassNotFound(paths: paths));
        } else {
          emit(ClassNotFound(paths: const []));
        }
      } on Exception catch (e) {
        emit(ClassError(errorMessage: e.toString()));
      }
    });

    on<AddClass>((event, emit) async {
      emit(ClassLoading());
      try {
        //Name different than usual because class is a reserved word
        final classSchool = await classService.addClass(event.name, event.pathId);
        classSchool['students'] = [];
        if (classSchool != null) {
          originalClasses ??= [];
          originalClasses!.add(classSchool);
          emit(ClassLoaded(classes: originalClasses!, paths: originalPaths!));
          showSuccessToast("Classe ajoutée avec succès");
        } else {
          showErrorToast("Erreur lors de l'ajout");
          originalClasses ??= [];
          emit(ClassLoaded(classes: originalClasses!, paths: originalPaths!));
        }
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString()}");
        originalClasses ??= [];
        emit(ClassLoaded(classes: originalClasses!, paths: originalPaths!));
      }
    });

    on<UpdateClass>((event, emit) async {
      emit(ClassLoading());
      try {
        final updatedClass = await classService.updateClass(event.id, event.name, event.pathId);

        if (updatedClass != null) {
          final userIndex = originalClasses!.indexWhere((element) => element["id"] == event.id); 
          originalClasses![userIndex] = updatedClass;
          emit(ClassLoaded(classes: originalClasses!, paths: originalPaths!));
          showSuccessToast("Classe modifiée avec succès");
        } else {
          showErrorToast("Erreur lors de la modification");
          emit(ClassLoaded(classes: originalClasses!, paths: originalPaths!));
        }
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString()}");
        emit(ClassLoaded(classes: originalClasses!, paths: originalPaths!));
      }
    });

    on<DeleteClass>((event, emit) async {
      emit(ClassLoading());
      try {
        final isDeleted = await classService.removeClass(event.id);

        if (isDeleted){
          originalClasses!.removeWhere((classSchool) => classSchool["id"] == event.id);
          emit(ClassLoaded(classes: originalClasses!, paths: originalPaths!));
          showSuccessToast("Classe supprimée avec succès");
        } else {
          showErrorToast("Erreur lors de la suppressions");
          emit(ClassLoaded(classes: originalClasses!, paths: originalPaths!));
        }
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString()}");
        emit(ClassLoaded(classes: originalClasses!, paths: originalPaths!));
      }   
    });
  }
}
