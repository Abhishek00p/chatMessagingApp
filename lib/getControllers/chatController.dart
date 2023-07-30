import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatController extends GetxController {
  String receiverLastSeen = 'Loading...';


  fetchReceiverData(String receiverId,chatRoomID,List participants) async* {


    try {
      final userRef =
      FirebaseFirestore.instance.collection('users').where('id', isEqualTo: receiverId);
      final userSnapshot = await userRef.get();

      if (userSnapshot.size == 1) {
        final userData = userSnapshot.docs.first.data();
        final isOnline = userData['isOnline'] as bool;
        if (isOnline) {
          yield 'Online';
        } else {

          final chatRoom =await FirebaseFirestore.instance.collection("chats").doc(chatRoomID).get();

          if( chatRoom.data()!=null){
            final lastSeenTimestamp = await chatRoom.data()?[participants[0]==receiverId? 'user1LastSeen':'user2LastSeen'] ;
            if (lastSeenTimestamp != null) {
              if(lastSeenTimestamp.runtimeType==String){
                yield '';
              }else{

                final lastSeen = lastSeenTimestamp.toDate();
                final formattedLastSeen = DateFormat('h:mm a').format(lastSeen);
                yield 'Last seen: $formattedLastSeen';
              }
            } else {
              yield 'Last seen: N/A';
            }
          }else{
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







