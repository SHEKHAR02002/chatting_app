import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:chatting_app/main.dart';
import 'package:chatting_app/models/chatroom.dart';
import 'package:chatting_app/models/message.dart';
import 'package:chatting_app/models/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  String type = "text";

  void storedata() async {
    String messageid = uuid.v1();

    String profilePic = await fireStoreFileUpload(
        "${FirebaseAuth.instance.currentUser!.uid}/imagePic.jpg",
        customProfileImage);

    MessageModel newMessage = MessageModel(
        messageid: uuid.v1(),
        sender: widget.userModel.uid,
        createon: DateTime.now(),
        text: profilePic,
        type: "image",
        seen: false);

    FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .collection("chatrooms")
        .doc(widget.chatroom.chatroomid)
        .collection("message")
        .doc(newMessage.messageid)
        .set(newMessage.toMap());

    log("photo send");
    type == "text";
  }

  String customProfileImage = "";
  Future<dynamic> getimage() async {
    try {
      final XFile? image =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      final File file = File(image!.path);
      setState(() {
        customProfileImage = file.path;
      });
      storedata();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future fireStoreFileUpload(refStorageImage, refImage) async {
    String pathValue = '';
    final firebaseStorageRef =
        FirebaseStorage.instance.ref().child(refStorageImage);
    final uploadTask = firebaseStorageRef.putFile(File(refImage));
    final taskSnapshot = await uploadTask.whenComplete(() {});
    await taskSnapshot.ref.getDownloadURL().then((value) async {
      pathValue = value;
    });
    return pathValue;
  }

  sendmsg() {
    String msg = messageController.text.trim();
    messageController.clear();
    if (msg != "") {
      //send msg
      MessageModel newMessage = MessageModel(
          messageid: uuid.v1(),
          sender: widget.userModel.uid,
          createon: DateTime.now(),
          text: msg,
          type: "text",
          seen: false);

      FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userModel.uid)
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
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
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
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(widget.userModel.uid)
                  .collection("chatrooms")
                  .doc(widget.chatroom.chatroomid)
                  .collection("message")
                  .orderBy("createon", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
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
                                Column(
                                  children: [
                                    currentMessage.type == "text"
                                        ? Container(
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
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  currentMessage.text
                                                      .toString(),
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 22),
                                                )))
                                        : currentMessage.text == ""
                                            ? const CircularProgressIndicator()
                                            : Image.network(
                                                currentMessage.text.toString(),
                                                fit: BoxFit.cover,
                                                height: height / 4,
                                                width: width / 2,
                                              ),
                                    const SizedBox(height: 20),
                                  ],
                                ),

                                // Image.network(
                                //     customProfileImage,
                                //     fit: BoxFit.cover,
                                //   )),
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
            ),
          )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Container(
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        type = "image";
                      });

                      getimage();
                    },
                    child: const Icon(
                      CupertinoIcons.add_circled_solid,
                      size: 40,
                      color: Color(
                        0xffd1bdf4,
                      ),
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
                      sendmsg();
                      // storedata();
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
