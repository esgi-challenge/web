import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/core/services/school_services.dart';

part 'school_event.dart';
part 'school_state.dart';

class SchoolBloc extends Bloc<SchoolEvent, SchoolState> {
  final SchoolService schoolService;

  SchoolBloc(this.schoolService) : super(SchoolInitial()) {
    on<LoadSchool>((event, emit) async {
      emit(SchoolLoading());
      try {
        final school = await schoolService.getSchool();
        if (school != null) {
          emit(SchoolLoaded(school: school));
        } else {
          emit(SchoolNotFound());
        }
      } on Exception catch (e) {
        emit(SchoolError(errorMessage: e.toString()));
      }
    });

    on<CreateSchool>((event, emit) async {
      emit(SchoolCreating());
      try {
        await schoolService.createSchool(event.name);
        emit(SchoolCreated());
        add(LoadSchool());
      } on Exception catch (e) {
        emit(SchoolError(errorMessage: e.toString()));
      }
    });
  }
}