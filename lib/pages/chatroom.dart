import 'dart:developer';

import 'package:chatting_app/main.dart';
import 'package:chatting_app/models/chatroom.dart';
import 'package:chatting_app/models/message.dart';
import 'package:chatting_app/models/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetuser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomPage(
      {super.key,
      required this.targetuser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();
    if (msg != "") {
      //send msg
      MessageModel newMessage = MessageModel(
          messageid: uuid.v1(),
          sender: widget.userModel.uid,
          createon: "${DateTime.now()}",
          text: msg,
          seen: false);

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("message")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      log("Message send");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          const CircleAvatar(),
          const SizedBox(
            width: 10,
          ),
          Text(widget.targetuser.name.toString())
        ],
      )),
      body: SafeArea(
          child: Container(
        child: Column(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                child: StreamBuilder(
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData) {
                          QuerySnapshot dataSnapshot =
                              snapshot.data as QuerySnapshot;
                          return ListView.builder(
                              //reverse
                              reverse: true,
                              itemCount: dataSnapshot.docs.length,
                              itemBuilder: (context, index) {
                                MessageModel currentMessage =
                                    MessageModel.fromMap(
                                        dataSnapshot.docs[index].data()
                                            as Map<String, dynamic>);

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  child: Row(
                                    mainAxisAlignment: (currentMessage.sender ==
                                            widget.userModel.uid)
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    children: [
                                      Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: (currentMessage.sender ==
                                                      widget.userModel.uid)
                                                  ? Colors.grey
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .secondary),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              currentMessage.text.toString(),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 22),
                                            ),
                                          )),
                                    ],
                                  ),
                                );
                              });
                        } else if (snapshot.hasError) {
                          return const Center(
                            child: Text("error occur"),
                          );
                        } else {
                          return const Center(
                            child: Text("Say hi to friend"),
                          );
                        }
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                    stream: FirebaseFirestore.instance
                        .collection("chatrooms")
                        .doc(widget.chatroom.chatroomid)
                        .collection("message")
                        // .orderBy("createdon")
                        .snapshots()),
              ),
            )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Container(
                color: Colors.grey[200],
                child: Row(
                  children: [
                    Flexible(
                        child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TextField(
                        controller: messageController,
                        maxLines: null,
                        decoration: const InputDecoration(
                            hintText: "Enter Message",
                            border: InputBorder.none),
                      ),
                    )),
                    IconButton(
                        onPressed: () {
                          sendMessage();
                        },
                        icon: Icon(
                          Icons.send,
                          color: Theme.of(context).colorScheme.secondary,
                        ))
                  ],
                ),
              ),
            )
          ],
        ),
      )),
    );
  }
}
