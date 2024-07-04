part of 'path_bloc.dart';

@immutable
abstract class PathState {}

class PathInitial extends PathState {}

class PathLoading extends PathState {}

class PathLoaded extends PathState {
  final List<dynamic> paths;

  PathLoaded({required this.paths});
}

class PathNotFound extends PathState {}

class PathError extends PathState {
  final String errorMessage;

  PathError({required this.errorMessage});
}