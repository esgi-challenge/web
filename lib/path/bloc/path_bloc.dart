import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:web/core/services/path_service.dart';

part 'path_event.dart';
part 'path_state.dart';

class PathBloc extends Bloc<PathEvent, PathState> {
  final PathService pathService;
  List<dynamic>? originalPaths;

  PathBloc(this.pathService) : super(PathInitial()) {
    on<LoadPaths>((event, emit) async {
      emit(PathLoading());
      try {
        final paths = await pathService.getPaths();
        if (paths != null && paths.isNotEmpty) {
          originalPaths = paths;
          emit(PathLoaded(paths: paths));
        } else {
          emit(PathNotFound());
        }
      } on Exception catch (e) {
        emit(PathError(errorMessage: e.toString()));
      }
    });

    on<AddPath>((event, emit) async {
      emit(PathLoading());
      try {
        final path = await pathService.addPath(event.shortName, event.longName);

        if (path != null) {
          originalPaths ??= [];
          originalPaths!.add(path);
          emit(PathLoaded(paths: originalPaths!));
        } else {
          emit(PathError(errorMessage: "La filière n'a pas pu être crée"));
        }
      } on Exception catch (e) {
        emit(PathError(errorMessage: e.toString()));
      }
    });

    on<UpdatePath>((event, emit) async {
      emit(PathLoading());
      try {
        final updatedPath = await pathService.updatePath(event.id, event.shortName, event.longName);

        if (updatedPath != null) {
          final userIndex = originalPaths!.indexWhere((element) => element["id"] == event.id); 
          originalPaths![userIndex] = updatedPath;
          emit(PathLoaded(paths: originalPaths!));
        } else {
          emit(PathError(errorMessage: "La filière n'a pas pu être modifié"));
        }
      } on Exception catch (e) {
        emit(PathError(errorMessage: e.toString()));
      }
    });

    on<DeletePath>((event, emit) async {
      emit(PathLoading());
      try {
        final isDeleted = await pathService.removePath(event.id);

        if (isDeleted){
          originalPaths!.removeWhere((path) => path["id"] == event.id);
          emit(PathLoaded(paths: originalPaths!));
        } else {
          emit(PathError(errorMessage: "La filière n'a pas pu être supprimé"));
        }
      } on Exception catch (e) {
        emit(PathError(errorMessage: "La filière n'a pas pu être supprimé"));
      }
    });
  }
}
