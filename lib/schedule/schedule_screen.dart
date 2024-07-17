import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:web/core/services/campus_service.dart';
import 'package:web/core/services/class_service.dart';
import 'package:web/core/services/course_service.dart';
import 'package:web/core/services/schedule_service.dart';
import 'package:web/schedule/bloc/schedule_bloc.dart';
import 'package:web/shared/input_validator.dart';

class ScheduleScreen extends StatelessWidget {
  ScheduleScreen({super.key});

  final GlobalKey<FormState> _createFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _updateFormKey = GlobalKey<FormState>();

  String? _selectedCourseId;
  String? _selectedCampusId;
  String? _selectedClassId;
  DateTime? _selectedTime;

  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  void _clearInputs() {
    _selectedCampusId = null;
    _selectedCourseId = null;
    _selectedClassId = null;
    _timeController.clear();
    _durationController.clear();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );
      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        _selectedTime = selectedDateTime;
        _timeController.text = selectedDateTime.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScheduleBloc(
          ScheduleService(), CourseService(), CampusService(), ClassService())
        ..add(LoadSchedules()),
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              HeroIcon(
                HeroIcons.calendarDays,
                color: Color.fromRGBO(72, 2, 151, 1),
              ),
              SizedBox(width: 8),
              Text(
                'Emplois du temps',
                style: TextStyle(
                  color: Color.fromRGBO(72, 2, 151, 1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            BlocBuilder<ScheduleBloc, ScheduleState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: () {
                    if (state is ScheduleLoaded &&
                        state.courses.isNotEmpty &&
                        state.campuses.isNotEmpty &&
                        state.classes.isNotEmpty) {
                      _showCreateDialog(context, state.courses,
                          state.campuses, state.classes);
                    } else if (state is ScheduleNotFound &&
                        state.courses.isNotEmpty &&
                        state.campuses.isNotEmpty &&
                        state.classes.isNotEmpty) {
                      _showCreateDialog(context, state.courses,
                          state.campuses, state.classes);
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
                  child:
                  const Text('Créer', style: TextStyle(fontSize: 16)),
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
                child: BlocBuilder<ScheduleBloc, ScheduleState>(
                  builder: (context, state) {
                    if (state is ScheduleLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ScheduleLoaded) {
                      return _buildScheduleTable(context, state.schedules);
                    } else if (state is ScheduleNotFound) {
                      return const Center(
                          child: Text('Aucun créneau d\'ajouté'));
                    } else if (state is ScheduleError) {
                      return Center(
                          child: Text('Erreur: ${state.errorMessage}'));
                    } else {
                      return const Center(child: Text('Emplois du temps'));
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
          title: const Text('Ajouter un créneau'),
          content: const Text(
              "Pour créer des créneaux vous devez avoir au moins un cours, un campus et une classe"),
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

  void _showCreateDialog(BuildContext context, dynamic courses,
      dynamic campuses, dynamic classes) {
    bool _qrCodeEnabled = false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<ScheduleBloc>(context),
          child: StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Ajouter un créneau'),
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
                            DropdownButtonFormField<String>(
                              decoration:
                                  const InputDecoration(labelText: 'Cours'),
                              value: _selectedCourseId,
                              items:
                                  courses.map<DropdownMenuItem<String>>((course) {
                                return DropdownMenuItem<String>(
                                  value: course['id'].toString(),
                                  child: Text(course['name'].isNotEmpty
                                      ? course['name']
                                      : 'N/A'),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                _selectedCourseId = newValue;
                              },
                              validator: (value) =>
                                  value == null ? 'Sélectionnez un cours' : null,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              decoration:
                                  const InputDecoration(labelText: 'Campus'),
                              value: _selectedCampusId,
                              items: campuses
                                  .map<DropdownMenuItem<String>>((campus) {
                                return DropdownMenuItem<String>(
                                  value: campus['id'].toString(),
                                  child: Text(campus['name'].isNotEmpty
                                      ? campus['name']
                                      : 'N/A'),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                _selectedCampusId = newValue;
                              },
                              validator: (value) =>
                                  value == null ? 'Sélectionnez un campus' : null,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              decoration:
                                  const InputDecoration(labelText: 'Classe'),
                              value: _selectedClassId,
                              items: classes
                                  .map<DropdownMenuItem<String>>((classSchool) {
                                return DropdownMenuItem<String>(
                                  value: classSchool['id'].toString(),
                                  child: Text(classSchool['name'].isNotEmpty
                                      ? classSchool['name']
                                      : 'N/A'),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                _selectedClassId = newValue;
                              },
                              validator: (value) => value == null
                                  ? 'Sélectionnez une classe'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Date'),
                              readOnly: true,
                              onTap: () => _selectDateTime(context),
                              validator: (value) => _selectedTime == null
                                  ? 'Sélectionnez une date'
                                  : null,
                              controller: _timeController,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: const InputDecoration(
                                  labelText: 'Durée (minutes)'),
                              controller: _durationController,
                              validator: InputValidator.validateOnlyNumbers,
                            ),
                            const SizedBox(height: 16),
                            CheckboxListTile(
                              title: const Text('Activer le QR Code pour appel'),
                              value: _qrCodeEnabled,
                              onChanged: (bool? newValue) {
                                setState(() {
                                  _qrCodeEnabled = newValue!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
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
                      if (_createFormKey.currentState!.validate()) {
                        context.read<ScheduleBloc>().add(AddSchedule(
                            _selectedTime!.millisecondsSinceEpoch ~/ 1000,
                            int.parse(_durationController.text),
                            int.parse(_selectedCourseId!),
                            int.parse(_selectedCampusId!),
                            int.parse(_selectedClassId!),
                            _qrCodeEnabled));
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

  void _showQrCode(BuildContext context, int scheduleId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider(
          create: (context) => ScheduleBloc(ScheduleService(), CourseService(),
              CampusService(), ClassService())
            ..add(LoadScheduleCode(scheduleId)),
          child: AlertDialog(
            title: const Text('QRCode de Signature'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: BlocBuilder<ScheduleBloc, ScheduleState>(
                builder: (context, state) {
                  if (state is ScheduleLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is ScheduleCode) {
                    return QrImageView(
                      data: state.code,
                      version: QrVersions.auto,
                      size: 200.0,
                    );
                  }

                  return Container();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showScheduleDetailDialog(BuildContext context, dynamic schedule) {
    final ScheduleBloc scheduleBloc = BlocProvider.of<ScheduleBloc>(context);
    final ScheduleState currentState = scheduleBloc.state;

    if (currentState is ScheduleLoaded) {
      final courseExists = currentState.courses
          .any((course) => course['id'] == schedule['courseId']);
      _selectedCourseId = courseExists ? schedule['courseId'].toString() : null;
      final campusExists = currentState.campuses
          .any((campus) => campus['id'] == schedule['campusId']);
      _selectedCampusId = campusExists ? schedule['campusId'].toString() : null;
      final classExists = currentState.classes
          .any((classSchool) => classSchool['id'] == schedule['classId']);
      _selectedClassId = classExists ? schedule['classId'].toString() : null;
    } else {
      _selectedCourseId = null;
      _selectedCampusId = null;
      _selectedClassId = null;
    }

    bool _qrCodeEnabled = schedule['qrCodeEnabled'] ?? false;

    _timeController.text =
        DateTime.fromMillisecondsSinceEpoch(schedule['time'] * 1000)
            .toLocal()
            .toString();
    _selectedTime =
        DateTime.fromMillisecondsSinceEpoch(schedule['time'] * 1000);
    _durationController.text = schedule['duration'].toString();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<ScheduleBloc>(context),
          child: StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Détails du créneau'),
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: BlocBuilder<ScheduleBloc, ScheduleState>(
                      builder: (context, state) {
                        if (state is ScheduleLoaded) {
                          return Form(
                            key: _updateFormKey,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  DropdownButtonFormField<String>(
                                    decoration:
                                        const InputDecoration(labelText: 'Cours'),
                                    value: _selectedCourseId,
                                    items: state.courses
                                        .map<DropdownMenuItem<String>>((course) {
                                      return DropdownMenuItem<String>(
                                        value: course['id'].toString(),
                                        child: Text(course['name'].isNotEmpty
                                            ? course['name']
                                            : 'N/A'),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      _selectedCourseId = newValue;
                                    },
                                    validator: (value) => value == null
                                        ? 'Sélectionnez un cours'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                        labelText: 'Campus'),
                                    value: _selectedCampusId,
                                    items: state.campuses
                                        .map<DropdownMenuItem<String>>((campus) {
                                      return DropdownMenuItem<String>(
                                        value: campus['id'].toString(),
                                        child: Text(campus['name'].isNotEmpty
                                            ? campus['name']
                                            : 'N/A'),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      _selectedCampusId = newValue;
                                    },
                                    validator: (value) => value == null
                                        ? 'Sélectionnez un campus'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                        labelText: 'Classe'),
                                    value: _selectedClassId,
                                    items: state.classes
                                        .map<DropdownMenuItem<String>>(
                                            (classSchool) {
                                      return DropdownMenuItem<String>(
                                        value: classSchool['id'].toString(),
                                        child: Text(classSchool['name'].isNotEmpty
                                            ? classSchool['name']
                                            : 'N/A'),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      _selectedClassId = newValue;
                                    },
                                    validator: (value) => value == null
                                        ? 'Sélectionnez une classe'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    decoration:
                                        const InputDecoration(labelText: 'Date'),
                                    readOnly: true,
                                    onTap: () => _selectDateTime(context),
                                    validator: (value) => _selectedTime == null
                                        ? 'Sélectionnez une date'
                                        : null,
                                    controller: _timeController,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                        labelText: 'Durée (minutes)'),
                                    controller: _durationController,
                                    validator: InputValidator.validateOnlyNumbers,
                                  ),
                                  const SizedBox(height: 16),
                                  CheckboxListTile(
                                    title: const Text('Activer QR Code'),
                                    value: _qrCodeEnabled,
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        _qrCodeEnabled = newValue!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                  )
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
                        context.read<ScheduleBloc>().add(UpdateSchedule(
                            schedule['id'],
                            _selectedTime!.millisecondsSinceEpoch ~/ 1000,
                            int.parse(_durationController.text),
                            int.parse(_selectedCourseId!),
                            int.parse(_selectedCampusId!),
                            int.parse(_selectedClassId!),
                            _qrCodeEnabled));
                        _clearInputs();
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Modifier'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showScheduleDeleteDialog(BuildContext context, dynamic schedule) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<ScheduleBloc>(context),
          child: Builder(
            builder: (context) {
              return AlertDialog(
                content: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Voulez-vous vraiment supprimer ce créneau ?')
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
                          .read<ScheduleBloc>()
                          .add(DeleteSchedule(schedule['id']));
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

  Widget _buildScheduleTable(BuildContext context, List<dynamic> schedules) {
    return SizedBox(
      width: double.infinity,
      child: BlocBuilder<ScheduleBloc, ScheduleState>(
        builder: (context, state) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Cours')),
                DataColumn(label: Text('Campus')),
                DataColumn(label: Text('Classe')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Durée')),
                DataColumn(label: Text('')),
                DataColumn(label: Text('')),
                DataColumn(label: Text('')),
                DataColumn(label: Text('')),
              ],
              rows: schedules.map((schedule) {
                final courseName = schedule['course']['name'].isNotEmpty
                    ? schedule['course']['name']
                    : 'N/A';
                final campusName = schedule['campus']['name'].isNotEmpty
                    ? schedule['campus']['name']
                    : 'N/A';
                final className = schedule['class']['name'].isNotEmpty
                    ? schedule['class']['name']
                    : 'N/A';
                final time =
                    DateTime.fromMillisecondsSinceEpoch(schedule['time'] * 1000)
                        .toLocal()
                        .toString();
                final duration = schedule['duration'].toString();

                return DataRow(
                  cells: [
                    DataCell(Text(courseName)),
                    DataCell(Text(campusName)),
                    DataCell(Text(className)),
                    DataCell(Text(time)),
                    DataCell(Text('$duration min')),
                    DataCell(ElevatedButton(
                      onPressed: () {
                        GoRouter.of(context).go('/schedules/${schedule['id']}');
                      },
                      child: const HeroIcon(
                        HeroIcons.userGroup,
                      ),
                    )),
                    DataCell(ElevatedButton(
                      onPressed: () {
                        if (schedule['qrCodeEnabled']) {
                          _showQrCode(context, schedule['id']);
                        }
                      },
                      child: HeroIcon(
                        HeroIcons.qrCode,
                        color: schedule['qrCodeEnabled']
                            ? Colors.black
                            : Colors.grey,
                      ),
                    )),
                    DataCell(ElevatedButton(
                      onPressed: () {
                        _showScheduleDetailDialog(context, schedule);
                      },
                      child: const HeroIcon(
                        HeroIcons.pencil,
                      ),
                    )),
                    DataCell(ElevatedButton(
                      onPressed: () {
                        _showScheduleDeleteDialog(context, schedule);
                      },
                      child: const HeroIcon(
                        HeroIcons.trash,
                        color: Colors.red,
                      ),
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
}
