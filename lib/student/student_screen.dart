import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/core/services/student_service.dart';
import 'package:web/student/bloc/student_bloc.dart';
import 'package:intl/intl.dart';

class StudentScreen extends StatelessWidget {
  StudentScreen({super.key});

  final _searchController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();

  void _clearInputs() {
    _emailController.clear();
    _firstnameController.clear();
    _lastnameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StudentBloc(StudentService())..add(LoadStudents()),
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
                  ElevatedButton(
                    onPressed: () {
                      _showCreateDialog(context);
                    },
                    child: const Text('Ajouter'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<StudentBloc, StudentState>(
                  builder: (context, state) {
                    if (state is StudentLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is StudentLoaded) {
                      return _buildStudentTable(context, state.students);
                    } else if (state is StudentNotFound) {
                      return const Center(child: Text('Aucun élève dans cette école'));
                    } else if (state is StudentError) {
                      return Center(child: Text('Erreur: ${state.errorMessage}'));
                    } else {
                      return const Center(child: Text('Initial State'));
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
          content: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _firstnameController,
                  decoration: const InputDecoration(labelText: 'Prénom'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _lastnameController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                ),
              ],
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
                _clearInputs();
                Navigator.of(context).pop();
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
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter un élève'),
          content: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _firstnameController,
                  decoration: const InputDecoration(labelText: 'Prénom'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _lastnameController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _lastnameController,
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                  obscureText: true,
                ),
              ],
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
                _clearInputs();
                Navigator.of(context).pop();
              },
              child: const Text('Ajouter'),
            ),
          ],
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
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Détails de l\'élève'),
          content: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _firstnameController,
                  decoration: const InputDecoration(labelText: 'Prénom'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _lastnameController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fermer', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                print('Email: ${_emailController.text}');
                print('Prénom: ${_firstnameController.text}');
                print('Nom: ${_lastnameController.text}');
                Navigator.of(context).pop();
              },
              child: const Text('Modifier'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStudentTable(BuildContext context, List<dynamic> students) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Nom')),
            DataColumn(label: Text('Prénom')),
            DataColumn(label: Text('Classe')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Date de création')),
            DataColumn(label: Text('Action')),
          ],
          rows: students.map((student) {
            DateTime parsedDate = DateTime.parse(student['createdAt']);
            return DataRow(
              cells: [
                DataCell(Text(student['lastname'])),
                DataCell(Text(student['firstname'])),
                DataCell(Text(student['classRefer'] ?? 'N/A')),
                DataCell(Text(student['email'])),
                DataCell(Text(DateFormat('dd-MM-yyyy').format(parsedDate))),
                DataCell(ElevatedButton(
                  onPressed: () {
                    _showStudentDetailDialog(context, student);
                  },
                  child: const Text('Voir'),
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}