import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/core/services/student_service.dart';
import 'package:web/student/bloc/student_bloc.dart';
import 'package:intl/intl.dart';

class StudentScreen extends StatelessWidget {
  StudentScreen({super.key});

  final _searchController = TextEditingController();

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
                children: [
                  Flexible(
                    flex: 1,
                    child: TextField(
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
                    ),
                  ),
                  const SizedBox(width: 500),
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
                  onPressed: () {},
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