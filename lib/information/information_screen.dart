import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons/heroicons.dart';
import 'package:web/core/services/information_service.dart';
import 'package:web/information/bloc/information_bloc.dart';
import 'package:intl/intl.dart';
import 'package:web/shared/input_validator.dart';

class InformationScreen extends StatelessWidget {
  InformationScreen({super.key});

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final GlobalKey<FormState> _createFormKey = GlobalKey<FormState>();

  void _clearInputs() {
    _titleController.clear();
    _descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InformationBloc(InformationService())..add(LoadInformations()),
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              HeroIcon(
                HeroIcons.informationCircle,
                color: Color.fromRGBO(72, 2, 151, 1),
              ),
              SizedBox(width: 8),
              Text(
                'Informations',
                style: TextStyle(
                  color: Color.fromRGBO(72, 2, 151, 1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            BlocBuilder<InformationBloc, InformationState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: () {
                    _showCreateDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromRGBO(72, 2, 151, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child:
                  const Text('Publier', style: TextStyle(fontSize: 16)),
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
                child: BlocBuilder<InformationBloc, InformationState>(
                  builder: (context, state) {
                    if (state is InformationLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is InformationLoaded) {
                      return _buildInformationList(context, state.informations);
                    } else if (state is InformationNotFound) {
                      return const Center(child: Text('Aucune publication dans cette école'));
                    } else if (state is InformationError) {
                      return Center(child: Text('Erreur: ${state.errorMessage}'));
                    } else {
                      return const Center(child: Text('Informations'));
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

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<InformationBloc>(context),
          child: Builder(
            builder: (context) {
              return AlertDialog(
                title: const Text('Publier une information'),
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Form(
                      key: _createFormKey,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(labelText: 'Titre'),
                              validator: InputValidator.validateName,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 5,
                              decoration: const InputDecoration(labelText: 'Description'),
                              validator: InputValidator.validateName,
                            ),
                          ],
                        ),
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
                        context.read<InformationBloc>().add(AddInformation(
                          _titleController.text,
                          _descriptionController.text,
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

  void _showInformationDeleteDialog(BuildContext context, dynamic information) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<InformationBloc>(context),
          child: Builder(
            builder: (context) {
              return AlertDialog(
                content: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Voulez vous vraiment supprimer cette publication ?')
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
                      context.read<InformationBloc>().add(DeleteInformation(information['id']));
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

  Widget _buildInformationList(BuildContext context, List<dynamic> informations) {
    return ListView.builder(
      itemCount: informations.length,
      itemBuilder: (context, index) {
        int reversedIndex = informations.length - 1 - index;
        var information = informations[reversedIndex];
        DateTime parsedDate = DateTime.parse(information['createdAt']);
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  information['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('dd/MM/yyyy').format(parsedDate),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(information['description']),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () {
                      _showInformationDeleteDialog(context, information);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4))
                      )
                    ),
                    child: const HeroIcon(
                      HeroIcons.trash,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}