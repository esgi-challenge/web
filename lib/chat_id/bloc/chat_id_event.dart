part of 'chat_id_bloc.dart';

@immutable
abstract class ChannelIdEvent {}

class LoadChannelId extends ChannelIdEvent {
  final int id;

  LoadChannelId(this.id);
}