import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:web/core/services/note_service.dart';
import 'package:web/core/services/project_service.dart';
import 'package:web/core/services/student_service.dart';
import 'package:web/shared/toaster.dart';

part 'note_event.dart';
part 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final NoteService noteService;
  final ProjectService projectService;
  final StudentService studentService;
  List<dynamic>? originalNotes;
  List<dynamic>? originalProjects;
  List<dynamic>? originalStudents;

  NoteBloc(this.noteService, this.projectService, this.studentService) : super(NoteInitial()) {
    on<LoadNotees>((event, emit) async {
      emit(NoteLoading());
      try {
        final notes = await noteService.getNotes();
        final projects = await projectService.getProjects();
        final students = await studentService.getStudents();

        if (notes != null && notes.isNotEmpty) {
          originalNotes = notes;
          originalProjects = projects;
          originalStudents = students;
          emit(NoteLoaded(notes: notes, projects: projects!, students: students!));
        } else if (projects != null && projects.isNotEmpty && students != null && students.isNotEmpty) {
          originalProjects = projects;
          originalStudents = students;
          emit(NoteNotFound(projects: projects, students: students));
        } else {
          emit(NoteNotFound(projects: const [], students: const []));
        }
      } on Exception catch (e) {
        emit(NoteError(errorMessage: e.toString()));
      }
    });

    on<AddNote>((event, emit) async {
      emit(NoteLoading());
      try {
        final note = await noteService.addNote(event.value, event.projectId, event.studentId);

        if (note != null) {
          originalNotes ??= [];
          originalNotes!.add(note);
          emit(NoteLoaded(notes: originalNotes!, projects: originalProjects!, students: originalStudents!));
          showSuccessToast("Note ajoutée avec succès");
        } else {
          showErrorToast("Erreur lors de l'ajout");
          originalNotes ??= [];
          emit(NoteLoaded(notes: originalNotes!, projects: originalProjects!, students: originalStudents!));
        }
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString()}");
        originalNotes ??= [];
        emit(NoteLoaded(notes: originalNotes!, projects: originalProjects!, students: originalStudents!));
      }
    });

    on<UpdateNote>((event, emit) async {
      emit(NoteLoading());
      try {
        final updatedNote = await noteService.updateNote(event.id, event.value, event.projectId, event.studentId);

        if (updatedNote != null) {
          final index = originalNotes!.indexWhere((element) => element["id"] == event.id); 
          originalNotes![index] = updatedNote;
          emit(NoteLoaded(notes: originalNotes!, projects: originalProjects!, students: originalStudents!));
          showSuccessToast("Note modifiée avec succès");
        } else {
          showErrorToast("Erreur lors de la modification");
          emit(NoteLoaded(notes: originalNotes!, projects: originalProjects!, students: originalStudents!));
        }
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString()}");
        emit(NoteLoaded(notes: originalNotes!, projects: originalProjects!, students: originalStudents!));
      }
    });

    on<DeleteNote>((event, emit) async {
      emit(NoteLoading());
      try {
        final isDeleted = await noteService.removeNote(event.id);

        if (isDeleted){
          originalNotes!.removeWhere((note) => note["id"] == event.id);
          emit(NoteLoaded(notes: originalNotes!, projects: originalProjects!, students: originalStudents!));
          showSuccessToast("Note supprimée avec succès");
        } else {
          showErrorToast("Erreur lors de la suppressions");
          emit(NoteLoaded(notes: originalNotes!, projects: originalProjects!, students: originalStudents!));
        }
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString()}");
        emit(NoteLoaded(notes: originalNotes!, projects: originalProjects!, students: originalStudents!));
      }   
    });
  }
}
