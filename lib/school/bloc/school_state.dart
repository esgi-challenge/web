part of 'school_bloc.dart';

@immutable
sealed class SchoolState {}

final class SchoolInitial extends SchoolState {}

final class SchoolLoading extends SchoolState {}

final class SchoolLoaded extends SchoolState {
  final Map<String, dynamic> school;

  SchoolLoaded({required this.school});
}

final class SchoolNotFound extends SchoolState {}

final class SchoolError extends SchoolState {
  final String errorMessage;

  SchoolError({required this.errorMessage});
}

final class SchoolCreating extends SchoolState {}

final class SchoolCreated extends SchoolState {}