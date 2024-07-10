import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons/heroicons.dart';
import 'package:web/core/services/course_service.dart';
import 'package:web/core/services/path_service.dart';
import 'package:web/core/services/teacher_service.dart';
import 'package:web/course/bloc/course_bloc.dart';
import 'package:intl/intl.dart';
import 'package:web/shared/input_validator.dart';

class CourseScreen extends StatelessWidget {
  CourseScreen({super.key});

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final GlobalKey<FormState> _createFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _updateFormKey = GlobalKey<FormState>();

  String? _selectedPathId;
  String? _selectedTeacherId;

  void _clearInputs() {
    _nameController.clear();
    _descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CourseBloc(CourseService(), TeacherService(), PathService())..add(LoadCourses()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cours'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 50),
                  BlocBuilder<CourseBloc, CourseState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: () {
                          if (state is CourseLoaded && state.paths.isNotEmpty && state.teachers.isNotEmpty) {
                            _showCreateDialog(context, state.paths, state.teachers);
                          } else if (state is CourseNotFound && state.paths.isNotEmpty && state.teachers.isNotEmpty) {
                            _showCreateDialog(context, state.paths, state.teachers);
                          } else {
                            _showEmptyDialog(context);
                          }
                        },
                        child: const Text('Créer'),
                      );
                    },
                  )
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<CourseBloc, CourseState>(
                  builder: (context, state) {
                    if (state is CourseLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is CourseLoaded) {
                      return _buildCourseTable(context, state.courses);
                    } else if (state is CourseNotFound) {
                      return const Center(child: Text('Aucune filière dans cette école'));
                    } else if (state is CourseError) {
                      return Center(child: Text('Erreur: ${state.errorMessage}'));
                    } else {
                      return const Center(child: Text('Filières'));
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
          title: const Text('Ajouter un cours'),
          content: const Text("Créez des filières et des professeurs avant de créer des cours"),
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

  void _showCreateDialog(BuildContext context, dynamic paths, dynamic teachers) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<CourseBloc>(context),
          child: Builder(
            builder: (context) {
              return AlertDialog(
                title: const Text('Ajouter un cours'),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Form(
                    key: _createFormKey,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: 'Nom'),
                            validator: InputValidator.validateName,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 5, // Agrandir le champ de texte
                            decoration: const InputDecoration(labelText: 'Description'),
                            validator: InputValidator.validateName,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Filière'),
                            value: _selectedPathId,
                            items: paths.map<DropdownMenuItem<String>>((path) {
                              return DropdownMenuItem<String>(
                                value: path['id'].toString(),
                                child: Text(path['shortName'].isNotEmpty ? path['shortName'] : 'N/A'), // Remplacer les valeurs vides par N/A
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              _selectedPathId = newValue;
                            },
                            validator: (value) => value == null ? 'Sélectionnez une filière' : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Professeur'),
                            value: _selectedTeacherId,
                            items: teachers.map<DropdownMenuItem<String>>((teacher) {
                              final fullName = '${teacher['firstname']} ${teacher['lastname']}';
                              return DropdownMenuItem<String>(
                                value: teacher['id'].toString(),
                                child: Text(fullName.isNotEmpty ? fullName : 'N/A'), // Remplacer les valeurs vides par N/A
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              _selectedTeacherId = newValue;
                            },
                            validator: (value) => value == null ? 'Sélectionnez un professeur' : null,
                          ),
                        ],
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
                    child: const Text('Fermer', style: TextStyle(color: Colors.red)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_createFormKey.currentState!.validate()) {
                        context.read<CourseBloc>().add(AddCourse(
                          _nameController.text,
                          _descriptionController.text,
                          int.parse(_selectedPathId!),
                          int.parse(_selectedTeacherId!)
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

  void _showCourseDetailDialog(BuildContext context, dynamic course) {
    _nameController.text = course['name'];
    _descriptionController.text = course['description'];
    final CourseBloc courseBloc = BlocProvider.of<CourseBloc>(context);
    final CourseState currentState = courseBloc.state;

    if (currentState is CourseLoaded) {
      final pathExists = currentState.paths.any((path) => path['id'] == course['pathId']);
      _selectedPathId = pathExists ? course['pathId'].toString() : null;
      final teacherExists = currentState.teachers.any((teacher) => teacher['id'] == course['teacherId']);
      _selectedTeacherId = teacherExists ? course['teacherId'].toString() : null;
    } else {
      _selectedPathId = null;
      _selectedTeacherId = null;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<CourseBloc>(context),
          child: Builder(
            builder: (context) {
              return AlertDialog(
                title: const Text('Détails de la classe'),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: BlocBuilder<CourseBloc, CourseState>(
                    builder: (context, state) {
                      if (state is CourseLoaded) {
                        return Form(
                          key: _updateFormKey,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(labelText: 'Nom'),
                                  validator: InputValidator.validateName,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _descriptionController,
                                  maxLines: 5, // Agrandir le champ de texte
                                  decoration: const InputDecoration(labelText: 'Description'),
                                  validator: InputValidator.validateName,
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(labelText: 'Filière'),
                                  value: _selectedPathId,
                                  items: state.paths.map<DropdownMenuItem<String>>((path) {
                                    return DropdownMenuItem<String>(
                                      value: path['id'].toString(),
                                      child: Text(path['shortName'].isNotEmpty ? path['shortName'] : 'N/A'), // Remplacer les valeurs vides par N/A
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    _selectedPathId = newValue;
                                  },
                                  validator: (value) => value == null ? 'Sélectionnez une filière' : null,
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(labelText: 'Professeur'),
                                  value: _selectedTeacherId,
                                  items: state.teachers.map<DropdownMenuItem<String>>((teacher) {
                                    final fullName = '${teacher['firstname']} ${teacher['lastname']}';
                                    return DropdownMenuItem<String>(
                                      value: teacher['id'].toString(),
                                      child: Text(fullName.isNotEmpty ? fullName : 'N/A'), // Remplacer les valeurs vides par N/A
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    _selectedTeacherId = newValue;
                                  },
                                  validator: (value) => value == null ? 'Sélectionnez un professeur' : null,
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
                    child: const Text('Fermer', style: TextStyle(color: Colors.red)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_updateFormKey.currentState!.validate()) {
                        context.read<CourseBloc>().add(UpdateCourse(
                          course['id'],
                          _nameController.text,
                          _descriptionController.text,
                          int.parse(_selectedPathId!),
                          int.parse(_selectedTeacherId!)
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

  void _showCourseDeleteDialog(BuildContext context, dynamic course) {
    String name = course['name'];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<CourseBloc>(context),
          child: Builder(
            builder: (context) {
              return AlertDialog(
                content: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Voulez vous vraiment supprimer le cours $name ?')
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
                      context.read<CourseBloc>().add(DeleteCourse(course['id']));
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

  Widget _buildCourseTable(BuildContext context, List<dynamic> courses) {
    return SizedBox(
      width: double.infinity,
      child: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Nom')),
                DataColumn(label: Text('Filière')),
                DataColumn(label: Text('Professeur')),
                DataColumn(label: Text('Date de création')),
                DataColumn(label: Text('')),
                DataColumn(label: Text(''))
              ],
              rows: courses.map((course) {
                DateTime parsedDate = DateTime.parse(course['createdAt']);
                final pathName = course['path']['shortName'].isNotEmpty ? course['path']['shortName'] : 'N/A';
                final teacherName = '${course['teacher']['firstname']} ${course['teacher']['lastname']}'.trim().isNotEmpty ? '${course['teacher']['firstname']} ${course['teacher']['lastname']}' : 'N/A';

                return DataRow(
                  cells: [
                    DataCell(Text(course['name'])),
                    DataCell(Text(pathName)), // Remplacer les valeurs vides par N/A
                    DataCell(Text(teacherName)), // Remplacer les valeurs vides par N/A
                    DataCell(Text(DateFormat('dd-MM-yyyy').format(parsedDate))),
                    DataCell(ElevatedButton(
                      onPressed: () {
                        _showCourseDetailDialog(context, course);
                      },
                      child: const HeroIcon(
                        HeroIcons.pencil,
                      ),
                    )),
                    DataCell(ElevatedButton(
                      onPressed: () {
                        _showCourseDeleteDialog(context, course);
                      },
                      child: const HeroIcon(
                        HeroIcons.trash,
                        color: Colors.red,
                      ),
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