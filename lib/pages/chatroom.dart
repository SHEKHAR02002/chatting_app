import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
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
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();
    if (msg != "") {
      //send msg
      MessageModel newMessage = MessageModel(
          messageid: uuid.v1(),
          sender: widget.userModel.uid,
          createon: DateTime.now(),
          text: msg,
          seen: false);

      FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userModel.uid)
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("message")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      FirebaseFirestore.instance
          .collection("users")
          .doc(widget.targetuser.uid)
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
          backgroundColor: Colors.white,
          bottomOpacity: 0.0,
          elevation: 0.0,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              CupertinoIcons.back,
              color: Colors.black,
            ),
          ),
          title: Row(
            children: [
              const CircleAvatar(),
              const SizedBox(
                width: 10,
              ),
              Column(
                children: [
                  Text(
                    widget.targetuser.name.toString(),
                    style: const TextStyle(
                        fontFamily: "Overpass",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const Text(
                    "9:30 pm",
                    style: TextStyle(
                      fontFamily: "Overpass",
                      fontSize: 14,
                      color: Color(
                        0xff606060,
                      ),
                    ),
                  )
                ],
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(160, 0, 0, 0),
                child: Icon(
                  CupertinoIcons.ellipsis_vertical,
                  color: Colors.black,
                ),
              )
            ],
          )),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: StreamBuilder(
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot dataSnapshot =
                          snapshot.data as QuerySnapshot;
                      return ListView.builder(
                          //reverse
                          // reverse: true,
                          itemCount: dataSnapshot.docs.length,
                          itemBuilder: (context, index) {
                            MessageModel currentMessage = MessageModel.fromMap(
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
                                              ? const Color(
                                                  0xff834df8,
                                                )
                                              : const Color(
                                                  0xffd1bdf4,
                                                )),
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
                    .collection("users")
                    .doc(widget.userModel.uid)
                    .collection("chatrooms")
                    .doc(widget.chatroom.chatroomid)
                    .collection("message")
                    .orderBy("createon", descending: false)
                    .snapshots()),
          )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Container(
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.add_circled_solid,
                    size: 40,
                    color: Color(
                      0xffd1bdf4,
                    ),
                  ),
                  Flexible(
                      child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: SizedBox(
                      height: 34,
                      child: TextFormField(
                        controller: messageController,
                        maxLines: null,
                        decoration: InputDecoration(
                            hintStyle: const TextStyle(
                              fontSize: 16,
                              color: Color(
                                0xff8c8c8c,
                              ),
                            ),
                            hintText: "Type Here.....",
                            filled: true,
                            fillColor: const Color(
                              0xffd1bdf4,
                            ),
                            enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(12),
                            )),
                      ),
                    ),
                  )),
                  IconButton(
                    onPressed: () {
                      sendMessage();
                    },
                    icon: const Icon(
                      CupertinoIcons.location_fill,
                      color: Color(
                        0xfffcbb64,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      )),
    );
  }
}
