import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:konsul_dosen/features/auth/cubit/auth_cubit.dart';
import 'package:konsul_dosen/features/chat/bloc/chat_cubit.dart';
import 'package:konsul_dosen/features/chat/model/chat.dart';
import 'package:konsul_dosen/features/chat/model/room.dart';
import 'package:konsul_dosen/helpers/dialog.dart';
import 'package:konsul_dosen/helpers/helpers.dart';
import 'package:konsul_dosen/utils/data_state.dart';
import 'package:konsul_dosen/utils/load_status.dart';
import 'package:konsul_dosen/widgets/loading_progress.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(this.uid, {super.key});

  final String uid;
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String? userId;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isLoadingChat = false;

  @override
  void initState() {
    super.initState();
    userId = context.read<AuthCubit>().state.userId;
    initAsync();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  initAsync() async {
    context.read<RoomCubit>().get(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomCubit, DataState<Room>>(builder: (context, state) {
      return Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text('Chat'),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (String result) {
                    switch (result) {
                      case 'End Chat':
                        endChat();
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'End Chat',
                      child: Text('Akhiri Sesi'),
                    ),
                  ],
                )
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('chats')
                          .where('roomId', isEqualTo: widget.uid)
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                              child: Container(
                                  margin: const EdgeInsets.all(16),
                                  child: Text('Error: ${snapshot.error}')));
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final chats = snapshot.data!.docs
                            .map((doc) => doc.data() as Map<String, dynamic>)
                            .toList();

                        return ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          itemCount: chats.length,
                          itemBuilder: (context, index) {
                            final doc = snapshot.data!.docs[index];
                            Chat chat = Chat.fromJson(chats[index])
                                .copyWith(id: doc.id);
                            bool isMe = chat.userId == userId;

                            return ChatItem(isMe: isMe, chat: chat);
                          },
                        );
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Ketik pesan anda...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.surface,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4.0,
                                spreadRadius: 2.0,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.send,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        onPressed: () {
                          if (_controller.text.isNotEmpty) {
                            createMessage(context, userId, _controller.text);
                            setState(() {
                              _controller.clear();
                              _scrollToBottom();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (state.status == LoadStatus.loading) const LoadingProgress(),
        ],
      );
    });
  }

  void createMessage(
      BuildContext context, String? userId, String message) async {
    try {
      if (userId == null) {
        throw Exception('User ID is null');
      }
      setState(() {
        isLoadingChat = true;
      });
      await FirebaseFirestore.instance.collection('chats').add({
        'roomId': widget.uid,
        'userId': userId,
        'chat': message,
        'createdAt': DateTime.now(),
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialogMsg(context, 'Error : ${e.toString()}');
      });
    } finally {
      setState(() {
        isLoadingChat = false;
      });
    }
  }

  void endChat() {
    print('Akhiri Session');
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

class ChatItem extends StatelessWidget {
  const ChatItem({
    super.key,
    required this.isMe,
    required this.chat,
  });

  final bool isMe;
  final Chat chat;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (isMe) {
          showDialogConfirmation(context, () => deleteMessage(context, chat.id),
              title: 'Konfirmasi', message: 'Apakah ingin mengapus data ini?');
        }
      },
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: IntrinsicWidth(
          child: Container(
            margin: isMe
                ? const EdgeInsets.fromLTRB(50, 8, 16, 4)
                : const EdgeInsets.fromLTRB(16, 8, 50, 4),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              color: isMe
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.tertiary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4.0,
                  spreadRadius: 2.0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat.chat ?? '-',
                  style: TextStyle(
                    color: isMe
                        ? Theme.of(context).colorScheme.onSecondary
                        : Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    formatDateTimeCustom(chat.createdAt, format: 'HH:mm'),
                    style: TextStyle(
                      fontSize: 12,
                      color: isMe
                          ? Theme.of(context)
                              .colorScheme
                              .onSecondary
                              .withOpacity(0.5)
                          : Theme.of(context)
                              .colorScheme
                              .onTertiary
                              .withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void deleteMessage(
    BuildContext context,
    String? uid,
  ) async {
    try {
      if (uid == null) {
        throw Exception('Chat ID is null');
      }
      await FirebaseFirestore.instance.collection('chats').doc(uid).delete();
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialogMsg(context, 'Error : ${e.toString()}');
      });
    }
  }
}
