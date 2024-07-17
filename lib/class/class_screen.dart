import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:web/core/services/class_service.dart';
import 'package:web/class/bloc/class_bloc.dart';
import 'package:intl/intl.dart';
import 'package:web/core/services/path_service.dart';
import 'package:web/shared/input_validator.dart';

class ClassScreen extends StatelessWidget {
  ClassScreen({super.key});

  final _nameController = TextEditingController();
  final GlobalKey<FormState> _createFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _updateFormKey = GlobalKey<FormState>();

  String? _selectedPathId;

  void _clearInputs() {
    _nameController.clear();
    _selectedPathId = null;
  }

  void _navigateToClassId(BuildContext context, int classId) {
    GoRouter router = GoRouter.of(context);
    router.go('/class/$classId');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClassBloc(ClassService(), PathService())..add(LoadClasses()),
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              HeroIcon(
                HeroIcons.buildingOffice,
                color: Color.fromRGBO(72, 2, 151, 1),
              ),
              SizedBox(width: 8),
              Text(
                'Classes',
                style: TextStyle(
                  color: Color.fromRGBO(72, 2, 151, 1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            BlocBuilder<ClassBloc, ClassState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: () {
                    if (state is ClassLoaded && state.paths.isNotEmpty) {
                      _showCreateDialog(context, state.paths);
                    } else if (state is ClassNotFound && state.paths.isNotEmpty) {
                      _showCreateDialog(context, state.paths);
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
                  child: const Text(
                      'Créer',
                      style: TextStyle(fontSize: 16)
                  ),
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
                child: BlocBuilder<ClassBloc, ClassState>(
                  builder: (context, state) {
                    if (state is ClassLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ClassLoaded) {
                      return _buildClassTable(context, state.classes, state.paths);
                    } else if (state is ClassNotFound) {
                      return const Center(child: Text('Aucune classe dans cette école'));
                    } else if (state is ClassError) {
                      return Center(child: Text('Erreur: ${state.errorMessage}'));
                    } else {
                      return const Center(child: Text('Classes'));
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
          title: const Text('Ajouter une classe'),
          content: const Text("Créez des filières avant de créer des classes"),
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

  void _showCreateDialog(BuildContext context, dynamic paths) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<ClassBloc>(context),
          child: Builder(
            builder: (context) {
              return AlertDialog(
                title: const Text('Ajouter une classe'),
                content: BlocBuilder<ClassBloc, ClassState>(
                  builder: (context, state) {
                      return Form(
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
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(labelText: 'Filière'),
                                value: _selectedPathId,
                                items: paths.map<DropdownMenuItem<String>>((path) {
                                  return DropdownMenuItem<String>(
                                    value: path['id'].toString(),
                                    child: Text(path['shortName']),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  _selectedPathId = newValue;
                                },
                                validator: (value) => value == null ? 'Sélectionnez une filière' : null,
                              ),
                            ],
                          ),
                        ),
                      );
                  },
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
                        context.read<ClassBloc>().add(AddClass(
                          _nameController.text,
                          int.parse(_selectedPathId!)
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

  void _showClassDetailDialog(BuildContext context, dynamic classSchool) {
    _nameController.text = classSchool['name'];
    final ClassBloc classBloc = BlocProvider.of<ClassBloc>(context);
    final ClassState currentState = classBloc.state;

    if (currentState is ClassLoaded) {
      final pathExists = currentState.paths.any((path) => path['id'] == classSchool['pathId']);
      _selectedPathId = pathExists ? classSchool['pathId'].toString() : null;
    } else {
      _selectedPathId = null;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<ClassBloc>(context),
          child: Builder(
            builder: (context) {
              return AlertDialog(
                title: const Text('Détails de la classe'),
                content: BlocBuilder<ClassBloc, ClassState>(
                  builder: (context, state) {
                    if (state is ClassLoaded) {
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
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(labelText: 'Filière'),
                                value: _selectedPathId,
                                items: state.paths.map<DropdownMenuItem<String>>((path) {
                                  return DropdownMenuItem<String>(
                                    value: path['id'].toString(),
                                    child: Text(path['shortName']),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  _selectedPathId = newValue;
                                },
                                validator: (value) => value == null ? 'Sélectionnez une filière' : null,
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
                        context.read<ClassBloc>().add(UpdateClass(
                          classSchool['id'],
                          _nameController.text,
                          int.parse(_selectedPathId!)
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

  void _showClassDeleteDialog(BuildContext context, dynamic classSchool) {
    String name = classSchool['name'];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<ClassBloc>(context),
          child: Builder(
            builder: (context) {
              return AlertDialog(
                content: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Voulez-vous vraiment supprimer la classe $name ?')
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
                      context.read<ClassBloc>().add(DeleteClass(classSchool['id']));
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

  Widget _buildClassTable(BuildContext context, List<dynamic> classes, List<dynamic> paths) {
    return SizedBox(
      width: double.infinity,
      child: BlocBuilder<ClassBloc, ClassState>(
        builder: (context, state) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(
                    label: Text('Nom',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color.fromRGBO(72, 2, 151, 1)
                        )
                    )
                ),
                DataColumn(
                    label: Text('Date de création',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color.fromRGBO(72, 2, 151, 1)
                        )
                    )
                ),
                DataColumn(
                    label: Text('Filière',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color.fromRGBO(72, 2, 151, 1)
                        )
                    )
                ),
                DataColumn(
                    label: Text('Nb d\'élèves',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color.fromRGBO(72, 2, 151, 1)
                        )
                    )
                ),
                DataColumn(label: Text('')),
              ],
              rows: classes.map((classSchool) {
                DateTime parsedDate = DateTime.parse(classSchool['createdAt']);
                String pathName = paths.firstWhere(
                  (path) => path['id'] == classSchool['pathId'],
                  orElse: () => {'shortName': 'N/A'}
                )['shortName'];
                return DataRow(
                  cells: [
                    DataCell(Text(classSchool['name'])),
                    DataCell(Text(DateFormat('dd-MM-yyyy').format(parsedDate))),
                    DataCell(Text(pathName)),
                    DataCell(Text(classSchool['students'].length.toString())),
                    DataCell(Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              _showClassDetailDialog(context, classSchool);
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
                              _navigateToClassId(context, classSchool['id']);
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
                                HeroIcons.userGroup,
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
                              _showClassDeleteDialog(context, classSchool);
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