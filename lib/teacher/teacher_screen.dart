import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons/heroicons.dart';
import 'package:web/core/services/teacher_service.dart';
import 'package:web/teacher/bloc/teacher_bloc.dart';
import 'package:web/shared/input_validator.dart';
import 'package:intl/intl.dart';

class TeacherScreen extends StatelessWidget {
  TeacherScreen({super.key});

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
      create: (context) => TeacherBloc(TeacherService())..add(LoadTeachers()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Professeurs'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: BlocBuilder<TeacherBloc, TeacherState>(
                      builder: (context, state) {
                        return TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Rechercher un professeur',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                context.read<TeacherBloc>().add(LoadTeachers());
                              },
                            ),
                          ),
                          onChanged: (query) {
                            context.read<TeacherBloc>().add(SearchTeachers(query));
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
                  BlocBuilder<TeacherBloc, TeacherState>(
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
                child: BlocBuilder<TeacherBloc, TeacherState>(
                  builder: (context, state) {
                    if (state is TeacherLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is TeacherLoaded) {
                      return _buildTeacherTable(context, state.teachers);
                    } else if (state is TeacherNotFound) {
                      return const Center(child: Text('Aucun professeur dans cette école'));
                    } else if (state is TeacherError) {
                      return Center(child: Text('Erreur: ${state.errorMessage}'));
                    } else {
                      return const Center(child: Text('Teachers'));
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
          title: const Text('Nouvel professeur'),
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
          value: BlocProvider.of<TeacherBloc>(context),
          child: Builder (
            builder: (context) {
              return AlertDialog(
                title: const Text('Ajouter un professeur'),
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
                        context.read<TeacherBloc>().add(AddTeacher(
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

  void _showTeacherDetailDialog(BuildContext context, dynamic teacher) {
    _emailController.text = teacher['email'];
    _firstnameController.text = teacher['firstname'];
    _lastnameController.text = teacher['lastname'];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<TeacherBloc>(context),
          child: Builder(
            builder: (context) {
              return AlertDialog(
                title: const Text('Détails de l\'professeur'),
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
                        context.read<TeacherBloc>().add(UpdateTeacher(
                          teacher['id'],
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

  void _showTeacherDeleteDialog(BuildContext context, dynamic teacher) {
    String firstname = teacher['firstname'];
    String lastname = teacher['lastname'];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<TeacherBloc>(context),
          child: Builder(
            builder: (context) {
              return AlertDialog(
                content: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Voulez vous vraiment supprimer l\'professeur $firstname $lastname?')
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
                      context.read<TeacherBloc>().add(DeleteTeacher(teacher['id']));
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

  Widget _buildTeacherTable(BuildContext context, List<dynamic> teachers) {
    return SizedBox(
      width: double.infinity,
      child: BlocBuilder<TeacherBloc, TeacherState>(
        builder: (context, state) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Nom')),
                DataColumn(label: Text('Prénom')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Date de création')),
                DataColumn(label: Text('')),
                DataColumn(label: Text(''))
              ],
              rows: teachers.map((teacher) {
                DateTime parsedDate = DateTime.parse(teacher['createdAt']);
                return DataRow(
                  cells: [
                    DataCell(Text(teacher['lastname'])),
                    DataCell(Text(teacher['firstname'])),
                    DataCell(Text(teacher['email'])),
                    DataCell(Text(DateFormat('dd-MM-yyyy').format(parsedDate))),
                    DataCell(ElevatedButton(
                      onPressed: () {
                        _showTeacherDetailDialog(context, teacher);
                      },
                      child: const Text('Voir'),
                    )),
                    DataCell(ElevatedButton(
                      onPressed: () {
                        _showTeacherDeleteDialog(context, teacher);
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