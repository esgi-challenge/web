import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:web/core/services/campus_service.dart';

part 'campus_event.dart';
part 'campus_state.dart';

class CampusBloc extends Bloc<CampusEvent, CampusState> {
  final CampusService campusService;
  List<dynamic>? originalCampus;

  CampusBloc(this.campusService) : super(CampusInitial()) {
    on<LoadCampus>((event, emit) async {
      emit(CampusLoading());
      try {
        final campus = await campusService.getCampus();
        if (campus != null && campus.isNotEmpty) {
          originalCampus = campus;
          emit(CampusLoaded(campus: campus));
        } else {
          emit(CampusNotFound());
        }
      } on Exception catch (e) {
        emit(CampusError(errorMessage: e.toString()));
      }
    });

    on<AddCampus>((event, emit) async {
      emit(CampusLoading());
      try {
        final campus = await campusService.addCampus(event.latitude, event.longitude, event.location, event.name);

        if (campus != null) {
          originalCampus ??= [];
          originalCampus!.add(campus);
          emit(CampusLoaded(campus: originalCampus!));
        } else {
          emit(CampusError(errorMessage: "Le campus n'a pas pu être crée"));
        }
      } on Exception catch (e) {
        emit(CampusError(errorMessage: e.toString()));
      }
    });

    on<UpdateCampus>((event, emit) async {
      emit(CampusLoading());
      try {
        final updatedCampus = await campusService.updateCampus(event.id, event.latitude, event.longitude, event.location, event.name);

        if (updatedCampus != null) {
          final userIndex = originalCampus!.indexWhere((element) => element["id"] == event.id); 
          originalCampus![userIndex] = updatedCampus;
          emit(CampusLoaded(campus: originalCampus!));
        } else {
          emit(CampusError(errorMessage: "Le campus n'a pas pu être modifié"));
        }
      } on Exception catch (e) {
        emit(CampusError(errorMessage: e.toString()));
      }
    });

    on<DeleteCampus>((event, emit) async {
      emit(CampusLoading());
      try {
        final isDeleted = await campusService.removeCampus(event.id);

        if (isDeleted){
          originalCampus!.removeWhere((campus) => campus["id"] == event.id);
          emit(CampusLoaded(campus: originalCampus!));
        } else {
          emit(CampusError(errorMessage: "Le campus n'a pas pu être supprimé"));
        }
      } on Exception catch (e) {
        emit(CampusError(errorMessage: "Le campus n'a pas pu être supprimé"));
      }
    });
  }
}
