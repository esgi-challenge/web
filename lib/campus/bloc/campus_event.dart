part of 'campus_bloc.dart';

@immutable
abstract class CampusEvent {}

class LoadCampus extends CampusEvent {}

class DeleteCampus extends CampusEvent {
  final int id;

  DeleteCampus(this.id);
}

class AddCampus extends CampusEvent {
  final double latitude;
  final double longitude;
  final String location;
  final String name;

  AddCampus(this.latitude, this.longitude, this.location, this.name);
}

class UpdateCampus extends CampusEvent {
  final int id;
  final double latitude;
  final double longitude;
  final String location;
  final String name;

  UpdateCampus(this.id, this.latitude, this.longitude, this.location, this.name);
}