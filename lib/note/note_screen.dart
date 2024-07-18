import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons/heroicons.dart';
import 'package:web/class_id/bloc/class_id_bloc.dart';
import 'package:web/core/services/note_service.dart';
import 'package:web/core/services/project_service.dart';
import 'package:web/core/services/student_service.dart';
import 'package:web/note/bloc/note_bloc.dart';
import 'package:intl/intl.dart';
import 'package:web/shared/input_validator.dart';

class NoteScreen extends StatelessWidget {
  NoteScreen({super.key});

  final _valueController = TextEditingController();
  final _searchController = TextEditingController();

  final GlobalKey<FormState> _createFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _updateFormKey = GlobalKey<FormState>();

  String? _selectedProjectId;
  String? _selectedStudentId;

  void _clearInputs() {
    _valueController.clear();
    _selectedProjectId = null;
    _selectedStudentId = null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NoteBloc(NoteService(), ProjectService(), StudentService())..add(LoadNotes()),
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              HeroIcon(
                HeroIcons.pencilSquare,
                color: Color.fromRGBO(72, 2, 151, 1),
              ),
              SizedBox(width: 8),
              Text(
                'Notes',
                style: TextStyle(
                  color: Color.fromRGBO(72, 2, 151, 1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            BlocBuilder<NoteBloc, NoteState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: () {
                    if (state is NoteLoaded && state.projects.isNotEmpty && state.students.isNotEmpty) {
                      _showCreateDialog(context, state.projects, state.students);
                    } else if (state is NoteNotFound && state.projects.isNotEmpty && state.students.isNotEmpty) {
                      _showCreateDialog(context, state.projects, state.students);
                    } else {
                      _showEmptyDialog(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromRGBO(72, 2, 151, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text('Ajouter une note', style: TextStyle(fontSize: 16)),
                );
              },
            ),
            SizedBox(width: 16),
          ],
          toolbarHeight: 64.0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: BlocBuilder<NoteBloc, NoteState>(
                      builder: (context, state) {
                        return TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Rechercher un élève',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                context.read<NoteBloc>().add(LoadNotes());
                              },
                            ),
                          ),
                          onChanged: (query) {
                            context
                                .read<NoteBloc>()
                                .add(SearchStudent(query));
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 500),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<NoteBloc, NoteState>(
                  builder: (context, state) {
                    if (state is NoteLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is NoteLoaded) {
                      return _buildNoteTable(context, state.notes);
                    } else if (state is NoteNotFound) {
                      return const Center(child: Text('Aucune note présente'));
                    } else if (state is NoteError) {
                      return Center(child: Text('Erreur: ${state.errorMessage}'));
                    } else {
                      return const Center(child: Text('Notes'));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmptyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Ajouter une note'),
          content: const Text("Il faut un projet et des élèves pour ajouter une note, contactez votre admin pour que des élèves soient ajoutés"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Fermer', style: TextStyle(color: Colors.red)),
            ),
          ]
        );
      }
    );
  }

  void _showCreateDialog(BuildContext context, dynamic projects, dynamic students) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<NoteBloc>(context),
          child: Builder(
            builder: (context) {
              return AlertDialog(
                title: const Text(
                  'Ajouter une note',
                  style: TextStyle(
                    color: Color.fromRGBO(72, 2, 151, 1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: BlocBuilder<NoteBloc, NoteState>(
                      builder: (context, state) {
                        return Form(
                          key: _createFormKey,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: _valueController,
                                  decoration: const InputDecoration(labelText: 'Note'),
                                  validator: InputValidator.validateOnlyNumbersRange,
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(labelText: 'Projet'),
                                  value: _selectedProjectId,
                                  items: projects.map<DropdownMenuItem<String>>((project) {
                                    return DropdownMenuItem<String>(
                                      value: project['id'].toString(),
                                      child: Text(project['title']),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    _selectedProjectId = newValue;
                                  },
                                  validator: (value) => value == null ? 'Sélectionnez un projet' : null,
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(labelText: 'Étudiant'),
                                  value: _selectedStudentId,
                                  items: students.map<DropdownMenuItem<String>>((student) {
                                    return DropdownMenuItem<String>(
                                      value: student['id'].toString(),
                                      child: Text(student['firstname']),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    _selectedStudentId = newValue;
                                  },
                                  validator: (value) => value == null ? 'Sélectionnez un étudiant' : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      _clearInputs();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Fermer', style: TextStyle(color: Colors.red)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_createFormKey.currentState!.validate()) {
                        context.read<NoteBloc>().add(AddNote(
                          int.parse(_valueController.text),
                          int.parse(_selectedProjectId!),
                          int.parse(_selectedStudentId!),
                        ));
                        _clearInputs();
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Ajouter'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showNoteDetailDialog(BuildContext context, dynamic note) {
    final NoteBloc noteBloc = BlocProvider.of<NoteBloc>(context);
    final NoteState currentState = noteBloc.state;
    
    final projectController = TextEditingController();
    final studentController = TextEditingController();

    _valueController.text = note['value'].toString();

    if (currentState is NoteLoaded) {
      final projectExists = currentState.projects.any((project) => project['id'] == note['projectId']);
      if (projectExists) {
        final projectIndex = currentState.projects.indexWhere((element) => element["id"] == note['projectId']);
        projectController.text = currentState.projects[projectIndex]['title'];
      } else {
        projectController.text = 'N/A';
      }

      final studentExists = currentState.students.any((student) => student['id'] == note['studentId']);
      if (studentExists) {
        final studentIndex = currentState.students.indexWhere((element) => element["id"] == note['studentId']);
        studentController.text = currentState.students[studentIndex]['firstname'] + ' ' + currentState.students[studentIndex]['lastname'];
      } else {
        studentController.text = 'N/A';
      }
    } else {
      _selectedProjectId = null;
      _selectedStudentId = null;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<NoteBloc>(context),
          child: Builder(
            builder: (context) {
              return AlertDialog(
                title: const Text(
                  'Détails de la note',
                  style: TextStyle(
                    color: Color.fromRGBO(72, 2, 151, 1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: BlocBuilder<NoteBloc, NoteState>(
                      builder: (context, state) {
                        if (state is NoteLoaded) {
                          return Form(
                            key: _updateFormKey,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    controller: _valueController,
                                    decoration: const InputDecoration(labelText: 'Note'),
                                    validator: InputValidator.validateOnlyNumbersRange,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    decoration: const InputDecoration(labelText: 'Projet'),
                                    controller: projectController,
                                    readOnly: true,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    decoration: const InputDecoration(labelText: 'Étudiant'),
                                    controller: studentController,
                                    readOnly: true,
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      _clearInputs();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Fermer', style: TextStyle(color: Colors.red)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_updateFormKey.currentState!.validate()) {
                        context.read<NoteBloc>().add(UpdateNote(
                          note['id'],
                          int.parse(_valueController.text),
                          note['projectId'],
                          note['studentId']
                        ));
                        _clearInputs();
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Modifier'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showNoteDeleteDialog(BuildContext context, dynamic classSchool) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<NoteBloc>(context),
          child: Builder(
            builder: (context) {
              return AlertDialog(
                content: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Voulez-vous vraiment supprimer cette note ?')
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Annuler', style: TextStyle(color: Colors.red)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NoteBloc>().add(DeleteNote(classSchool['id']));
                      Navigator.of(context).pop();
                    },
                    child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNoteTable(BuildContext context, List<dynamic> notes) {
    return SizedBox(
      width: double.infinity,
      child: BlocBuilder<NoteBloc, NoteState>(
        builder: (context, state) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(
                    label: Text('Note',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color.fromRGBO(72, 2, 151, 1)))),
                DataColumn(
                    label: Text('Projet',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color.fromRGBO(72, 2, 151, 1)))),
                DataColumn(
                    label: Text('Étudiant',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color.fromRGBO(72, 2, 151, 1)))),
                DataColumn(
                    label: Text('Date de création',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color.fromRGBO(72, 2, 151, 1)))),
                DataColumn(label: Text('')),
              ],
              rows: notes.map((note) {
                DateTime parsedDate = DateTime.parse(note['createdAt']);
                return DataRow(
                  cells: [
                    DataCell(Text(note['value'].toString())),
                    DataCell(Text(note['project']['title'])),
                    DataCell(Text('${note['student']['firstname']} ${note['student']['lastname']}')),
                    DataCell(Text(DateFormat('dd-MM-yyyy').format(parsedDate))),
                    DataCell(Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              _showNoteDetailDialog(context, note);
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Color.fromRGBO(247, 159, 2, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: EdgeInsets.all(0),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: HeroIcon(
                                HeroIcons.pencil,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              _showNoteDeleteDialog(context, note);
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Color.fromRGBO(249, 141, 53, 1.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: EdgeInsets.all(0),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: HeroIcon(
                                HeroIcons.trash,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                  ],
                );
              }).toList(),
            ),
          );
        },
      )
    );
  }
}