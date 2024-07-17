import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:web/core/services/campus_service.dart';
import 'package:web/core/services/class_service.dart';
import 'package:web/core/services/course_service.dart';
import 'package:web/core/services/schedule_service.dart';
import 'package:web/schedule/bloc/schedule_bloc.dart';

class ScheduleIdScreen extends StatelessWidget {
  final int scheduleId;
  ScheduleIdScreen({super.key, required this.scheduleId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScheduleBloc(
          ScheduleService(), CourseService(), CampusService(), ClassService())
        ..add(LoadSchedule(scheduleId)),
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
              router.go('/schedules');
            },
          ),
          title: const Text(
            "Signature",
            style: TextStyle(
              color: Color.fromRGBO(72, 2, 151, 1),
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          toolbarHeight: 64.0,
        ),
        body: BlocBuilder<ScheduleBloc, ScheduleState>(
          builder: (context, state) {
            if (state is ScheduleInitial || state is ScheduleLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ScheduleLoaded) {
              // return Column(
              //   children: [
              //     Expanded(
              //       child: StreamBuilder(
              //         stream: channel.stream,
              //         builder: (context, snapshot) {
              //           if (snapshot.hasData) {
              //             var data = json.decode(snapshot.data as String);
              //             messages.add({
              //               'content': data['content'],
              //               'senderId': data['senderId'],
              //               'createdAt': data['createdAt'],
              //             });
              //             WidgetsBinding.instance
              //                 .addPostFrameCallback((_) => _scrollToBottom());
              //           }
              //           return ListView.builder(
              //             controller: _scrollController,
              //             padding: const EdgeInsets.symmetric(
              //                 horizontal: 32.0, vertical: 32.0),
              //             itemCount: messages.length,
              //             itemBuilder: (context, index) {
              //               var message = messages[index];
              //               var isOwnMessage = message['senderId'] == userId;
              //               return Column(
              //                 crossAxisAlignment: isOwnMessage
              //                     ? CrossAxisAlignment.end
              //                     : CrossAxisAlignment.start,
              //                 children: [
              //                   const SizedBox(height: 16),
              //                   Row(
              //                     mainAxisAlignment: isOwnMessage
              //                         ? MainAxisAlignment.end
              //                         : MainAxisAlignment.start,
              //                     crossAxisAlignment: CrossAxisAlignment.end,
              //                     children: [
              //                       const SizedBox(width: 8),
              //                       Flexible(
              //                         child: ConstrainedBox(
              //                           constraints:
              //                               const BoxConstraints(maxWidth: 230),
              //                           child: Container(
              //                             decoration: BoxDecoration(
              //                               color: isOwnMessage
              //                                   ? const Color.fromRGBO(
              //                                       72, 2, 151, 1)
              //                                   : const Color.fromRGBO(
              //                                       249, 178, 53, 1),
              //                               borderRadius: BorderRadius.only(
              //                                 topLeft: const Radius.circular(8),
              //                                 topRight:
              //                                     const Radius.circular(8),
              //                                 bottomLeft: isOwnMessage
              //                                     ? const Radius.circular(8)
              //                                     : Radius.zero,
              //                                 bottomRight: isOwnMessage
              //                                     ? Radius.zero
              //                                     : const Radius.circular(8),
              //                               ),
              //                             ),
              //                             child: Padding(
              //                               padding: const EdgeInsets.all(10.0),
              //                               child: Column(
              //                                 crossAxisAlignment: isOwnMessage
              //                                     ? CrossAxisAlignment.end
              //                                     : CrossAxisAlignment.start,
              //                                 children: [
              //                                   Text(
              //                                     message['content'],
              //                                     style: const TextStyle(
              //                                       color: Colors.white,
              //                                       fontSize: 14,
              //                                     ),
              //                                     softWrap: true,
              //                                     overflow: TextOverflow.clip,
              //                                   ),
              //                                   const SizedBox(height: 4),
              //                                   Text(
              //                                     "${message['createdAt'].substring(8, 10)}/${message['createdAt'].substring(5, 7)}/${message['createdAt'].substring(0, 4)} - ${message['createdAt'].substring(11, 16)}",
              //                                     style: const TextStyle(
              //                                       color: Colors.white,
              //                                       fontSize: 10,
              //                                     ),
              //                                   ),
              //                                 ],
              //                               ),
              //                             ),
              //                           ),
              //                         ),
              //                       ),
              //                       const SizedBox(width: 8),
              //                     ],
              //                   ),
              //                   const SizedBox(height: 16),
              //                 ],
              //               );
              //             },
              //           );
              //         },
              //       ),
              //     ),
              //     Padding(
              //       padding: const EdgeInsets.symmetric(vertical: 16.0),
              //       child: Container(
              //         decoration: const BoxDecoration(
              //           color: Colors.white,
              //           borderRadius: BorderRadius.all(Radius.circular(50)),
              //         ),
              //         child: Row(
              //           children: [
              //             Flexible(
              //               child: TextField(
              //                 controller: messageController,
              //                 decoration: const InputDecoration(
              //                   hintText: "Votre message...",
              //                   hintStyle: TextStyle(
              //                     color: Color.fromRGBO(141, 143, 142, 1),
              //                   ),
              //                   border: InputBorder.none,
              //                   contentPadding:
              //                       EdgeInsets.symmetric(horizontal: 16.0),
              //                 ),
              //               ),
              //             ),
              //             IconButton(
              //               icon: const HeroIcon(
              //                 HeroIcons.paperAirplane,
              //                 color: Color.fromRGBO(72, 2, 151, 1),
              //               ),
              //               onPressed: _sendMessage,
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ],
              // );
            } else if (state is ScheduleError) {
              return Center(child: Text('Erreur: ${state.errorMessage}'));
            } else if (state is ScheduleSignatures) {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32.0, vertical: 32.0),
                itemCount: state.signatures['students'].length,
                itemBuilder: (context, index) {
                  final student = state.signatures['students'][index];

                  var isSigned = false;

                  state.signatures['signatures'].forEach((signature) => {
                        if (signature['studentId'] == student['id'])
                          {isSigned = true}
                      });

                  return Column(
                    children: [
                      Signature(
                          code: state.code,
                          scheduleId: scheduleId,
                          studentId: student['id'],
                          name:
                              "${student['firstname']} ${student['lastname']}",
                          isSigned: isSigned),
                      const SizedBox(
                        height: 8,
                      ),
                    ],
                  );
                },
              );
            }

            return Container();
          },
        ),
      ),
    );
  }
}

class Signature extends StatelessWidget {
  final String name;
  final int studentId;
  final int scheduleId;
  final String code;
  final bool isSigned;
  const Signature(
      {super.key,
      required this.name,
      required this.isSigned,
      required this.studentId,
      required this.scheduleId,
      required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(50, 50, 50, 0.1),
            spreadRadius: 0,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name),
            ElevatedButton(
              onPressed: () {
                if (!isSigned) {
                  context.read<ScheduleBloc>().add(
                        SignSchedule(
                          scheduleId: scheduleId,
                          studentId: studentId,
                          code: code,
                        ),
                      );
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color.fromRGBO(247, 159, 2, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text('Ajouter'),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              decoration: BoxDecoration(
                color: isSigned ? Color.fromRGBO(191, 255, 189, 1) : Color.fromRGBO(255, 201, 201, 1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                isSigned ? "Présent" : "Absent",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSigned ? Color.fromRGBO(42, 153, 40, 1) : Color.fromRGBO(255, 56, 46, 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
