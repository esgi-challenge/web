import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heroicons/heroicons.dart';
import 'package:web/core/services/campus_service.dart';
import 'package:web/campus/bloc/campus_bloc.dart';
import 'package:intl/intl.dart';
import 'package:web/shared/input_validator.dart';

class CampusScreen extends StatefulWidget {
  const CampusScreen({super.key});

  @override
  _CampusScreenState createState() => _CampusScreenState();
}

class _CampusScreenState extends State<CampusScreen> {
  late GoogleMapController mapController;

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final GlobalKey<FormState> _createFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _updateFormKey = GlobalKey<FormState>();

  Timer? _debounce;

  void _clearInputs() {
    _nameController.clear();
    _locationController.clear();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CampusBloc(CampusService())..add(LoadCampus()),
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              HeroIcon(
                HeroIcons.buildingOffice,
                color: Color.fromRGBO(72, 2, 151, 1),
              ),
              SizedBox(width: 8),
              Text(
                'Campus',
                style: TextStyle(
                  color: Color.fromRGBO(72, 2, 151, 1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            BlocBuilder<CampusBloc, CampusState>(
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
                  child: const Text('Créer', style: TextStyle(fontSize: 16)),
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
                child: BlocBuilder<CampusBloc, CampusState>(
                  builder: (context, state) {
                    if (state is CampusLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is CampusLoaded) {
                      return _buildCampusTable(context, state.campus);
                    } else if (state is CampusNotFound) {
                      return const Center(
                          child: Text('Aucun campus dans cette école'));
                    } else if (state is CampusError) {
                      return Center(
                          child: Text('Erreur: ${state.errorMessage}'));
                    } else {
                      return const Center(child: Text('Campus'));
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
          value: BlocProvider.of<CampusBloc>(context),
          child: Builder(
            builder: (context) {
              List<dynamic> predictions = [];
              double choosedLatitude = 0.0;
              double choosedLongitude = 0.0;

              return StatefulBuilder(
                builder: (context, setState) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: const Text(
                          'Ajouter un campus',
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
                                      controller: _nameController,
                                      decoration: const InputDecoration(
                                          labelText: 'Nom'),
                                      validator: InputValidator.validateName,
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _locationController,
                                      focusNode: _searchFocusNode,
                                      decoration: const InputDecoration(
                                          labelText: 'Localisation'),
                                      onChanged: (query) {
                                        if (_debounce?.isActive ?? false)
                                          _debounce?.cancel();
                                        _debounce = Timer(
                                            const Duration(milliseconds: 600),
                                            () async {
                                          if (query.trim().isNotEmpty) {
                                            final response =
                                                await CampusService()
                                                    .getLocationPredictions(
                                                        query);
                                            setState(() {
                                              predictions = response;
                                            });
                                          } else {
                                            setState(() {
                                              predictions.clear();
                                            });
                                          }
                                        });
                                      },
                                    ),
                                    if (predictions.isNotEmpty)
                                      SizedBox(
                                        height: 250,
                                        width: 300,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          padding: const EdgeInsets.all(8),
                                          itemCount: predictions.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            final prediction =
                                                predictions[index];
                                            return ListTile(
                                              title: Text(
                                                  prediction['description']),
                                              onTap: () {
                                                setState(() {
                                                  predictions.clear();
                                                });

                                                _locationController.text =
                                                    prediction['description'];
                                                choosedLatitude =
                                                    prediction['latitude'];
                                                choosedLongitude =
                                                    prediction['longitude'];
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Annuler'),
                            onPressed: () {
                              _clearInputs();
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Ajouter'),
                            onPressed: () {
                              if (_createFormKey.currentState!.validate()) {
                                context.read<CampusBloc>().add(AddCampus(
                                      choosedLatitude,
                                      choosedLongitude,
                                      _locationController.text,
                                      _nameController.text,
                                    ));
                                _clearInputs();
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showCampusDetailDialog(BuildContext context, dynamic campus) {
    _nameController.text = campus['name'];
    final location = campus['location'];
    final latitude = campus['latitude'];
    final longitude = campus['longitude'];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
            value: BlocProvider.of<CampusBloc>(context),
            child: Builder(
              builder: (context) {
                return AlertDialog(
                  title: const Text(
                    'Détails du campus',
                    style: TextStyle(
                      color: Color.fromRGBO(72, 2, 151, 1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Form(
                      key: _updateFormKey,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration:
                                  const InputDecoration(labelText: 'Nom'),
                              validator: InputValidator.validateName,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Localisation: $location',
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                                height: 400,
                                width: 1000,
                                child: GoogleMap(
                                  onMapCreated: _onMapCreated,
                                  initialCameraPosition: CameraPosition(
                                      target: LatLng(latitude, longitude),
                                      zoom: 11.0),
                                  markers: {
                                    Marker(
                                        markerId: MarkerId(location),
                                        position: LatLng(latitude, longitude))
                                  },
                                ))
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
                      child: const Text('Fermer',
                          style: TextStyle(color: Colors.red)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_updateFormKey.currentState!.validate()) {
                          context.read<CampusBloc>().add(UpdateCampus(
                                campus['id'],
                                campus['latitude'],
                                campus['longitude'],
                                campus['location'],
                                _nameController.text,
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
            ));
      },
    );
  }

  void _showCampusDeleteDialog(BuildContext context, dynamic campus) {
    String name = campus['name'];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<CampusBloc>(context),
          child: Builder(
            builder: (context) {
              return AlertDialog(
                content: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Voulez vous vraiment supprimer le campus $name ?')
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Annuler',
                        style: TextStyle(color: Colors.red)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<CampusBloc>()
                          .add(DeleteCampus(campus['id']));
                      Navigator.of(context).pop();
                    },
                    child: const Text('Supprimer',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCampusTable(BuildContext context, List<dynamic> campuss) {
    return SizedBox(
        width: double.infinity,
        child: BlocBuilder<CampusBloc, CampusState>(
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
                              color: Color.fromRGBO(72, 2, 151, 1)))),
                  DataColumn(
                      label: Text('Localisation',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color.fromRGBO(72, 2, 151, 1)))),
                  DataColumn(
                      label: Text('Date de création',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color.fromRGBO(72, 2, 151, 1)))),
                  DataColumn(label: Text('')),
                ],
                rows: campuss.map((campus) {
                  DateTime parsedDate = DateTime.parse(campus['createdAt']);
                  return DataRow(
                    cells: [
                      DataCell(Text(campus['name'])),
                      DataCell(Text(campus['location'])),
                      DataCell(
                          Text(DateFormat('dd-MM-yyyy').format(parsedDate))),
                      DataCell(Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                _showCampusDetailDialog(context, campus);
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
                                _showCampusDeleteDialog(context, campus);
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    Color.fromRGBO(249, 141, 53, 1.0),
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
        ));
  }
}
