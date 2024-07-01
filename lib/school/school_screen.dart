import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/core/services/school_services.dart';
import 'package:web/school/bloc/school_bloc.dart';

class SchoolScreen extends StatelessWidget {
  SchoolScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SchoolBloc(SchoolService())..add(LoadSchool()),
      child: Scaffold(
        appBar: AppBar(title: const Text('École')),
        body: BlocBuilder<SchoolBloc, SchoolState>(
          builder: (context, state) {
            if (state is SchoolLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SchoolNotFound) {
              return _buildCreateSchoolForm(context);
            } else if (state is SchoolLoaded) {
              return Center(
                child: Text('Bienvenue sur le portail de votre organisme de formation : ${state.school['name']}'),
              );
            } else if (state is SchoolError) {
              return Center(child: Text('Erreur: ${state.errorMessage}'));
            } else if (state is SchoolCreating) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return const Center(child: Text('Initial State'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildCreateSchoolForm(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Il semblerait que vous n\'avez pas d\'organisme d\'éducation. Vous pouvez le créer en remplissant le formulaire suivant :',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: name,
                      decoration: const InputDecoration(labelText: 'Nom de l\'école'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le nom est requis';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<SchoolBloc>().add(CreateSchool(name: name.text));
                        }
                      },
                      child: const Text('Créer'),
                    ),
                  ],
                )
              ),
            ),
          ],
        ),
      )
    ); 
  }
}