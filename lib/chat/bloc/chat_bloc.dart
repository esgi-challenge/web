import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:web/core/services/chat_service.dart';
import 'package:web/shared/toaster.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChannelBloc extends Bloc<ChannelEvent, ChannelState> {
  final ChatService chatService;
  List<dynamic>? originalChannels;
  List<dynamic>? originalStudents;

  ChannelBloc(this.chatService) : super(ChannelInitial()) {
    on<LoadChannels>((event, emit) async {
      emit(ChannelLoading());
      try {
        final channels = await chatService.getChannels();
        final students = await chatService.getStudents();

        if (channels != null && channels.isNotEmpty) {
          originalChannels = channels;
          originalStudents = students;
          emit(ChannelLoaded(channels: channels, students: students!));
        } else if (students != null && students.isNotEmpty) {
          originalStudents = students;
          originalChannels ??= [];
          emit(ChannelLoaded(channels: originalChannels!, students: students));
        } else {
          originalStudents ??= [];
          originalChannels ??= [];
          emit(ChannelLoaded(channels: originalChannels!, students: originalStudents!));
        }
      } on Exception catch (e) {
        emit(ChannelError(errorMessage: e.toString()));
      }
    });

    on<SearchStudents>((event, emit) {
      if (originalStudents == null) return;

      final query = event.query.toLowerCase();
      final filteredStudents = originalStudents!.where((student) {
        return student['lastname'].toLowerCase().startsWith(query);
      }).toList();

      emit(ChannelLoaded(channels: originalChannels!, students: filteredStudents));
    });

    on<AddChannel>((event, emit) async {
      emit(ChannelLoading());
      try {
        final channel = await chatService.addChannel(event.studentId);

        if (channel != null) {
          emit(ChannelAdded(channelId: channel['id']));
        }
      } on Exception catch (e) {
        showErrorToast("Erreur: ${e.toString()}");
        originalChannels ??= [];
        emit(ChannelLoaded(channels: originalChannels!, students: originalStudents!));
      }
    });
  }
}
