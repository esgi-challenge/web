part of 'information_bloc.dart';

@immutable
abstract class InformationEvent {}

class LoadInformations extends InformationEvent {}

class DeleteInformation extends InformationEvent {
  final int id;

  DeleteInformation(this.id);
}

class AddInformation extends InformationEvent {
  final String name;
  final String description;

  AddInformation(this.name, this.description);
}