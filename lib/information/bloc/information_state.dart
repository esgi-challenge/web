part of 'information_bloc.dart';

@immutable
abstract class InformationState {}

class InformationInitial extends InformationState {}

class InformationLoading extends InformationState {}

class InformationLoaded extends InformationState {
  final List<dynamic> informations;

  InformationLoaded({required this.informations});
}

class InformationNotFound extends InformationState {}

class InformationError extends InformationState {
  final String errorMessage;

  InformationError({required this.errorMessage});
}