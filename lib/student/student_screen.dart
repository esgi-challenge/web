import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons/heroicons.dart';
import 'package:web/core/services/class_service.dart';
import 'package:web/core/services/student_service.dart';
import 'package:web/student/bloc/student_bloc.dart';
import 'package:intl/intl.dart';
import 'package:web/shared/input_validator.dart';

class StudentScreen extends StatelessWidget {
  StudentScreen({super.key});

  final _searchController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _passwordController = TextEditingController();

  final GlobalKey<FormState> _inviteFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _createFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _updateFormKey = GlobalKey<FormState>();

  void _clearInputs() {
    _emailController.clear();
    _firstnameController.clear();
    _lastnameController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StudentBloc(StudentService(), ClassService())..add(LoadStudents()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Élèves'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: BlocBuilder<StudentBloc, StudentState>(
                      builder: (context, state) {
                        return TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Rechercher un élève',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                context.read<StudentBloc>().add(LoadStudents());
                              },
                            ),
                          ),
                          onChanged: (query) {
                            context.read<StudentBloc>().add(SearchStudents(query));
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 500),
                  ElevatedButton(
                    onPressed: () {
                      _showInviteDialog(context);
                    },
                    child: const Text('Inviter'),
                  ),
                  const SizedBox(width: 50),
                  BlocBuilder<StudentBloc, StudentState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: () {
                          _showCreateDialog(context);
                        },
                        child: const Text('Ajouter'),
                      );
                    },
                  )
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<StudentBloc, StudentState>(
                  builder: (context, state) {
                    if (state is StudentLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is StudentLoaded) {
                      return _buildStudentTable(context, state.students, state.classes);
                    } else if (state is StudentNotFound) {
                      return const Center(child: Text('Aucun élève dans cette école'));
                    } else if (state is StudentError) {
                      return Center(child: Text('Erreur: ${state.errorMessage}'));
                    } else {
                      return const Center(child: Text('Students'));
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

  void _showInviteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nouvel élève'),
          content: Form(
            key: _inviteFormKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: InputValidator.validateEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _firstnameController,
                    decoration: const InputDecoration(labelText: 'Prénom'),
                    validator: InputValidator.validateName,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastnameController,
                    decoration: const InputDecoration(labelText: 'Nom'),
                    validator: InputValidator.validateName,
                  ),
                ],
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
                if (_inviteFormKey.currentState!.validate()) {
                  _clearInputs();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Inviter'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<StudentBloc>(context),
          child: Builder (
            builder: (context) {
              return AlertDialog(
                title: const Text('Ajouter un élève'),
                content: Form(
                  key: _createFormKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: InputValidator.validateEmail,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _firstnameController,
                          decoration: const InputDecoration(labelText: 'Prénom'),
                          validator: InputValidator.validateName,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _lastnameController,
                          decoration: const InputDecoration(labelText: 'Nom'),
                          validator: InputValidator.validateName,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(labelText: 'Mot de passe'),
                          obscureText: true,
                          validator: InputValidator.validatePassword,
                        ),
                      ],
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
                        context.read<StudentBloc>().add(AddStudent(
                          _emailController.text,
                          _firstnameController.text,
                          _lastnameController.text,
                          _passwordController.text,
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

  void _showStudentDetailDialog(BuildContext context, dynamic student) {
    _emailController.text = student['email'];
    _firstnameController.text = student['firstname'];
    _lastnameController.text = student['lastname'];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<StudentBloc>(context),
          child: Builder(
            builder: (context) {
              return AlertDialog(
                title: const Text('Détails de l\'élève'),
                content: Form(
                  key: _updateFormKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: InputValidator.validateEmail,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _firstnameController,
                          decoration: const InputDecoration(labelText: 'Prénom'),
                          validator: InputValidator.validateName,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _lastnameController,
                          decoration: const InputDecoration(labelText: 'Nom'),
                          validator: InputValidator.validateName,
                        ),
                      ],
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
                        context.read<StudentBloc>().add(UpdateStudent(
                          student['id'],
                          _emailController.text,
                          _firstnameController.text,
                          _lastnameController.text,
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
          )
        );
      },
    );
  }

  void _showStudentDeleteDialog(BuildContext context, dynamic student) {
    String firstname = student['firstname'];
    String lastname = student['lastname'];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<StudentBloc>(context),
          child: Builder(
            builder: (context) {
              return AlertDialog(
                content: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Voulez vous vraiment supprimer l\'élève $firstname $lastname?')
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
                      context.read<StudentBloc>().add(DeleteStudent(student['id']));
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

  Widget _buildStudentTable(BuildContext context, List<dynamic> students, List<dynamic> classes) {
    return SizedBox(
      width: double.infinity,
      child: BlocBuilder<StudentBloc, StudentState>(
        builder: (context, state) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Nom')),
                DataColumn(label: Text('Prénom')),
                DataColumn(label: Text('Classe')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Date de création')),
                DataColumn(label: Text('')),
                DataColumn(label: Text(''))
              ],
              rows: students.map((student) {
                DateTime parsedDate = DateTime.parse(student['createdAt']);
                String className = classes.firstWhere(
                  (classSchool) => classSchool['id'] == student['classRefer'],
                  orElse: () => {'name': 'N/A'}
                )['name'];
                return DataRow(
                  cells: [
                    DataCell(Text(student['lastname'])),
                    DataCell(Text(student['firstname'])),
                    DataCell(Text(className)),
                    DataCell(Text(student['email'])),
                    DataCell(Text(DateFormat('dd-MM-yyyy').format(parsedDate))),
                    DataCell(ElevatedButton(
                      onPressed: () {
                        _showStudentDetailDialog(context, student);
                      },
                      child: const HeroIcon(
                        HeroIcons.pencil,
                      ),
                    )),
                    DataCell(ElevatedButton(
                      onPressed: () {
                        _showStudentDeleteDialog(context, student);
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
      )
    );
  }
}