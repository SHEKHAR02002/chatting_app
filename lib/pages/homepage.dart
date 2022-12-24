import 'package:chatting_app/models/chatroom.dart';
import 'package:chatting_app/models/firebasehepler.dart';
import 'package:chatting_app/models/usermodel.dart';
import 'package:chatting_app/pages/chatroom.dart';
import 'package:chatting_app/pages/login.dart';
import 'package:chatting_app/pages/searchpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomePage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Chat App"),
          actions: [
            IconButton(
                onPressed: () {
                  logout();
                },
                icon: const Icon(Icons.exit_to_app)),
          ],
        ),
        body: SafeArea(
          child: StreamBuilder(
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot chatRoomSnapshot =
                        snapshot.data as QuerySnapshot;
                    return ListView.builder(
                      itemCount: chatRoomSnapshot.docs.length,
                      itemBuilder: ((context, index) {
                        ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                            chatRoomSnapshot.docs[index].data()
                                as Map<String, dynamic>);

                        Map<String, dynamic> participants =
                            chatRoomModel.participants!;

                        List<String> participantkeys =
                            participants.keys.toList();

                        participantkeys.remove(widget.userModel.uid);

                        return FutureBuilder(
                          future: FirebasHelper.getUserModelById(
                              participantkeys[0]),
                          builder: (context, userData) {
                            if (userData.connectionState ==
                                ConnectionState.done) {
                              if (userData.data != null) {
                                UserModel targetUser =
                                    userData.data as UserModel;
                                //made list Tile
                                return ListTile(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return ChatRoomPage(
                                          chatroom: chatRoomModel,
                                          firebaseUser: widget.firebaseUser,
                                          userModel: widget.userModel,
                                          targetuser: targetUser,
                                        );
                                      }));
                                    },
                                    leading: const CircleAvatar(),
                                    title: Text(targetUser.name.toString()),
                                    subtitle: Text(
                                      chatRoomModel.lastMessage.toString(),
                                    ));
                              } else {
                                return Container();
                              }
                            } else {
                              return Container();
                            }
                          },
                        );
                      }),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(snapshot.error.toString()),
                    );
                  } else {
                    return const Center(
                      child: Text("no Chats"),
                    );
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
              stream: FirebaseFirestore.instance
                  .collection("chatrooms")
                  .where("participants.${widget.userModel.uid}",
                      isEqualTo: true)
                  .snapshots()),
          // CupertinoButton(
          //     color: Theme.of(context).colorScheme.secondary,
          //     onPressed: () {
          //       logout();
          //     },
          //     child: const Text("Logout")),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SearchPage(
                        userModel: widget.userModel,
                        firebaseUser: widget.firebaseUser,
                      )),
            );
          },
          child: const Icon(Icons.search),
        ));
  }
}
