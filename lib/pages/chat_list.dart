import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_hostelite/screens/chat_screen.dart';
import 'package:project_hostelite/theme/colors.dart';
import 'package:project_hostelite/utils/routes.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'My Chats',
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: scaffoldBackgroundColor,
        leading: IconButton(
          highlightColor: primaryBlue.withOpacity(0.2),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 22,
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.homeRoute);
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: primaryBlue,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No chats found.'));
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final participants = chat['participants'] as List<dynamic>;

              final otherUserId =
                  participants.firstWhere((id) => id != user.uid);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.transparent,
                      ),
                    );
                  }
                  if (!userSnapshot.hasData) {
                    return const ListTile();
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;

                  final profilePicUrl = userData['profileImageUrl'] ?? '';

                  final Timestamp? lastMessageTimestamp = chat['timestamp'];
                  String formattedTime = 'Unknown';
                  if (lastMessageTimestamp != null) {
                    final DateTime lastMessageDateTime =
                        lastMessageTimestamp.toDate().toLocal();
                    final DateTime now = DateTime.now();

                    if (lastMessageDateTime.day == now.day &&
                        lastMessageDateTime.month == now.month &&
                        lastMessageDateTime.year == now.year) {
                      formattedTime =
                          DateFormat('h:mm a').format(lastMessageDateTime);
                    } else if (lastMessageDateTime.day == now.day - 1 &&
                        lastMessageDateTime.month == now.month &&
                        lastMessageDateTime.year == now.year) {
                      formattedTime = 'Yesterday';
                    } else {
                      formattedTime =
                          DateFormat('d/M/y').format(lastMessageDateTime);
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(14, 18, 14, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: primaryBlue.withOpacity(0.5),
                              offset: const Offset(0, 5),
                              spreadRadius: -15,
                              blurRadius: 20),
                        ],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade400,
                          backgroundImage: profilePicUrl.isNotEmpty
                              ? NetworkImage(profilePicUrl)
                              : const AssetImage('assets/icons/user.png')
                                  as ImageProvider,
                          radius: 24,
                        ),
                        title: Row(
                          children: [
                            Text(
                              userData['name'],
                              style: const TextStyle(fontSize: 17),
                            ),
                            const Spacer(),
                            Text(
                              formattedTime,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          chat['lastMessage'],
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                  chatId: chat.id, otherUser: userData),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
