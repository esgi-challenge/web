part of 'chat_bloc.dart';

@immutable
abstract class ChannelState {}

class ChannelInitial extends ChannelState {}

class ChannelLoading extends ChannelState {}

class ChannelLoaded extends ChannelState {
  final List<dynamic> channels;
  final List<dynamic> students;

  ChannelLoaded({required this.channels, required this.students});
}

class ChannelNotFound extends ChannelState {
  final List<dynamic> students;

  ChannelNotFound({required this.students});
}

class ChannelAdded extends ChannelState {
  final int channelId;

  ChannelAdded({required this.channelId});
}

class ChannelError extends ChannelState {
  final String errorMessage;

  ChannelError({required this.errorMessage});
}