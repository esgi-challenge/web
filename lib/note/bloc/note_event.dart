part of 'note_bloc.dart';

@immutable
abstract class NoteEvent {}

class LoadNotees extends NoteEvent {}

class DeleteNote extends NoteEvent {
  final int id;

  DeleteNote(this.id);
}

class AddNote extends NoteEvent {
  final int value;
  final int projectId;
  final int studentId;

  AddNote(this.value, this.projectId, this.studentId);
}

class UpdateNote extends NoteEvent {
  final int id;
  final int value;
  final int projectId;
  final int studentId;

  UpdateNote(this.id, this.value, this.projectId, this.studentId);
}