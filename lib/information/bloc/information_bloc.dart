import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:web/core/services/information_service.dart';
import 'package:web/shared/toaster.dart';

part 'information_event.dart';
part 'information_state.dart';

class InformationBloc extends Bloc<InformationEvent, InformationState> {
  final InformationService informationService;
  List<dynamic>? originalInformations;

  InformationBloc(this.informationService) : super(InformationInitial()) {
    on<LoadInformations>((event, emit) async {
      emit(InformationLoading());
      try {
        final informations = await informationService.getInformations();
        if (informations != null && informations.isNotEmpty) {
          originalInformations = informations;
          emit(InformationLoaded(informations: informations));
        } else {
          emit(InformationNotFound());
        }
      } on Exception catch (e) {
        emit(InformationError(errorMessage: e.toString()));
      }
    });

    on<AddInformation>((event, emit) async {
      emit(InformationLoading());
      try {
        final information = await informationService.addInformation(event.name, event.description);

        if (information != null) {
          originalInformations ??= [];
          originalInformations!.add(information);
          emit(InformationLoaded(informations: originalInformations!));
          showSuccessToast("Information publiée");
        } else {
          showErrorToast("Erreur lors de la publication");
          originalInformations ??= [];
          emit(InformationLoaded(informations: originalInformations!));
        }
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString()}");
        originalInformations ??= [];
        emit(InformationLoaded(informations: originalInformations!));
      }
    });

    on<DeleteInformation>((event, emit) async {
      emit(InformationLoading());
      try {
        final isDeleted = await informationService.removeInformation(event.id);

        if (isDeleted){
          originalInformations!.removeWhere((information) => information["id"] == event.id);
          emit(InformationLoaded(informations: originalInformations!));
          showSuccessToast("Information supprimée avec succès");
        } else {
          showErrorToast("Erreur lors de la suppression");
          emit(InformationLoaded(informations: originalInformations!));
        }
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString()}");
        emit(InformationLoaded(informations: originalInformations!));
      }
    });
  }
}
