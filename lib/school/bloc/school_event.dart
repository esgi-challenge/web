part of 'school_bloc.dart';

@immutable
sealed class SchoolEvent {}

final class LoadSchool extends SchoolEvent {}

final class CreateSchool extends SchoolEvent {
  final String name;

  CreateSchool({required this.name});
}