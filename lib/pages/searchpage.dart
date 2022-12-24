import 'dart:developer';

import 'package:chatting_app/main.dart';
import 'package:chatting_app/models/chatroom.dart';
import 'package:chatting_app/models/usermodel.dart';
import 'package:chatting_app/pages/chatroom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  ///chat room creat//
  Future<ChatRoomModel?> getChatroomModel(UserModel targetUSer) async {
    ChatRoomModel? chatRoom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUSer.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      //fetch existing

      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      chatRoom = existingChatroom;
    } else {
      //creat new chat room
      ChatRoomModel newChatroom = ChatRoomModel(
          chatroomid: uuid.v1(),
          lastMessage: "",
          participants: {
            widget.userModel.uid.toString(): true,
            targetUSer.uid.toString(): true
          });
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userModel.uid)
          .collection("chatrooms")
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());

      await FirebaseFirestore.instance
          .collection("users")
          .doc(targetUSer.uid)
          .collection("chatrooms")
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());

      chatRoom = newChatroom;
      log("new chatroom created");
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
            child: Column(
          children: [
            TextField(
              controller: searchController,
            ),
            const SizedBox(height: 20),
            CupertinoButton(
                color: Theme.of(context).colorScheme.secondary,
                onPressed: () {
                  setState(() {});
                },
                child: const Text("Search")),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .where("email", isEqualTo: searchController.text)
                  .where("email", isNotEqualTo: widget.userModel.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                    if (dataSnapshot.docs.isNotEmpty) {
                      Map<String, dynamic> userMap =
                          dataSnapshot.docs[0].data() as Map<String, dynamic>;

                      UserModel searchUser = UserModel.fromMap(userMap);

                      return ListTile(
                        onTap: () async {
                          ChatRoomModel? chatroomModel =
                              await getChatroomModel(searchUser);

                          if (chatroomModel != null) {
                            Navigator.pop(context);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ChatRoomPage(
                                targetuser: searchUser,
                                userModel: widget.userModel,
                                firebaseUser: widget.firebaseUser,
                                chatroom: chatroomModel,
                              );
                            }));
                          }
                          // Navigator.pop(context);
                          // Navigator.push(context,
                          //     MaterialPageRoute(builder: (context) {
                          //   return  ChatRoomPage(
                          //     targetuser: searchUser,
                          //     userModel: widget.userModel,
                          //     firebaseUser: widget.firebaseUser,
                          //     chatroom: ,
                          //   );
                          // }));
                        },
                        leading: const CircleAvatar(),
                        title: Text(searchUser.name!),
                        subtitle: Text(searchUser.email!),
                        trailing: const Icon(Icons.keyboard_arrow_right),
                      );
                    } else {
                      return const Text("No result Found");
                    }
                  } else if (snapshot.hasError) {
                    return const Text("Error");
                  } else {
                    return const Text("No result Found");
                  }
                } else {
                  return const CircularProgressIndicator();
                }
              },
            )
          ],
        )),
      ),
    );
  }
}
