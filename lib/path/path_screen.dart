import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons/heroicons.dart';
import 'package:web/core/services/path_service.dart';
import 'package:web/path/bloc/path_bloc.dart';
import 'package:intl/intl.dart';
import 'package:web/shared/input_validator.dart';

class PathScreen extends StatelessWidget {
  PathScreen({super.key});

  final _shortNameController = TextEditingController();
  final _longNameController = TextEditingController();

  final GlobalKey<FormState> _createFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _updateFormKey = GlobalKey<FormState>();

  void _clearInputs() {
    _shortNameController.clear();
    _longNameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PathBloc(PathService())..add(LoadPaths()),
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              HeroIcon(
                HeroIcons.briefcase,
                color: Color.fromRGBO(72, 2, 151, 1),
              ),
              SizedBox(width: 8),
              Text(
                'Filières',
                style: TextStyle(
                  color: Color.fromRGBO(72, 2, 151, 1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            BlocBuilder<PathBloc, PathState>(
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
                child: BlocBuilder<PathBloc, PathState>(
                  builder: (context, state) {
                    if (state is PathLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is PathLoaded) {
                      return _buildPathTable(context, state.paths);
                    } else if (state is PathNotFound) {
                      return const Center(child: Text('Aucune filière dans cette école'));
                    } else if (state is PathError) {
                      return Center(child: Text('Erreur: ${state.errorMessage}'));
                    } else {
                      return const Center(child: Text('Filières'));
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
          value: BlocProvider.of<PathBloc>(context),
          child: Builder (
            builder: (context) {
              return AlertDialog(
                title: const Text(
                  'Ajouter une filière',
                  style: TextStyle(
                    color: Color.fromRGBO(72, 2, 151, 1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                              controller: _shortNameController,
                              decoration: const InputDecoration(labelText: 'Nom raccourci'),
                              validator: InputValidator.validateName,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _longNameController,
                              decoration: const InputDecoration(labelText: 'Nom complet'),
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
                        context.read<PathBloc>().add(AddPath(
                          _shortNameController.text,
                          _longNameController.text,
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

  void _showPathDetailDialog(BuildContext context, dynamic path) {
    _shortNameController.text = path['shortName'];
    _longNameController.text = path['longName'];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<PathBloc>(context),
          child: Builder(
            builder: (context) {
              return AlertDialog(
                title: const Text(
                  'Détails de la filière',
                  style: TextStyle(
                    color: Color.fromRGBO(72, 2, 151, 1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Form(
                      key: _updateFormKey,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _shortNameController,
                              decoration: const InputDecoration(labelText: 'Nom raccourci'),
                              validator: InputValidator.validateName,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _longNameController,
                              decoration: const InputDecoration(labelText: 'Nom complet'),
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
                      if (_updateFormKey.currentState!.validate()) {
                        context.read<PathBloc>().add(UpdatePath(
                          path['id'],
                          _shortNameController.text,
                          _longNameController.text,
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

  void _showPathDeleteDialog(BuildContext context, dynamic path) {
    String shortName = path['shortName'];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<PathBloc>(context),
          child: Builder(
            builder: (context) {
              return AlertDialog(
                content: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Voulez vous vraiment supprimer la filière $shortName ?')
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
                      context.read<PathBloc>().add(DeletePath(path['id']));
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

  Widget _buildPathTable(BuildContext context, List<dynamic> paths) {
    return SizedBox(
      width: double.infinity,
      child: BlocBuilder<PathBloc, PathState>(
        builder: (context, state) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(
                    label: Text('Nom raccourci',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color.fromRGBO(72, 2, 151, 1)
                        )
                    )
                ),
                DataColumn(
                    label: Text('Nom complet',
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
                DataColumn(label: Text('')),
              ],
              rows: paths.map((path) {
                DateTime parsedDate = DateTime.parse(path['createdAt']);
                return DataRow(
                  cells: [
                    DataCell(Text(path['shortName'])),
                    DataCell(Text(path['longName'])),
                    DataCell(Text(DateFormat('dd-MM-yyyy').format(parsedDate))),
                    DataCell(Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              _showPathDetailDialog(context, path);
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
                              _showPathDeleteDialog(context, path);
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