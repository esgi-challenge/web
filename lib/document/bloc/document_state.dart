part of 'document_bloc.dart';

@immutable
abstract class DocumentState {}

class DocumentInitial extends DocumentState {}

class DocumentLoading extends DocumentState {}

class DocumentLoaded extends DocumentState {
  final List<dynamic> documents;
  final List<dynamic> courses;

  DocumentLoaded({required this.documents, required this.courses});
}

class DocumentNotFound extends DocumentState {
  final List<dynamic> courses;

  DocumentNotFound({required this.courses});
}

class DocumentError extends DocumentState {
  final String errorMessage;

  DocumentError({required this.errorMessage});
}