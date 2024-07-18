import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons/heroicons.dart';
import 'package:web/core/services/class_service.dart';
import 'package:web/core/services/course_service.dart';
import 'package:web/core/services/document_service.dart';
import 'package:web/core/services/project_service.dart';
import 'package:web/project/bloc/project_bloc.dart';
import 'package:web/shared/input_validator.dart';

class ProjectScreen extends StatelessWidget {
  ProjectScreen({super.key});

  final _titleController = TextEditingController();

  final GlobalKey<FormState> _createFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _updateFormKey = GlobalKey<FormState>();

  String? _selectedCourseId;
  String? _selectedClassId;
  String? _selectedDocumentId;
  DateTime? _selectedTime;

  final TextEditingController _timeController = TextEditingController();

  void _clearInputs() {
    _titleController.clear();
    _selectedDocumentId = null;
    _selectedCourseId = null;
    _selectedClassId = null;
    _timeController.clear();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );
      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        _selectedTime = selectedDateTime;
        _timeController.text = selectedDateTime.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProjectBloc(
          ProjectService(), CourseService(), ClassService(), DocumentService())
        ..add(LoadProjects()),
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              HeroIcon(
                HeroIcons.adjustmentsHorizontal,
                color: Color.fromRGBO(72, 2, 151, 1),
              ),
              SizedBox(width: 8),
              Text(
                'Projets',
                style: TextStyle(
                  color: Color.fromRGBO(72, 2, 151, 1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            BlocBuilder<ProjectBloc, ProjectState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: () {
                    if (state is ProjectLoaded && state.courses.isNotEmpty &&  state.classes.isNotEmpty && state.documents.isNotEmpty) {
                      _showCreateDialog(context, state.courses, state.classes, state.documents);
                    } else if (state is ProjectNotFound && state.courses.isNotEmpty && state.classes.isNotEmpty && state.documents.isNotEmpty) {
                      _showCreateDialog(context, state.courses, state.classes, state.documents);
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
                  child: const Text('Ajouter', style: TextStyle(fontSize: 16)),
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
              Expanded(
                child: BlocBuilder<ProjectBloc, ProjectState>(
                  builder: (context, state) {
                    if (state is ProjectLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ProjectLoaded) {
                      return _buildProjectTable(context, state.projects);
                    } else if (state is ProjectNotFound) {
                      return const Center(
                          child: Text('Aucun projet d\'ajouté'));
                    } else if (state is ProjectError) {
                      return Center(
                          child: Text('Erreur: ${state.errorMessage}'));
                    } else {
                      return const Center(child: Text('Projets'));
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
          title: const Text('Ajouter un créneau'),
          content: const Text(
              "Pour créer des projets il faut au moins une classe, un cours et un document, contactez votre admin pour ajouter des classes et cours"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Fermer', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showCreateDialog(BuildContext context, dynamic courses, dynamic classes,
      dynamic documents) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<ProjectBloc>(context),
          child: Builder(
            builder: (context) {
              return AlertDialog(
                title: const Text(
                  'Ajouter un projet',
                  style: TextStyle(
                    color: Color.fromRGBO(72, 2, 151, 1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Form(
                      key: _createFormKey,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _titleController,
                              decoration:
                                  const InputDecoration(labelText: 'Titre'),
                              validator: InputValidator.validateName,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              decoration:
                                  const InputDecoration(labelText: 'Cours'),
                              value: _selectedCourseId,
                              items: courses
                                  .map<DropdownMenuItem<String>>((course) {
                                return DropdownMenuItem<String>(
                                  value: course['id'].toString(),
                                  child: Text(course['name'].isNotEmpty
                                      ? course['name']
                                      : 'N/A'),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                _selectedCourseId = newValue;
                              },
                              validator: (value) => value == null
                                  ? 'Sélectionnez un cours'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              decoration:
                                  const InputDecoration(labelText: 'Classe'),
                              value: _selectedClassId,
                              items: classes
                                  .map<DropdownMenuItem<String>>((classSchool) {
                                return DropdownMenuItem<String>(
                                  value: classSchool['id'].toString(),
                                  child: Text(classSchool['name'].isNotEmpty
                                      ? classSchool['name']
                                      : 'N/A'),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                _selectedClassId = newValue;
                              },
                              validator: (value) => value == null
                                  ? 'Sélectionnez une classe'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              decoration:
                                  const InputDecoration(labelText: 'Document'),
                              value: _selectedDocumentId,
                              items: documents
                                  .map<DropdownMenuItem<String>>((document) {
                                return DropdownMenuItem<String>(
                                  value: document['id'].toString(),
                                  child: Text(document['name'].isNotEmpty
                                      ? document['name']
                                      : 'N/A'),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                _selectedDocumentId = newValue;
                              },
                              validator: (value) => value == null
                                  ? 'Sélectionnez un document'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: const InputDecoration(
                                  labelText: 'Date de rendu'),
                              readOnly: true,
                              onTap: () => _selectDateTime(context),
                              validator: (value) => _selectedTime == null
                                  ? 'Sélectionnez une date limite de rendu'
                                  : null,
                              controller: _timeController,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      _clearInputs();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Fermer',
                        style: TextStyle(color: Colors.red)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_createFormKey.currentState!.validate()) {
                        context.read<ProjectBloc>().add(AddProject(
                            _titleController.text,
                            (_selectedTime?.toUtc().millisecondsSinceEpoch ??
                                    1000) /
                                1000,
                            int.parse(_selectedCourseId!),
                            int.parse(_selectedClassId!),
                            int.parse(_selectedDocumentId!)));
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

  void _showProjectDetailDialog(BuildContext context, dynamic project) {
    _titleController.text = project['title'];
    final ProjectBloc projectBloc = BlocProvider.of<ProjectBloc>(context);
    final ProjectState currentState = projectBloc.state;

    if (currentState is ProjectLoaded) {
      final courseExists = currentState.courses
          .any((course) => course['id'] == project['courseId']);
      _selectedCourseId = courseExists ? project['courseId'].toString() : null;
      final classExists = currentState.classes
          .any((classSchool) => classSchool['id'] == project['classId']);
      _selectedClassId = classExists ? project['classId'].toString() : null;
      final documentExists = currentState.documents
          .any((document) => document['id'] == project['documentId']);
      _selectedDocumentId =
          documentExists ? project['documentId'].toString() : null;
    } else {
      _selectedCourseId = null;
      _selectedClassId = null;
      _selectedDocumentId = null;
    }

    _timeController.text = project['endDate'];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<ProjectBloc>(context),
          child: Builder(
            builder: (context) {
              return AlertDialog(
                title: const Text(
                  'Détails du projet',
                  style: TextStyle(
                    color: Color.fromRGBO(72, 2, 151, 1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: BlocBuilder<ProjectBloc, ProjectState>(
                    builder: (context, state) {
                      if (state is ProjectLoaded) {
                        return Form(
                          key: _updateFormKey,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: _titleController,
                                  decoration:
                                      const InputDecoration(labelText: 'Titre'),
                                  validator: InputValidator.validateName,
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  decoration:
                                      const InputDecoration(labelText: 'Cours'),
                                  value: _selectedCourseId,
                                  items: state.courses
                                      .map<DropdownMenuItem<String>>((course) {
                                    return DropdownMenuItem<String>(
                                      value: course['id'].toString(),
                                      child: Text(course['name'].isNotEmpty
                                          ? course['name']
                                          : 'N/A'),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    _selectedCourseId = newValue;
                                  },
                                  validator: (value) => value == null
                                      ? 'Sélectionnez un cours'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                      labelText: 'Classe'),
                                  value: _selectedClassId,
                                  items: state.classes
                                      .map<DropdownMenuItem<String>>(
                                          (classSchool) {
                                    return DropdownMenuItem<String>(
                                      value: classSchool['id'].toString(),
                                      child: Text(classSchool['name'].isNotEmpty
                                          ? classSchool['name']
                                          : 'N/A'),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    _selectedClassId = newValue;
                                  },
                                  validator: (value) => value == null
                                      ? 'Sélectionnez une classe'
                                      : null,
                                ),
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                      labelText: 'Document'),
                                  value: _selectedDocumentId,
                                  items: state.documents
                                      .map<DropdownMenuItem<String>>(
                                          (document) {
                                    return DropdownMenuItem<String>(
                                      value: document['id'].toString(),
                                      child: Text(document['name'].isNotEmpty
                                          ? document['name']
                                          : 'N/A'),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    _selectedDocumentId = newValue;
                                  },
                                  validator: (value) => value == null
                                      ? 'Sélectionnez un document'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  decoration: const InputDecoration(
                                      labelText: 'Date de rendu'),
                                  readOnly: true,
                                  onTap: () => _selectDateTime(context),
                                  validator: (value) => _selectedTime == null
                                      ? 'Sélectionnez une date limite de rendu'
                                      : null,
                                  controller: _timeController,
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
                actions: [
                  TextButton(
                    onPressed: () {
                      _clearInputs();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Fermer',
                        style: TextStyle(color: Colors.red)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_updateFormKey.currentState!.validate()) {
                        context.read<ProjectBloc>().add(UpdateProject(
                            project['id'],
                            _titleController.text,
                            (_selectedTime?.toUtc().millisecondsSinceEpoch ??
                                    1000) /
                                1000,
                            int.parse(_selectedCourseId!),
                            int.parse(_selectedClassId!),
                            int.parse(_selectedDocumentId!)));
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

  void _showProjectDeleteDialog(BuildContext context, dynamic project) {
    String title = project['title'];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<ProjectBloc>(context),
          child: Builder(
            builder: (context) {
              return AlertDialog(
                content: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Voulez-vous vraiment supprimer le projet $title ?')
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Annuler',
                        style: TextStyle(color: Colors.red)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<ProjectBloc>()
                          .add(DeleteProject(project['id']));
                      Navigator.of(context).pop();
                    },
                    child: const Text('Supprimer',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProjectTable(BuildContext context, List<dynamic> projects) {
    return SizedBox(
      width: double.infinity,
      child: BlocBuilder<ProjectBloc, ProjectState>(
        builder: (context, state) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(
                    label: Text('Titre',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color.fromRGBO(72, 2, 151, 1)))),
                DataColumn(
                    label: Text('Cours',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color.fromRGBO(72, 2, 151, 1)))),
                DataColumn(
                    label: Text('Classe',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color.fromRGBO(72, 2, 151, 1)))),
                DataColumn(
                    label: Text('Document',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color.fromRGBO(72, 2, 151, 1)))),
                DataColumn(
                    label: Text('Date de rendu',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color.fromRGBO(72, 2, 151, 1)))),
                DataColumn(label: Text('')),
              ],
              rows: projects.map((project) {
                final courseName = project['course']['name'].isNotEmpty
                    ? project['course']['name']
                    : 'N/A';
                final className = project['class']['name'].isNotEmpty
                    ? project['class']['name']
                    : 'N/A';
                final documentName = project['document']['name'].isNotEmpty
                    ? project['document']['name']
                    : 'N/A';
                final time = project['endDate'];

                return DataRow(
                  cells: [
                    DataCell(Text(project['title'])),
                    DataCell(Text(courseName)),
                    DataCell(Text(className)),
                    DataCell(Text(documentName)),
                    DataCell(Text(time)),
                    DataCell(Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              _showProjectDetailDialog(context, project);
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
                              _showProjectDeleteDialog(context, project);
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
      ),
    );
  }
}
