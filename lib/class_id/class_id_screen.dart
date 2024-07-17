import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:web/class_id/bloc/class_id_bloc.dart';
import 'package:web/core/services/class_service.dart';

class ClassIdScreen extends StatelessWidget {
  final int id;

  ClassIdScreen({super.key, required this.id});
  
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClassIdBloc(ClassService())..add(LoadClassId(id)),
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const HeroIcon(HeroIcons.arrowLongLeft,
                  color: Color.fromRGBO(247, 159, 2, 1), size: 32),
              onPressed: () {
                GoRouter router = GoRouter.of(context);
                router.go('/class');
              },
            ),
            title: const Text(
              "Liste des étudiants",
              style: TextStyle(
                color: Color.fromRGBO(72, 2, 151, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            toolbarHeight: 64.0,
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
        floatingActionButton: BlocBuilder<ClassIdBloc, ClassIdState>(
          builder: (context, state) {
            return FloatingActionButton(
              onPressed: () {
                if (state is ClassIdLoaded) {
                  _showAddStudentDialog(context, state.classLessStudents);
                }
              },
              child: const Icon(Icons.add),
            );
          },
        )
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
                DataColumn(
                    label: Text('Prénom',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color.fromRGBO(72, 2, 151, 1)))),
                DataColumn(
                    label: Text('Nom',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color.fromRGBO(72, 2, 151, 1)))),
                DataColumn(label: Text(''))
              ],
              rows: students.map((student) {
                return DataRow(
                  cells: [
                    DataCell(Text(student['firstname'])),
                    DataCell(Text(student['lastname'])),
                    DataCell(
                      SizedBox(
                        width: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            _showRemoveStudentDialog(context, student);
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
                              HeroIcons.userMinus,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        },
      )
    );
  }

  void _showAddStudentDialog(BuildContext context, List<dynamic> students) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<ClassIdBloc>(context),
          child: Builder (
            builder: (context) {
              return AlertDialog(
                title: const Text('Ajouter un élève'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 300,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Rechercher un élève',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                context.read<ClassIdBloc>().add(LoadClassId(id));
                              },
                            ),
                          ),
                          onChanged: (query) {
                            context.read<ClassIdBloc>().add(SearchStudents(query));
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: BlocBuilder<ClassIdBloc, ClassIdState>(
                          builder: (context, state) {
                            if (students.isEmpty) {
                              return const Center(child: Text('Aucun élève sans classe'));
                            } else if (state is ClassIdLoaded) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(label: Text('Prénom')),
                                      DataColumn(label: Text('Nom')),
                                      DataColumn(label: Text(''))
                                    ],
                                    rows: state.classLessStudents.map<DataRow>((student) {
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(student['firstname'])),
                                          DataCell(Text(student['lastname'])),
                                          DataCell(ElevatedButton(
                                            onPressed: () {
                                              _searchController.clear();
                                              context.read<ClassIdBloc>().add(AddStudent(student['id']));
                                            },
                                            child: const HeroIcon(
                                              HeroIcons.userPlus,
                                              color: Colors.green,
                                            ),
                                          )),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            } else {
                              return const Center(child: CircularProgressIndicator());
                            }
                          },
                        ),
                      ),
                    ],
                  )
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Fermer', style: TextStyle(color: Colors.red)),
                  )
                ],
              );
            },
          ),
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