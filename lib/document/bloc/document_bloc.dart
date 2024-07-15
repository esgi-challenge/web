import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:web/core/services/document_service.dart';
import 'package:web/core/services/course_service.dart';
import 'package:web/shared/toaster.dart';

part 'document_event.dart';
part 'document_state.dart';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final DocumentService documentService;
  final CourseService courseService;
  List<dynamic>? originalDocuments;
  List<dynamic>? originalCourses;

  DocumentBloc(this.documentService, this.courseService) : super(DocumentInitial()) {
    on<LoadDocuments>((event, emit) async {
      emit(DocumentLoading());
      try {
        final documents = await documentService.getDocuments();
        final courses = await courseService.getCourses();

        if (documents != null && documents.isNotEmpty) {
          originalDocuments = documents;
          originalCourses = courses;
          emit(DocumentLoaded(documents: documents, courses: courses!));
        } else if (courses != null && courses.isNotEmpty) {
          originalCourses = courses;
          emit(DocumentNotFound(courses: courses));
        } else {
          emit(DocumentNotFound(courses: const []));
        }
      } on Exception catch (e) {
        emit(DocumentError(errorMessage: e.toString()));
      }
    });

    on<AddDocument>((event, emit) async {
      emit(DocumentLoading());
      try {
        final document = await documentService.addDocument(event.name, event.courseId, event.documentBytes, event.documentName);

        if (document != null) {
          originalDocuments ??= [];
          originalDocuments!.add(document);
          emit(DocumentLoaded(documents: originalDocuments!, courses: originalCourses!));
          showSuccessToast("Document ajouté avec succès");
        } else {
          showErrorToast("Erreur lors de l'ajout");
          originalDocuments ??= [];
          emit(DocumentLoaded(documents: originalDocuments!, courses: originalCourses!));
        }
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString()}");
        originalDocuments ??= [];
        emit(DocumentLoaded(documents: originalDocuments!, courses: originalCourses!));
      }
    });

    on<DeleteDocument>((event, emit) async {
      emit(DocumentLoading());
      try {
        final isDeleted = await documentService.removeDocument(event.id);

        if (isDeleted){
          originalDocuments!.removeWhere((document) => document["id"] == event.id);
          emit(DocumentLoaded(documents: originalDocuments!, courses: originalCourses!));
          showSuccessToast("Document supprimé avec succès");
        } else {
          showErrorToast("Erreur lors de la suppression");
          emit(DocumentLoaded(documents: originalDocuments!, courses: originalCourses!));
        }
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString()}");
        emit(DocumentLoaded(documents: originalDocuments!, courses: originalCourses!));
      }
    });
  }
}
