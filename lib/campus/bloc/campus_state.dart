part of 'campus_bloc.dart';

@immutable
abstract class CampusState {}

class CampusInitial extends CampusState {}

class CampusLoading extends CampusState {}

class CampusLoaded extends CampusState {
  final List<dynamic> campus;

  CampusLoaded({required this.campus});
}

class CampusNotFound extends CampusState {}

class CampusError extends CampusState {
  final String errorMessage;

  CampusError({required this.errorMessage});
}