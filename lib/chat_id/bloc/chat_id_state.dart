part of 'chat_id_bloc.dart';

@immutable
abstract class ChannelIdState {}

class ChannelIdInitial extends ChannelIdState {}

class ChannelIdLoading extends ChannelIdState {}

class ChannelIdLoaded extends ChannelIdState {
  final dynamic channelId;

  ChannelIdLoaded({required this.channelId});
}

class ChannelIdNotFound extends ChannelIdState {}

class ChannelIdError extends ChannelIdState {
  final String errorMessage;

  ChannelIdError({required this.errorMessage});
}