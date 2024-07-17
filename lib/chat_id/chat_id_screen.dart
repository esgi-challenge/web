import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web/chat_id/bloc/chat_id_bloc.dart';
import 'package:web/core/services/auth_services.dart';
import 'package:web/core/services/chat_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChannelIdScreen extends StatefulWidget {
  final int id;

  const ChannelIdScreen({super.key, required this.id});

  @override
  _ChannelIdScreenState createState() => _ChannelIdScreenState();
}

class _ChannelIdScreenState extends State<ChannelIdScreen> {
  late WebSocketChannel channel;
  late TextEditingController messageController;
  late ScrollController _scrollController;
  late int userId;

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController();
    _scrollController = ScrollController();
    String? wsUrl = dotenv.env['WS_URL'];

    Map<String, dynamic> decodedToken = JwtDecoder.decode(AuthService.jwt!);
    userId = decodedToken['user']['id'];
    log("ANTOINE");
    log("wsUrl");
    channel = WebSocketChannel.connect(
      Uri.parse('$wsUrl/api/ws/chat/${widget.id}'),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    channel.sink.close();
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (messageController.text.isNotEmpty) {
      String token = AuthService.jwt!;
      final msg = {'content': messageController.text, 'jwt': token};
      channel.sink.add(json.encode(msg));
      messageController.clear();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 50,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ChannelIdBloc(ChatService())..add(LoadChannelId(widget.id)),
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(245, 242, 249, 1),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const HeroIcon(HeroIcons.arrowLongLeft,
                color: Color.fromRGBO(247, 159, 2, 1), size: 32),
            onPressed: () {
              GoRouter router = GoRouter.of(context);
              router.go('/chat');
            },
          ),
          title: BlocBuilder<ChannelIdBloc, ChannelIdState>(
            builder: (context, state) {
              if (state is ChannelIdLoaded) {
                var otherUser = state.channelId['firstUser']['id'] == userId
                    ? state.channelId['secondUser']
                    : state.channelId['firstUser'];
                return Text(
                  "${otherUser['firstname']} ${otherUser['lastname']}",
                  style: const TextStyle(
                    color: Color.fromRGBO(109, 53, 172, 1),
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                  ),
                );
              }
              return const Text('Chat',
                  style: TextStyle(
                      color: Color.fromRGBO(109, 53, 172, 1), fontSize: 32));
            },
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<ChannelIdBloc, ChannelIdState>(
          builder: (context, state) {
            if (state is ChannelIdInitial || state is ChannelIdLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ChannelIdLoaded) {
              var messages = state.channelId['messages'];
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _scrollToBottom());
              return Column(
                children: [
                  Expanded(
                    child: StreamBuilder(
                      stream: channel.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var data = json.decode(snapshot.data as String);
                          messages.add({
                            'content': data['content'],
                            'senderId': data['senderId'],
                            'createdAt': data['createdAt'],
                          });
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) => _scrollToBottom());
                        }
                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32.0, vertical: 32.0),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            var message = messages[index];
                            var isOwnMessage = message['senderId'] == userId;
                            return Column(
                              crossAxisAlignment: isOwnMessage
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: isOwnMessage
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(maxWidth: 230),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: isOwnMessage
                                                ? const Color.fromRGBO(
                                                    72, 2, 151, 1)
                                                : const Color.fromRGBO(
                                                    249, 178, 53, 1),
                                            borderRadius: BorderRadius.only(
                                              topLeft: const Radius.circular(8),
                                              topRight:
                                                  const Radius.circular(8),
                                              bottomLeft: isOwnMessage
                                                  ? const Radius.circular(8)
                                                  : Radius.zero,
                                              bottomRight: isOwnMessage
                                                  ? Radius.zero
                                                  : const Radius.circular(8),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              crossAxisAlignment: isOwnMessage
                                                  ? CrossAxisAlignment.end
                                                  : CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  message['content'],
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                  softWrap: true,
                                                  overflow: TextOverflow.clip,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "${message['createdAt'].substring(8, 10)}/${message['createdAt'].substring(5, 7)}/${message['createdAt'].substring(0, 4)} - ${message['createdAt'].substring(11, 16)}",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      child: Row(
                        children: [
                          Flexible(
                            child: TextField(
                              controller: messageController,
                              decoration: const InputDecoration(
                                hintText: "Votre message...",
                                hintStyle: TextStyle(
                                  color: Color.fromRGBO(141, 143, 142, 1),
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16.0),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const HeroIcon(
                              HeroIcons.paperAirplane,
                              color: Color.fromRGBO(72, 2, 151, 1),
                            ),
                            onPressed: _sendMessage,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else if (state is ChannelIdError) {
              return Center(child: Text('Erreur: ${state.errorMessage}'));
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
