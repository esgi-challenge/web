part of 'document_bloc.dart';

@immutable
abstract class DocumentEvent {}

class LoadDocuments extends DocumentEvent {}

class DeleteDocument extends DocumentEvent {
  final int id;

  DeleteDocument(this.id);
}

class AddDocument extends DocumentEvent {
  final String name;
  final int? courseId;
  final Uint8List documentBytes;
  final String documentName;

  AddDocument(this.name, this.courseId, this.documentBytes, this.documentName);
}