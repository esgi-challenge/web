import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:web/core/services/auth_services.dart';
import 'package:web/core/services/chat_service.dart';
import 'package:web/chat/bloc/chat_bloc.dart';

class ChannelScreen extends StatelessWidget {
  ChannelScreen({super.key});

  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChannelBloc(ChatService())..add(LoadChannels()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chat'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 50),
                  BlocBuilder<ChannelBloc, ChannelState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: () {
                          if (state is ChannelLoaded) {
                            _showDiscussDialog(context, state.students);
                          }
                        },
                        child: const Text('Discuter'),
                      );
                    },
                  )
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<ChannelBloc, ChannelState>(
                  builder: (context, state) {
                    if (state is ChannelAdded) {
                      GoRouter.of(context).go('/chat/${state.channelId}');
                    } 
                    if (state is ChannelLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ChannelLoaded && state.channels.isNotEmpty) {
                      return _buildChannelTable(context, state.channels);
                    } else if (state is ChannelLoaded && state.channels.isEmpty) {
                      return const Center(child: Text('Aucune discussion en cours'));
                    } else if (state is ChannelError) {
                      return Center(child: Text('Erreur: ${state.errorMessage}'));
                    } else {
                      return const Center(child: Text('Chat'));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDiscussDialog(BuildContext context, List<dynamic> students) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<ChannelBloc>(context),
          child: Builder (
            builder: (context) {
              return AlertDialog(
                title: const Text('Discuter avec un élève'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 300,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Rechercher un élève',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                context.read<ChannelBloc>().add(LoadChannels());
                              },
                            ),
                          ),
                          onChanged: (query) {
                            context.read<ChannelBloc>().add(SearchStudents(query));
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: BlocBuilder<ChannelBloc, ChannelState>(
                          builder: (context, state) {
                            if (students.isEmpty) {
                              return const Center(child: Text('Aucun élève dans cette école'));
                            } else if (state is ChannelLoaded) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(label: Text('Prénom')),
                                      DataColumn(label: Text('Nom')),
                                      DataColumn(label: Text(''))
                                    ],
                                    rows: state.students.map<DataRow>((student) {
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(student['firstname'])),
                                          DataCell(Text(student['lastname'])),
                                          DataCell(ElevatedButton(
                                            onPressed: () {
                                              _searchController.clear();
                                              context.read<ChannelBloc>().add(AddChannel(student['id']));
                                              Navigator.of(context).pop();
                                            },
                                            child: const HeroIcon(
                                              HeroIcons.chatBubbleOvalLeft,
                                            ),
                                          )),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            } else {
                              return const Center(child: CircularProgressIndicator());
                            }
                          },
                        ),
                      ),
                    ],
                  )
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Fermer', style: TextStyle(color: Colors.red)),
                  )
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildChannelTable(BuildContext context, List<dynamic> channels) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(AuthService.jwt!);
    int userId = decodedToken['user']['id'];

    return SizedBox(
      width: double.infinity,
      child: BlocBuilder<ChannelBloc, ChannelState>(
        builder: (context, state) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Utilisateur')),
                DataColumn(label: Text('Dernier message')),
                DataColumn(label: Text(''))
              ],
              rows: channels.map((channel) {
                final channelId = channel["id"];
                final firstUser = channel['firstUser'];
                final secondUser = channel['secondUser'];

                final chatUser = (firstUser['id'] == userId) ? secondUser : firstUser;
                final chatUserName = '${chatUser['firstname']} ${chatUser['lastname']}';

                String lastMessage = "Aucun message envoyé";
                if (channel['messages'].isNotEmpty) {
                  lastMessage = channel['messages'].last['content'];
                  if (lastMessage.length > 40) {
                    lastMessage = '${lastMessage.substring(0, 40)}...';
                  }
                }

                return DataRow(
                  cells: [
                    DataCell(Text(chatUserName)),
                    DataCell(
                      Text(
                        lastMessage,
                        style: TextStyle(color: Colors.black.withOpacity(0.8)),
                      ),
                    ),
                    DataCell(ElevatedButton(
                      onPressed: () {
                        GoRouter.of(context).go('/chat/$channelId');
                      },
                      child: const HeroIcon(
                        HeroIcons.chatBubbleOvalLeft,
                      ),
                    )),
                  ],
                );
              }).toList(),
            ),
          );
        },
      )
    );
  }
}