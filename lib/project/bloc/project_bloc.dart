import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:web/core/services/class_service.dart';
import 'package:web/core/services/course_service.dart';
import 'package:web/core/services/document_service.dart';
import 'package:web/core/services/project_service.dart';
import 'package:web/shared/toaster.dart';

part 'project_event.dart';
part 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final ProjectService projectService;
  final CourseService courseService;
  final ClassService classService;
  final DocumentService documentService;
  List<dynamic>? originalProjects;
  List<dynamic>? originalCourses;
  List<dynamic>? originalClasses;
  List<dynamic>? originalDocuments;

  ProjectBloc(this.projectService, this.courseService, this.classService, this.documentService) : super(ProjectInitial()) {
    on<LoadProjects>((event, emit) async {
      emit(ProjectLoading());
      try {
        final projects = await projectService.getProjects();
        final courses = await courseService.getCourses();
        final classes = await classService.getClasses();
        final documents = await documentService.getDocuments();

        if (projects != null && projects.isNotEmpty) {
          originalProjects = projects;
          originalCourses = courses;
          originalClasses = classes;
          originalDocuments = documents;
          emit(ProjectLoaded(projects: projects, courses: courses!, classes: classes!, documents: documents!));
        } else if (courses != null && courses.isNotEmpty && classes != null && classes.isNotEmpty && documents != null && documents.isNotEmpty) {
          originalCourses = courses;
          originalClasses = classes;
          originalDocuments = documents;
          emit(ProjectNotFound(courses: courses, classes: classes, documents: documents));
        } else {
          emit(ProjectNotFound(courses: const [], classes: const [], documents: const []));
        }
      } on Exception catch (e) {
        emit(ProjectError(errorMessage: e.toString()));
      }
    });

    on<AddProject>((event, emit) async {
      emit(ProjectLoading());
      try {
        final project = await projectService.addProject(event.title, event.endDate, event.courseId, event.classId, event.documentId);

        if (project != null) {
          originalProjects ??= [];
          originalProjects!.add(project);
          emit(ProjectLoaded(projects: originalProjects!, courses: originalCourses!, classes: originalClasses!, documents: originalDocuments!));
          showSuccessToast("Projet ajouté avec succès");
        } else {
          showErrorToast("Erreur lors de l'ajout");
          originalProjects ??= [];
          emit(ProjectLoaded(projects: originalProjects!, courses: originalCourses!, classes: originalClasses!, documents: originalDocuments!));
        }
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString()}");
        originalProjects ??= [];
        emit(ProjectLoaded(projects: originalProjects!, courses: originalCourses!, classes: originalClasses!, documents: originalDocuments!));
      }
    });

    on<UpdateProject>((event, emit) async {
      emit(ProjectLoading());
      try {
        final updatedProject = await projectService.updateProject(event.id, event.title, event.endDate, event.courseId, event.classId, event.documentId);

        if (updatedProject != null) {
          final userIndex = originalProjects!.indexWhere((element) => element["id"] == event.id); 
          originalProjects![userIndex] = updatedProject;
          emit(ProjectLoaded(projects: originalProjects!, courses: originalCourses!, classes: originalClasses!, documents: originalDocuments!));
          showSuccessToast("Projet modifié avec succès");
        } else {
          showErrorToast("Erreur lors de la modification");
          emit(ProjectLoaded(projects: originalProjects!, courses: originalCourses!, classes: originalClasses!, documents: originalDocuments!));
        }
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString()}");
        emit(ProjectLoaded(projects: originalProjects!, courses: originalCourses!, classes: originalClasses!, documents: originalDocuments!));
      }
    });

    on<DeleteProject>((event, emit) async {
      emit(ProjectLoading());
      try {
        final isDeleted = await projectService.removeProject(event.id);

        if (isDeleted){
          originalProjects!.removeWhere((project) => project["id"] == event.id);
          emit(ProjectLoaded(projects: originalProjects!, courses: originalCourses!, classes: originalClasses!, documents: originalDocuments!));
          showSuccessToast("Projet supprimé avec succès");
        } else {
          showErrorToast("Erreur lors de la suppression");
          emit(ProjectLoaded(projects: originalProjects!, courses: originalCourses!, classes: originalClasses!, documents: originalDocuments!));
        }
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString()}");
        emit(ProjectLoaded(projects: originalProjects!, courses: originalCourses!, classes: originalClasses!, documents: originalDocuments!));
      }
    });
  }
}
