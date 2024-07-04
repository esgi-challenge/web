import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:web/class_id/bloc/class_id_bloc.dart';
import 'package:web/core/services/class_service.dart';

class ClassIdScreen extends StatelessWidget {
  final int id;

  const ClassIdScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClassIdBloc(ClassService())..add(LoadClassId(id)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Liste des étudiants'),
          leading: BackButton(
            onPressed: () {
              GoRouter router = GoRouter.of(context);
              router.go('/class');
            },
          ),
        ),
        body: BlocBuilder<ClassIdBloc, ClassIdState>(
          builder: (context, state) {
            if (state is ClassIdInitial || state is ClassIdLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ClassIdLoaded) {
              if (state.classId['students'].isEmpty) {
                return const Center(child: Text('Aucun élève dans cette classe'));
              } else {
                return _buildStudentTable(context, state.classId['students']);
              }
            } else if (state is ClassIdError) {
              return Center(child: Text('Erreur: ${state.errorMessage}'));
            } else {
              return Container();
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddStudentDialog(context);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildStudentTable(BuildContext context, List<dynamic> students) {
    return SizedBox(
      width: double.infinity,
      child: BlocBuilder<ClassIdBloc, ClassIdState>(
        builder: (context, state) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Prénom')),
                DataColumn(label: Text('Nom de famille')),
                DataColumn(label: Text(''))
              ],
              rows: students.map((student) {
                return DataRow(
                  cells: [
                    DataCell(Text(student['firstname'])),
                    DataCell(Text(student['lastname'])),
                    DataCell(ElevatedButton(
                      onPressed: () {
                        _showRemoveStudentDialog(context, student);
                      },
                      child: const HeroIcon(
                        HeroIcons.userMinus,
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

  void _showAddStudentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Ajouter un étudiant'),
          content: Form(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                ],
              ),
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
                Navigator.of(context).pop();
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

 void _showRemoveStudentDialog(BuildContext context, dynamic student) {
    String firstname = student['firstname'];
    String lastname = student['lastname'];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<ClassIdBloc>(context),
          child: Builder(
            builder: (context) {
              return AlertDialog(
                content: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Voulez-vous vraiment retirer $firstname $lastname de cette classe ?')
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
                      context.read<ClassIdBloc>().add(RemoveStudent(student['id']));
                      Navigator.of(context).pop();
                    },
                    child: const Text('Retirer', style: TextStyle(color: Colors.red)),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}