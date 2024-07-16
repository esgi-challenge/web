part of 'note_bloc.dart';

@immutable
abstract class NoteState {}

class NoteInitial extends NoteState {}

class NoteLoading extends NoteState {}

class NoteLoaded extends NoteState {
  final List<dynamic> notes;
  final List<dynamic> projects;
  final List<dynamic> students;

  NoteLoaded({required this.notes, required this.projects, required this.students});
}

class NoteNotFound extends NoteState {
  final List<dynamic> projects;
  final List<dynamic> students;

  NoteNotFound({required this.projects, required this.students});
}

class NoteError extends NoteState {
  final String errorMessage;

  NoteError({required this.errorMessage});
}