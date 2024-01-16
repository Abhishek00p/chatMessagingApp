import 'dart:io';

import 'package:chatmassegeapp/Screen/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/chatModel.dart';

class MyFirebase {
  final _userCollection = FirebaseFirestore.instance.collection("users");

  registerWithEmailPassword(String email, String password, String? name) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // User registration successful
      User user = userCredential.user!;
      await _userCollection.doc(FirebaseAuth.instance.currentUser!.uid).set({
        "name": name ?? "User",
        "email": email,
        "isOnline": false,
        "id": user.uid
      });
      return user;
    } catch (e) {
      print("registeration fail $e");
      if (e.toString().contains("by another account")) {
        Fluttertoast.showToast(msg: "User already exist with that EmailID");
      }
      Fluttertoast.showToast(msg: "Failed to Register user");
    }
  }

  signInWithEmailPassword(String email, String password) async {
    try {
      print("Email : $email and pss : $password");
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // User signed in successfully
      User user = userCredential.user!;
      Fluttertoast.showToast(msg: "Successfulyy Logged in");

      return user;
    } catch (e) {
      print("login Failed $e");
      Fluttertoast.showToast(msg: "Failed to login user");
    }
  }

  signOut() async {
    await updateOnlineStatus(false);
    await FirebaseAuth.instance.signOut();

    await GoogleSignIn().signOut();
  }

  signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(scopes: ['email']);
    final value = await googleSignIn.signIn();
    if (value != null) {
      var gauth = await value.authentication;
      var cred = GoogleAuthProvider.credential(
          accessToken: gauth.accessToken, idToken: gauth.idToken);
      var userCred = await FirebaseAuth.instance.signInWithCredential(cred);

      if (userCred.user != null) {
        await _userCollection.doc(userCred.user!.uid).set({
          "name": value.displayName ?? "User",
          "email": value.email,
          "isOnline": true,
          "id": value.id
        });
        Get.offAll(() => HomePage());
      } else {
        Fluttertoast.showToast(msg: "Failed to login");
      }
    } else {
      return null;
    }
  }

  updateOnlineStatus(bool? isOnline) async {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    if (FirebaseAuth.instance.currentUser == null) {
    } else {
      QuerySnapshot querySnapshot = await usersCollection
          .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (querySnapshot.size == 1) {
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;

        await documentSnapshot.reference.update({
          'isOnline': isOnline ?? false,
          'updatedAt': DateTime.now(),
        });
      } else {
        print('User document not found .');
      }
    }
  }

  UpdateUserLastSeen(String chatRoomId, List participants) async {
    try {
      final userID = FirebaseAuth.instance.currentUser!.uid;

      final chatroomData = await FirebaseFirestore.instance
          .collection("chats")
          .doc(chatRoomId)
          .get();

      var userCol1 = await FirebaseFirestore.instance
          .collection("users")
          .where('id', isEqualTo: participants[0])
          .get();
      var userCol2 = await FirebaseFirestore.instance
          .collection("users")
          .where('id', isEqualTo: participants[1])
          .get();
      if (chatroomData.exists) {
        if (participants[0] == userID) {
          var user1NAme = userCol1.docs.first.data()["name"];
          var user2NAme = userCol2.docs.first.data()["name"];
          var user1LastSeen = DateTime.now();
          await FirebaseFirestore.instance
              .collection("chats")
              .doc(chatRoomId)
              .update({
            'user1LastSeen': user1LastSeen,
            'user1Name': user1NAme,
            'user2Name': user2NAme,
            'chatroomId': chatRoomId,
            'participants': participants
          });
        } else {
          var user1NAme = userCol1.docs.first.data()["name"];
          var user2NAme = userCol2.docs.first.data()["name"];
          var user2LastSeen = DateTime.now();
          await FirebaseFirestore.instance
              .collection("chats")
              .doc(chatRoomId)
              .update({
            'user2LastSeen': user2LastSeen,
            'user1Name': user1NAme,
            'user2Name': user2NAme,
            'chatroomId': chatRoomId,
            'participants': participants
          });
        }
      } else {
        var user1NAme = userCol1.docs.first.data()["name"];
        var user2NAme = userCol2.docs.first.data()["name"];
        if (participants[0] == userID) {
          var user1LastSeen = DateTime.now();
          var user2LastSeen = "";

          await FirebaseFirestore.instance
              .collection("chats")
              .doc(chatRoomId)
              .set({
            'user1LastSeen': user1LastSeen,
            'user2LastSeen': user2LastSeen,
            'user1Name': user1NAme,
            'user2Name': user2NAme,
            'chatroomId': chatRoomId,
            'participants': participants
          });
        } else {
          var user2LastSeen = DateTime.now();
          var user1LastSeen = '';
          await FirebaseFirestore.instance
              .collection("chats")
              .doc(chatRoomId)
              .set({
            'user1LastSeen': user1LastSeen,
            'user2LastSeen': user2LastSeen,
            'user1Name': user1NAme,
            'user2Name': user2NAme,
            'chatroomId': chatRoomId,
            'participants': participants
          });
        }
      }
    } catch (e) {
      print("error e:$e");
    }
  }

  getAllUserList() {
    try {
      return FirebaseFirestore.instance.collection("users").snapshots();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  getAllChatRoomList() {
    try {
      return FirebaseFirestore.instance
          .collection("chats")
          .where('participants',
              arrayContains: FirebaseAuth.instance.currentUser!.uid)
          .snapshots();
    } catch (e) {
      print('Error getting user chatroom: $e');
      return [];
    }
  }

  getAllChatsOFRoom(String Id) {
    return FirebaseFirestore.instance
        .collection("chats")
        .doc(Id)
        .collection("messages")
        .snapshots();
  }

  sendMessage(String chatRoomID, String text, String receiverID,
      List participants) async {
    try {
      final userID = FirebaseAuth.instance.currentUser!.uid;
      //
      final snap = await FirebaseFirestore.instance
          .collection("chats")
          .doc(chatRoomID)
          .get();
      if (snap.exists) {
        final unreadCountOfuser1 =
            await snap.data()?["unreadCountOfUser1"] ?? 0;
        final unreadCountOfuser2 =
            await snap.data()?["unreadCountOfUser2"] ?? 0;
        FirebaseFirestore.instance.collection("chats").doc(chatRoomID).set({
          "chatroomId": chatRoomID,
          "participants": participants,
          "lastMessage": text,
          "lastMessageTimestamp": DateTime.now(),
          "unreadCountOfUser1": participants[0] == receiverID
              ? unreadCountOfuser1 + 1
              : unreadCountOfuser1,
          "unreadCountOfUser2": participants[1] == receiverID
              ? unreadCountOfuser2 + 1
              : unreadCountOfuser2,
        });
        var chatroom = FirebaseFirestore.instance
            .collection("chats")
            .doc(chatRoomID)
            .collection("messages");
        await chatroom.doc().set({
          "senderId": userID,
          "receiverId": receiverID,
          "text": text,
          "image": "",
          "timestamp": DateTime.now(),
          "isSeen": false,
          "updatedAt": DateTime.now(),
        });
      } else {
        final userId = FirebaseAuth.instance.currentUser!.uid;
        FirebaseFirestore.instance.collection("chats").doc(chatRoomID).set({
          "chatroomId": chatRoomID,
          "participants": participants,
          "lastMessage": text,
          "lastMessageTimestamp": DateTime.now(),
          "unreadCountOfUser1": userID == participants[0] ? 1 : 0,
          "unreadCountOfUser2": userID == participants[1] ? 1 : 0,
          "user1LastSeen": userID == participants[0] ? DateTime.now() : "",
          "user2LastSeen": userID == participants[1] ? DateTime.now() : "",
        });
        var chatroom = FirebaseFirestore.instance
            .collection("chats")
            .doc(chatRoomID)
            .collection("messages");
        await chatroom.doc().set({
          "senderId": userID,
          "receiverId": receiverID,
          "text": text,
          "image": "",
          "timestamp": DateTime.now(),
          "isSeen": false,
          "updatedAt": DateTime.now(),
        });
      }

      Fluttertoast.showToast(msg: "Message Sent");
    } catch (e) {
      print("eeeeeeeeeeeee- $e");
    }
  }

  Future<ChatModel?> getLatestChatMessage(String chatroomId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatroomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var latestMessageData = snapshot.docs.first.data();
        return ChatModel.fromJson(latestMessageData as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print("Error getting latest message: $e");
      return null;
    }
  }

  Future<int> getUnseenMessageCount(String chatroomId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatroomId)
          .collection('messages')
          .where('isSeen', isEqualTo: false)
          .get();

      return snapshot.size;
    } catch (e) {
      print("Error getting unseen message count: $e");
      return 0;
    }
  }

  // Store Images to storage

  sendImageAsChat(File pickedFile, String chatRoomID, String receiverID,
      List participants) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference chatImagesRef = storage.ref().child('chat_images');

    final imageFile = File(pickedFile.path);
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final imageName = 'image_$timestamp.jpg';
    final imageRef = chatImagesRef.child(imageName);
    Fluttertoast.showToast(msg: "sending Image...");
    await imageRef.putFile(imageFile);
    final imageDownloadUrl = await imageRef.getDownloadURL();
    try {
      final snap = await FirebaseFirestore.instance
          .collection("chats")
          .doc(chatRoomID)
          .get();
      if (snap.exists) {
        final unreadCountOfuser1 =
            await snap.data()!["unreadCountOfUser1"] ?? 0;
        final unreadCountOfuser2 =
            await snap.data()!["unreadCountOfUser2"] ?? 0;

        await FirebaseFirestore.instance
            .collection("chats")
            .doc(chatRoomID)
            .set({
          "chatroomId": chatRoomID,
          "participants": participants,
          "lastMessage": "photo",
          "lastMessageTimestamp": DateTime.now(),
          "unreadCountOfUser1": participants[0] == receiverID
              ? unreadCountOfuser1 + 1
              : unreadCountOfuser1,
          "unreadCountOfUser2": participants[1] == receiverID
              ? unreadCountOfuser2 + 1
              : unreadCountOfuser2,
        });
        var chatroom = FirebaseFirestore.instance
            .collection("chats")
            .doc(chatRoomID)
            .collection("messages");
        await chatroom.doc().set({
          "senderId": FirebaseAuth.instance.currentUser!.uid,
          "receiverId": receiverID,
          "text": "",
          "image": imageDownloadUrl,
          "timestamp": DateTime.now(),
          "isSeen": false,
          "updatedAt": DateTime.now(),
        });
      } else {
        final userId = FirebaseAuth.instance.currentUser!.uid;
        FirebaseFirestore.instance.collection("chats").doc(chatRoomID).set({
          "chatroomId": chatRoomID,
          "participants": participants,
          "lastMessage": "photo",
          "lastMessageTimestamp": DateTime.now(),
          "unreadCountOfUser1": userId == participants[0] ? 1 : 0,
          "unreadCountOfUser2": userId == participants[1] ? 1 : 0,
          "user1LastSeen": userId == participants[0] ? DateTime.now() : "",
          "user2LastSeen": userId == participants[1] ? DateTime.now() : "",
        });
        var chatroom = FirebaseFirestore.instance
            .collection("chats")
            .doc(chatRoomID)
            .collection("messages");
        await chatroom.doc().set({
          "senderId": userId,
          "receiverId": receiverID,
          "text": "",
          "image": imageDownloadUrl,
          "timestamp": DateTime.now(),
          "isSeen": false,
          "updatedAt": DateTime.now(),
        });
      }
      Fluttertoast.showToast(msg: "Message Sent");
    } catch (e) {
      print("eeeeeeeeeee- $e");
    }
  }

  Future<bool> sendImageAndText({
    required File pickedFile,
    required String chatRoomID,
    required String receiverID,
    required List participants,
    required String textMessage,
  }) async {
    Fluttertoast.showToast(msg: 'processing image..');
    final String imageUrl = await getDownloadLinkForChatFile(file: pickedFile);
    final snap = await FirebaseFirestore.instance
        .collection("chats")
        .doc(chatRoomID)
        .get();
    try {
      if (snap.exists && imageUrl.isNotEmpty) {
        final unreadCountOfuser1 =
            await snap.data()!["unreadCountOfUser1"] ?? 0;
        final unreadCountOfuser2 =
            await snap.data()!["unreadCountOfUser2"] ?? 0;

        await FirebaseFirestore.instance
            .collection("chats")
            .doc(chatRoomID)
            .set({
          "chatroomId": chatRoomID,
          "participants": participants,
          "lastMessage": textMessage,
          "lastMessageTimestamp": DateTime.now(),
          "unreadCountOfUser1": participants[0] == receiverID
              ? unreadCountOfuser1 + 1
              : unreadCountOfuser1,
          "unreadCountOfUser2": participants[1] == receiverID
              ? unreadCountOfuser2 + 1
              : unreadCountOfuser2,
        });
        var chatroom = FirebaseFirestore.instance
            .collection("chats")
            .doc(chatRoomID)
            .collection("messages");
        await chatroom.doc().set({
          "senderId": FirebaseAuth.instance.currentUser!.uid,
          "receiverId": receiverID,
          "text": textMessage,
          "image": imageUrl,
          "timestamp": DateTime.now(),
          "isSeen": false,
          "updatedAt": DateTime.now(),
        });
        return true;
      } else if (imageUrl.isNotEmpty) {
        final userId = FirebaseAuth.instance.currentUser!.uid;
        FirebaseFirestore.instance.collection("chats").doc(chatRoomID).set({
          "chatroomId": chatRoomID,
          "participants": participants,
          "lastMessage": textMessage,
          "lastMessageTimestamp": DateTime.now(),
          "unreadCountOfUser1": userId == participants[0] ? 1 : 0,
          "unreadCountOfUser2": userId == participants[1] ? 1 : 0,
          "user1LastSeen": userId == participants[0] ? DateTime.now() : "",
          "user2LastSeen": userId == participants[1] ? DateTime.now() : "",
        });
        var chatroom = FirebaseFirestore.instance
            .collection("chats")
            .doc(chatRoomID)
            .collection("messages");
        await chatroom.doc().set({
          "senderId": userId,
          "receiverId": receiverID,
          "text": textMessage,
          "image": imageUrl,
          "timestamp": DateTime.now(),
          "isSeen": false,
          "updatedAt": DateTime.now(),
        });
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Failed to send image and text :$e');
      return false;
    }
  }

  Future<String> getDownloadLinkForChatFile({required File file}) async {
    try {
      final FirebaseStorage storage = FirebaseStorage.instance;
      final Reference chatImagesRef = storage.ref().child('chat_images');

      final imageFile = File(file.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final imageName = 'image_$timestamp.jpg';
      final imageRef = chatImagesRef.child(imageName);
      // Fluttertoast.showToast(msg: "sending Image...");
      await imageRef.putFile(imageFile);
      return await imageRef.getDownloadURL();
    } catch (e) {
      debugPrint('Failed to upload image :$e');
      return '';
    }
  }
}
