import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:web/chat_id/bloc/chat_id_bloc.dart';
import 'package:web/core/services/auth_services.dart';
import 'package:web/core/services/chat_service.dart';

class ChannelIdScreen extends StatelessWidget {
  final int id;

  ChannelIdScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(AuthService.jwt!);
    int userId = decodedToken['user']['id'];

    final TextEditingController messageController = TextEditingController();

    return BlocProvider(
      create: (context) => ChannelIdBloc(ChatService())..add(LoadChannelId(id)),
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(245, 242, 249, 1),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const HeroIcon(HeroIcons.arrowLongLeft, color: Color.fromRGBO(247, 159, 2, 1), size: 32),
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
              return const Text('Chat', style: TextStyle(color: Color.fromRGBO(109, 53, 172, 1), fontSize: 32));
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
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        var message = messages[index];
                        var isOwnMessage = message['senderId'] == userId;
                        return Column(
                          crossAxisAlignment:
                              isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment:
                                  isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const SizedBox(width: 8),
                                Flexible(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 230),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isOwnMessage
                                            ? const Color.fromRGBO(72, 2, 151, 1)
                                            : const Color.fromRGBO(249, 178, 53, 1),
                                        borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(8),
                                          topRight: const Radius.circular(8),
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
                                          crossAxisAlignment:
                                              isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const HeroIcon(
                              HeroIcons.paperAirplane,
                              color: Color.fromRGBO(72, 2, 151, 1),
                            ),
                            onPressed: () {
                              String messageContent = messageController.text;
                              if (messageContent.isNotEmpty) {
                                print(messageContent);
                                messageController.clear();
                              }
                            },
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