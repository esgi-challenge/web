import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/core/services/student_service.dart';
import 'package:web/student/bloc/student_bloc.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StudentBloc(StudentService())..add(LoadStudents()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Élèves'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                final query = _searchController.text;
                context.read<StudentBloc>().add(SearchStudents(query));
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Rechercher un élève',
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            context.read<StudentBloc>().add(LoadStudents());
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Inviter'),
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
                      return _buildStudentTable(state.students);
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

  Widget _buildStudentTable(List<dynamic> students) {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Nom')),
          DataColumn(label: Text('Prénom')),
          DataColumn(label: Text('Classe')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Action')),
        ],
        rows: students.map((student) {
          return DataRow(
            cells: [
              DataCell(Text(student['lastname'])),
              DataCell(Text(student['firstname'])),
              DataCell(Text(student['classRefer'] ?? 'N/A')),
              DataCell(Text(student['email'])),
              DataCell(ElevatedButton(
                onPressed: () {},
                child: const Text('Voir'),
              )),
            ],
          );
        }).toList(),
      ),
    );
  }
}