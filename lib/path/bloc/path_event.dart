part of 'path_bloc.dart';

@immutable
abstract class PathEvent {}

class LoadPaths extends PathEvent {}

class DeletePath extends PathEvent {
  final int id;

  DeletePath(this.id);
}

class AddPath extends PathEvent {
  final String shortName;
  final String longName;

  AddPath(this.shortName, this.longName);
}

class UpdatePath extends PathEvent {
  final int id;
  final String shortName;
  final String longName;

  UpdatePath(this.id, this.shortName, this.longName);
}