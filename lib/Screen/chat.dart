import 'dart:async';
import 'dart:io';

import 'package:chatmassegeapp/Firebase/firebase.dart';
import 'package:chatmassegeapp/models/chatModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../getControllers/chatController.dart';

//
class ChatPage extends StatefulWidget {
  final chatRoomId;
  final receiverID;
  final receiverName;
  final participants;
  const ChatPage(
      {required this.chatRoomId,
      required this.receiverID,
        required this.receiverName,
      required this.participants});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final textController = TextEditingController();

  void markMessagesAsSeen(String chatRoomId, String currentUserId) async {
    var value = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomId)
        .get();
    if (value.exists) {
      final messagesRef = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages');

      messagesRef.get().then((querySnapshot) {
        querySnapshot.docs.forEach((messageDoc) {
          final data = messageDoc.data();
          final senderId = data['senderId'];

          // Check if the message sender is different from the current user
          if (senderId != currentUserId) {
            messagesRef.doc(messageDoc.id).update({
              'isSeen': true,
              'updatedAt': DateTime.now()
            }).catchError((error) {
              // Handle the error if necessary
              print('Error updating seen status: $error');
            });
          }
        });
      });

      // change unReadCount

      final ref =
          FirebaseFirestore.instance.collection("chats").doc(chatRoomId);
      final refDAta = await ref.get();
      List ar = [123, 456];
      int index = ar.indexOf(currentUserId);
      var unreadCountOfUser1 = index == 0 ? refDAta['unreadCountOfUser1'] : 0;
      var unreadCountOfUser2 = index == 1 ? refDAta['unreadCountOfUser2'] : 0;
      await ref.update({
        'unreadCountOfUser2': unreadCountOfUser2,
        'unreadCountOfUser1': unreadCountOfUser1
      });
    }
  }

  @override
  void initState() {
    super.initState();
    markMessagesAsSeen(
        widget.chatRoomId, FirebaseAuth.instance.currentUser!.uid);
    // Timer.periodic(Duration(seconds: 2), (timer) {
    //
    //     userOnlineTimer=timer;
    //
    //   chatController.fetchReceiverData(widget.receiver.id);
    // });

    MyFirebase().updateOnlineStatus(true);
  }

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
    MyFirebase().updateOnlineStatus(false);
    chatController.dispose();
    MyFirebase().UpdateUserLastSeen(widget.chatRoomId, widget.participants);
  }

  final ChatController chatController = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    print("chatRoom ID : ${widget.chatRoomId}");
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${widget.receiverName}",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 3),
              StreamBuilder(
                stream: chatController.fetchReceiverData(
                    widget.receiverID, widget.chatRoomId, widget.participants),
                builder: (context, AsyncSnapshot snapshot) {
                  print("lastseen Stream  : ${snapshot.data}");
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text(
                      "Loading..",
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    );
                  }
                  if (snapshot.hasError || snapshot.data == null) {
                    return Text("eror");
                  }
                  if (snapshot.data!.isEmpty) {
                    return SizedBox();
                  }
                  return Text(
                    snapshot.data.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  );
                },
              ),
            ],
          ),
        ),
        body: Container(
          height: h,
          width: w,
          child: Column(
            children: [
              Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: MyFirebase().getAllChatsOFRoom(widget.chatRoomId),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }
                        if (snapshot.data == null) {
                          return Center(
                            child: Text("No chats available"),
                          );
                        }

                        final List docs = snapshot.data!.docs;
                        //
                        List<ChatModel> chatList = docs
                            .map((e) => ChatModel.fromJson(
                                e.data() as Map<String, dynamic>))
                            .toList();
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: chatList.length,
                            itemBuilder: (context, ind) {
                              var boolValue = chatList[ind].senderId ==
                                  FirebaseAuth.instance.currentUser!.uid;
                              chatList.sort(
                                  (a, b) => a.timestamp.compareTo(b.timestamp));
                              return Padding(
                                padding: EdgeInsets.all(8),
                                child: Align(
                                  alignment: boolValue
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 10),
                                    constraints: BoxConstraints(
                                        minHeight: h * 0.04,
                                        minWidth: w * 0.02,
                                        maxWidth: chatList[ind].text.length >
                                                    20 ||
                                                chatList[ind].image.length > 20
                                            ? w * 0.6
                                            : w * 0.4),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: boolValue
                                            ? Colors.grey[200]
                                            : Colors.orange.withOpacity(0.6)),
                                    child: Center(
                                      child: Row(children: [
                                        Expanded(
                                            child: chatList[ind].image.isEmpty
                                                ? Text(
                                                    "${chatList[ind].text}",
                                                    maxLines: 50,
                                                  )
                                                : Container(
                                                    height: h * 0.25,
                                                    width: w * 0.4,
                                                    child: Image.network(
                                                        chatList[ind].image,
                                                        fit: BoxFit.fill),
                                                  )),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                            "${DateFormat('h:mm a').format(chatList[ind].timestamp)}")
                                      ]),
                                    ),
                                  ),
                                ),
                              );
                            });
                      })),
              Container(
                width: w,
                constraints: BoxConstraints(maxHeight: h * 0.08),
                margin: EdgeInsets.all(15),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(border: Border.all()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: w * 0.1,
                        child: IconButton(
                            onPressed: () async {
                              final pickedImg = await ImagePicker()
                                  .pickImage(source: ImageSource.gallery);
                              pickedImg != null
                                  ? await MyFirebase().sendImageAsChat(
                                      File(pickedImg.path),
                                      widget.chatRoomId,
                                      widget.receiverID,
                              widget.participants
                              )
                                  : null;
                            },
                            icon: Icon(
                              Icons.photo,
                              size: 22,
                            ))),
                    Container(
                      constraints: BoxConstraints(
                          maxHeight: h * 0.08, maxWidth: w * 0.73),
                      child: TextFormField(
                        controller: textController,
                        decoration: InputDecoration(
                            hintText: "Type here",
                            suffixIcon: IconButton(
                                onPressed: () async {
                                  if (textController.text.isNotEmpty) {
                                    await MyFirebase().sendMessage(
                                        widget.chatRoomId,
                                        textController.text,
                                        widget.receiverID,
                                        widget.participants);
                                    textController.clear();
                                  }
                                },
                                icon: Icon(
                                  Icons.send,
                                  color: Colors.orange,
                                ))),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
