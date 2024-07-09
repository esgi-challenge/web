part of 'chat_bloc.dart';

@immutable
abstract class ChannelEvent {}

class LoadChannels extends ChannelEvent {}

class AddChannel extends ChannelEvent {
  final int studentId;

  AddChannel(this.studentId);
}

class SearchStudents extends ChannelEvent {
  final String query;

  SearchStudents(this.query);
}