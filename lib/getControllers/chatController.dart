import 'dart:async';
import 'dart:io';

import 'package:chatmassegeapp/Firebase/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatController extends GetxController {
  String receiverLastSeen = 'Loading...';
  Rx<String> message = ''.obs;
  RxBool showImagePreview = false.obs;
  Rx<File> imageFile = Rx(File(''));

  updateMessage({required String mesg}) {
    message.value = mesg;
  }

  updateImageFile(File? file) {
    if (file != null) {
      showImagePreview.value = true;
      imageFile.value = file;
    } else {
      showImagePreview.value = false;
    }
  }

  // call firebase function from here
  sendImageAndTextToUser({
    // required File pickedFile,
    required String chatRoomID,
    required String receiverID,
    required List participants,
    // required String textMessage,
  }) async {
    try {
      // Fluttertoast.showToast(msg: 'processing image and message');

      final value = await MyFirebase().sendImageAndText(
          pickedFile: imageFile.value,
          chatRoomID: chatRoomID,
          receiverID: receiverID,
          participants: participants,
          textMessage: message.value);
      if (value) {
        Fluttertoast.showToast(msg: 'Successfully sent message');
        showImagePreview.value = false;
        message.value = '';
        imageFile.value = File('');
      }else{
        Fluttertoast.showToast(msg: 'Failed to sent message');

      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to send message');
    }
  }

  fetchReceiverData(String receiverId, chatRoomID, List participants) async* {
    try {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: receiverId);
      final userSnapshot = await userRef.get();

      if (userSnapshot.size == 1) {
        final userData = userSnapshot.docs.first.data();
        final isOnline = userData['isOnline'] as bool;
        if (isOnline) {
          yield 'Online';
        } else {
          final chatRoom = await FirebaseFirestore.instance
              .collection("chats")
              .doc(chatRoomID)
              .get();

          if (chatRoom.data() != null) {
            final lastSeenTimestamp = await chatRoom.data()?[
                participants[0] == receiverId
                    ? 'user1LastSeen'
                    : 'user2LastSeen'];
            if (lastSeenTimestamp != null) {
              if (lastSeenTimestamp.runtimeType == String) {
                yield '';
              } else {
                final lastSeen = lastSeenTimestamp.toDate();
                final formattedLastSeen = DateFormat('h:mm a').format(lastSeen);
                yield 'Last seen: $formattedLastSeen';
              }
            } else {
              yield 'Last seen: N/A';
            }
          } else {
            yield '';
          }
        }
      } else {
        yield 'Receiver Not Found';
      }
    } catch (e) {
      print('Error fetching receiver data: $e');
      yield 'Error';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
