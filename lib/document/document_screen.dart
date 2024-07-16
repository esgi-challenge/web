import 'dart:html' as html;

import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons/heroicons.dart';
import 'package:web/core/services/auth_services.dart';
import 'package:web/core/services/document_service.dart';
import 'package:web/core/services/course_service.dart';
import 'package:web/document/bloc/document_bloc.dart';
import 'package:intl/intl.dart';
import 'package:web/shared/input_validator.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:web/shared/toaster.dart';

class DocumentScreen extends StatelessWidget {
  DocumentScreen({super.key});

  final _nameController = TextEditingController();

  final GlobalKey<FormState> _createFormKey = GlobalKey<FormState>();

  String? _selectedPathId;

  Future<int> _getUserKind() async {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(AuthService.jwt!);
    int userKind = decodedToken['user']['userKind'];
    return userKind;
  }

  void _clearInputs() {
    _nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DocumentBloc(DocumentService(), CourseService())..add(LoadDocuments()),
      child: Scaffold(
        appBar: AppBar(
          title: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HeroIcon(
                    HeroIcons.document,
                    color: Color.fromRGBO(72, 2, 151, 1),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Documents',
                    style: TextStyle(
                      color: Color.fromRGBO(72, 2, 151, 1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          toolbarHeight: 64.0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 50),
                  BlocBuilder<DocumentBloc, DocumentState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: () {
                          if (state is DocumentLoaded && state.courses.isNotEmpty) {
                            _showCreateDialog(context, state.courses);
                          } else if (state is DocumentNotFound && state.courses.isNotEmpty) {
                            _showCreateDialog(context, state.courses);
                          } else {
                            _showEmptyDialog(context);
                          }
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
                  )
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<DocumentBloc, DocumentState>(
                  builder: (context, state) {
                    if (state is DocumentLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is DocumentLoaded) {
                      return _buildDocumentTable(context, state.documents);
                    } else if (state is DocumentNotFound) {
                      return const Center(child: Text('Aucun document dans cette école'));
                    } else if (state is DocumentError) {
                      return Center(child: Text('Erreur: ${state.errorMessage}'));
                    } else {
                      return const Center(child: Text('Cours'));
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

  void _showEmptyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Ajouter un cours'),
          content: const Text("Des cours sont nécessaires avant d'ajouter un document"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Fermer', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

   void _showCreateDialog(BuildContext context, dynamic courses) async {
    final userKind = await _getUserKind();
    Uint8List? selectedFileBytes;
    String? selectedFileName;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<DocumentBloc>(context),
          child: Builder(
            builder: (context) {
              return AlertDialog(
                title: const Text('Ajouter un document'),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: Form(
                    key: _createFormKey,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: 'Nom'),
                            validator: InputValidator.validateName,
                          ),
                          const SizedBox(height: 16),
                          if (userKind != 2)
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(labelText: 'Cours'),
                              value: _selectedPathId,
                              items: courses.map<DropdownMenuItem<String>>((course) {
                                return DropdownMenuItem<String>(
                                  value: course['id'].toString(),
                                  child: Text(course['name'].isNotEmpty ? course['name'] : 'N/A'),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                _selectedPathId = newValue;
                              },
                              validator: (value) => value == null ? 'Sélectionnez un cours' : null,
                            ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () async {
                              final result = await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf'],
                              );
                              if (result != null) {
                                final file = result.files.single;
                                if (file.size <= 500 * 1024 * 1024) {
                                  selectedFileBytes = file.bytes;
                                  selectedFileName = file.name;
                                } else {
                                  showErrorToast("Le fichier ne doit pas dépasser 500 Mo");
                                }
                              }
                            },
                            child: const Text('Sélectionner un fichier'),
                          ),
                          if (selectedFileName != null)
                            Text(selectedFileName!),
                        ],
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
                      if (_createFormKey.currentState!.validate() && selectedFileBytes != null) {
                        context.read<DocumentBloc>().add(AddDocument(
                          _nameController.text,
                          userKind == 2 ? null : int.parse(_selectedPathId!),
                          selectedFileBytes!,
                          selectedFileName!,
                        ));
                        _clearInputs();
                        Navigator.of(context).pop();
                      } else if (selectedFileBytes == null) {
                        showErrorToast("Veuillez sélectionner un fichier");
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


  void _showDocumentDeleteDialog(BuildContext context, dynamic document) {
    String name = document['name'];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<DocumentBloc>(context),
          child: Builder(
            builder: (context) {
              return AlertDialog(
                content: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Voulez vous vraiment supprimer le cours $name ?')
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
                      context.read<DocumentBloc>().add(DeleteDocument(document['id']));
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

  Widget _buildDocumentTable(BuildContext context, List<dynamic> documents) {
    return SizedBox(
      width: double.infinity,
      child: BlocBuilder<DocumentBloc, DocumentState>(
        builder: (context, state) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(
                    label: Text('Nom',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color.fromRGBO(72, 2, 151, 1)
                        )
                    )
                ),
                DataColumn(
                    label: Text('Cours',
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
              rows: documents.map((document) {
                DateTime parsedDate = DateTime.parse(document['createdAt']);
                final courseName = (document['course'] != null && document['course']['name'].isNotEmpty)
                    ? document['course']['name']
                    : 'N/A';

                return DataRow(
                  cells: [
                    DataCell(Text(document['name'])),
                    DataCell(Text(courseName)),
                    DataCell(Text(DateFormat('dd-MM-yyyy').format(parsedDate))),
                    DataCell(Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _downloadDocument(document['path']);
                          },
                          child: const HeroIcon(
                            HeroIcons.arrowDownTray,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            _showDocumentDeleteDialog(context, document);
                          },
                          child: const HeroIcon(
                            HeroIcons.trash,
                            color: Colors.red,
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
      ),
    );
  }

  void _downloadDocument(String path) {
    final url = 'https://storage.googleapis.com/challenge-esgi-preprod-storage/$path';
    html.AnchorElement anchorElement = html.AnchorElement(href: url)
    ..target = 'blank';
    anchorElement.click();
  }
}