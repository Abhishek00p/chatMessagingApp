import 'dart:io';

import 'package:chatmassegeapp/Firebase/firebase.dart';
import 'package:chatmassegeapp/constants/colors.dart';
import 'package:chatmassegeapp/models/chatModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
      {super.key,
      required this.chatRoomId,
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
      final messagesRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages');

      messagesRef.get().then((querySnapshot) {
        for (var messageDoc in querySnapshot.docs) {
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
        }
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
    var userPRofile = '';
    print("chatRoom ID : ${widget.chatRoomId}");
    return Scaffold(
      // backgroundColor: Color.fromRGBO(5, 17, 59, 1),
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
        // backgroundColor: Color.fromRGBO(5, 17, 59, 1),
        backgroundColor: background,
        title: Row(
          children: [
            CircleAvatar(
              radius: h * 0.02,
              backgroundColor: Colors.white54,
              child: userPRofile.isEmpty
                  ? const Icon(Icons.person)
                  : Image.network(userPRofile),
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.receiverName}",
                  style: GoogleFonts.roboto(
                      fontSize: 18,
                      color: Colors.white,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 3),
                StreamBuilder(
                  stream: chatController.fetchReceiverData(widget.receiverID,
                      widget.chatRoomId, widget.participants),
                  builder: (context, AsyncSnapshot snapshot) {
                    print("lastseen Stream  : ${snapshot.data}");
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text(
                        "Loading..",
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      );
                    }
                    if (snapshot.hasError || snapshot.data == null) {
                      return const Text("eror");
                    }
                    if (snapshot.data!.isEmpty) {
                      return const SizedBox();
                    }
                    return Text(
                      snapshot.data.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: SizedBox(
        height: h - kToolbarHeight,
        width: w,
        child: Column(
          children: [
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: MyFirebase().getAllChatsOFRoom(widget.chatRoomId),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (snapshot.data == null ||
                          snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "No chats available",
                            style: TextStyle(color: Colors.white),
                          ),
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
                              padding: const EdgeInsets.all(8),
                              child: Align(
                                alignment: boolValue
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
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
                                      color: !boolValue
                                          ? recieverChatBAckground
                                          : senderChatBAckground),
                                  child: Center(
                                    child: Row(children: [
                                      Expanded(
                                          child: chatList[ind].image.isEmpty
                                              ? Text(
                                                  chatList[ind].text,
                                                  style: GoogleFonts.roboto(
                                                    fontSize: 13,
                                                    color: Colors.white,
                                                  ),
                                                  // TextStyle(
                                                  //     color: boolValue
                                                  //         ? Color.fromRGBO(
                                                  //             5, 17, 59, 1)
                                                  //         : Colors.white
                                                  //             .withOpacity(
                                                  //                 0.5)),
                                                  maxLines: 50,
                                                )
                                              : chatList[ind].text.isEmpty &&
                                                      chatList[ind]
                                                          .image
                                                          .trim()
                                                          .isNotEmpty
                                                  ? SizedBox(
                                                      height: h * 0.25,
                                                      width: w * 0.4,
                                                      child: Image.network(
                                                          chatList[ind].image,
                                                          fit: BoxFit.fill),
                                                    )
                                                  : Column(
                                                      children: [
                                                        SizedBox(
                                                          height: h * 0.25,
                                                          width: w * 0.4,
                                                          child: Image.network(
                                                              chatList[ind]
                                                                  .image,
                                                              fit: BoxFit.fill),
                                                        ),
                                                        Text(
                                                          chatList[ind].text,
                                                          style: GoogleFonts
                                                              .roboto(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .white),
                                                          // TextStyle(
                                                          //     color:
                                                          //     boolValue
                                                          //         ? Color
                                                          //             .fromRGBO(
                                                          //                 5,
                                                          //                 17,
                                                          //                 59,
                                                          //                 1)
                                                          //         : Colors.white
                                                          //             .withOpacity(
                                                          //                 0.5)),
                                                          maxLines: 50,
                                                        )
                                                      ],
                                                    )),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                            DateFormat('h:mm a').format(
                                                chatList[ind].timestamp),
                                            style: GoogleFonts.roboto(
                                                color: Colors.white,
                                                fontSize: 13)
                                            // TextStyle(
                                            //     color: boolValue
                                            //         ? Color.fromRGBO(5, 17, 59, 1)
                                            //         : Colors.white
                                            //             .withOpacity(0.5))
                                            ),
                                      )
                                    ]),
                                  ),
                                ),
                              ),
                            );
                          });
                    })),
            Obx(
              () => SizedBox(
                height:
                    chatController.showImagePreview.value ? h * 0.45 : h * 0.1,
                width: w,
                child: Stack(
                  children: [
                    chatController.showImagePreview.value
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                color: Colors.green,
                                height: h * 0.2,
                                width: w * 0.4,
                                child: Image.file(
                                  chatController.imageFile.value,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  'Click on Close button to Deselect File ',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300),
                                ),
                              ),
                              const SizedBox(height: 10),
                              IconButton(
                                  onPressed: () {
                                    chatController.updateImageFile(null);
                                  },
                                  icon: const Icon(Icons.close)),
                              SizedBox(
                                height: h * 0.1,
                                child: ChatKeyboard(
                                    w: w,
                                    h: h,
                                    // chatController: chatController,
                                    textController: textController,
                                    widget: widget),
                              ),
                              // const SizedBox(
                              //   height: 10,
                              // ),
                            ],
                          )
                        : ChatKeyboard(
                            w: w,
                            h: h,
                            // chatController: chatController,
                            textController: textController,
                            widget: widget),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatKeyboard extends StatelessWidget {
  ChatKeyboard({
    super.key,
    required this.w,
    required this.h,
    // required this.chatController,
    required this.textController,
    required this.widget,
  });

  final double w;
  final double h;
  // final ChatController chatController;
  final TextEditingController textController;
  final ChatPage widget;

  final ChatController chatController = Get.find<ChatController>();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: w,
      height: h * 0.07,

      // constraints: BoxConstraints(maxHeight: h * 0.08),
      margin: const EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // color: Color.fromRGBO(19, 37, 77, 1),
        color: recieverChatBAckground,
      ),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
                width: w * 0.1,
                child: IconButton(
                    onPressed: () async {
                      final pickedImg = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (pickedImg != null) {
                        chatController.updateImageFile(File(pickedImg.path));
                        // await MyFirebase().sendImageAsChat(
                        //   File(pickedImg.path),
                        //   widget.chatRoomId,
                        //   widget.receiverID,
                        //   widget.participants);
                      }
                    },
                    icon: const Icon(
                      Icons.photo,
                      color: Colors.white,
                      size: 22,
                    ))),
            Container(
              height: h * 0.1,
              constraints: BoxConstraints(maxWidth: w * 0.73),
              child: TextFormField(
                controller: textController,
                onChanged: (value) {
                  chatController.updateMessage(mesg: value);
                  if (value.trim().isEmpty) {
                    chatController.updateSendButtonVisibility(false);
                  } else {
                    chatController.updateSendButtonVisibility(true);
                  }
                },
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    hintText: "Type here...",
                    suffixIcon: CircleAvatar(
                      radius: 4,
                      backgroundColor: !(chatController.enableSendButton.value)
                          ? Colors.grey
                          : const Color.fromRGBO(73, 208, 238, 1),
                      child: IconButton(
                        onPressed: !(chatController.enableSendButton.value)
                            ? () {}
                            : () async {
                                chatController.updateImageFile(null);

                                await chatController
                                    .updateSendButtonVisibility(false);
                                if (textController.text.isNotEmpty &&
                                    chatController.imageFile.value.path
                                        .trim()
                                        .isEmpty) {
                                  await MyFirebase().sendMessage(
                                      widget.chatRoomId,
                                      textController.text,
                                      widget.receiverID,
                                      widget.participants);
                                  textController.clear();
                                } else if (textController.text.isEmpty &&
                                    chatController.imageFile.value.path
                                        .trim()
                                        .isNotEmpty) {
                                  await MyFirebase().sendImageAsChat(
                                      chatController.imageFile.value,
                                      widget.chatRoomId,
                                      widget.receiverID,
                                      widget.participants);
                                } else {
                                  chatController.sendImageAndTextToUser(
                                      chatRoomID: widget.chatRoomId,
                                      receiverID: widget.receiverID,
                                      participants: widget.participants);
                                  textController.clear();
                                }

                                chatController.clearStates();
                              },
                        icon: const Icon(
                          Icons.send,
                          size: 17,
                          color: Colors.white,
                        ),
                      ),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
