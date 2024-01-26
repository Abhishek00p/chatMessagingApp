import 'package:chatmassegeapp/Auth/login.dart';
import 'package:chatmassegeapp/Firebase/firebase.dart';
import 'package:chatmassegeapp/constants/colors.dart';
import 'package:chatmassegeapp/getControllers/userListController.dart';
import 'package:chatmassegeapp/models/userModel.dart';
import 'package:chatmassegeapp/models/chatRoomModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'chat.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String userNAME = "";

  getUserName() async {
    print("Curruser Id :${FirebaseAuth.instance.currentUser!.uid}");
    var result = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    var userDataResult = result.data();
    print(
        "user Details :${userDataResult?.keys.toList()}  ${userDataResult?.values.toList()}");

    setState(() {
      userNAME = userDataResult?["name"];
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getUserName();
    MyFirebase().updateOnlineStatus(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      MyFirebase().updateOnlineStatus(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    final userListController = Get.put(UserListController());
    return Scaffold(
      backgroundColor: background,
      body: SizedBox(
        height: h,
        width: w,
        child:
            // Obx(
            //   () =>
            Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: h * 0.05,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "The Chat App",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  IconButton(
                      onPressed: () async {
                        await MyFirebase().signOut();
                        Get.delete<UserListController>();

                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()));
                      },
                      icon: const Icon(
                        Icons.logout_outlined,
                        color: Colors.white,
                      ))
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              // Text("Hello, $userNAME ",style: ,)
              //     .marginSymmetric(horizontal: 25, vertical: 10),
              Container(
                height: h * 0.06,
                width: w,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black.withOpacity(0.25)),
                child: TextField(
                  style: TextStyle(color: Colors.white.withOpacity(0.6)),
                  decoration: InputDecoration(
                    hintText: "Search User Here...     Tip: 'komal'",
                    hintStyle: GoogleFonts.roboto(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w400),
                    // TextStyle(color: Colors.white.withOpacity(0.5)),
                    border: InputBorder.none,
                    // prefixIcon: Icon(
                    //   Icons.search,
                    //   color: Colors.white,
                    // ),
                    suffixIcon: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      userListController.searchTextEmpty.value = true;
                    } else {
                      userListController.searchTextEmpty.value = false;
                      userListController.listOfUSerNAmes.value =
                          userListController.listOFUSer.value
                              .where((element) => element.name
                                  .toString()
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                    }
                  },
                ),
              ),
              StreamBuilder(
                stream: MyFirebase().getAllUserList(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError || snapshot.data == null) {
                    return const SizedBox();
                  }

                  final usersDocs = snapshot.data!.docs;

                  var userList = usersDocs
                      .map((e) =>
                          UserModel.fromJson(e.data() as Map<String, dynamic>))
                      .toList();

                  if (FirebaseAuth.instance.currentUser != null) {
                    userList.removeWhere((element) =>
                        element.id == FirebaseAuth.instance.currentUser!.uid);
                  }

                  userListController.listOFUSer.value = userList;
                  return Obx(
                    () => Visibility(
                      visible: !userListController.searchTextEmpty.value,
                      child: Container(
                        constraints: BoxConstraints(maxHeight: h * 0.35),
                        padding: const EdgeInsets.all(8.0),
                        color: Colors.grey[200]?.withOpacity(0.2),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount:
                              userListController.listOfUSerNAmes.value.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                var userID = userListController
                                    .listOfUSerNAmes[index].id;
                                var currUSerID =
                                    FirebaseAuth.instance.currentUser!.uid;
                                var sortedlist = [userID, currUSerID]..sort();

                                Get.to(() => ChatPage(
                                    chatRoomId: sortedlist.join("-"),
                                    receiverID: userID,
                                    receiverName: userListController
                                        .listOfUSerNAmes[index].name,
                                    participants: sortedlist));
                              },
                              child: ListTile(
                                title: Text(
                                  userListController
                                          .listOfUSerNAmes.value[index].name ??
                                      'userWith no name',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: MyFirebase().getAllChatRoomList(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || snapshot.data == null) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "Start a new chat",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w300),
                        ),
                      );
                    }
                    final List usersDocs = snapshot.data!.docs;
                    //
                    final chatroomList = usersDocs
                        .map((e) =>
                            ChatRoom.fromJson(e.data() as Map<String, dynamic>))
                        .toList();
                    return SizedBox(
                      height: h * 0.7,
                      width: w,
                      child: ListView.builder(
                          itemCount: chatroomList.length,
                          itemBuilder: (context, index) {
                            var thisChatRoom = chatroomList[index];
                            var currUSerID =
                                FirebaseAuth.instance.currentUser!.uid;
                            var isCurrentUserFirstParticipant =
                                chatroomList[index].participants!.first ==
                                    currUSerID;
                            var userID = isCurrentUserFirstParticipant
                                ? chatroomList[index].participants!.last
                                : chatroomList[index].participants!.first;
                            var userName = isCurrentUserFirstParticipant
                                ? chatroomList[index].user2Name
                                : chatroomList[index].user1Name;

                            // var userProfile = isCurrentUserFirstParticipant? //TODO: need to implement
                            var userPRofile = '';
                            print("user receiver name : $userName");
                            //
                            var unReadcount = isCurrentUserFirstParticipant
                                ? chatroomList[index].unreadCountOfUser1
                                : chatroomList[index].unreadCountOfUser2;

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  Get.to(() => ChatPage(
                                        chatRoomId:
                                            chatroomList[index].chatroomId,
                                        receiverID: userID,
                                        receiverName: userName,
                                        participants:
                                            chatroomList[index].participants,
                                      ));
                                },
                                child: SizedBox(
                                  height: h * 0.07,
                                  // color: Colors.red,
                                  width: w,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      CircleAvatar(
                                        radius: h * 0.03,
                                        backgroundColor: Colors.white54,
                                        child: userPRofile.isEmpty
                                            ? const Icon(Icons.person)
                                            : Image.network(userPRofile),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      SizedBox(
                                        width: w * 0.5,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(userName ?? "",
                                                style: GoogleFonts.roboto(
                                                    fontSize: 15,
                                                    color: Colors.white)
                                                //  TextStyle(
                                                //     color: Colors.white
                                                //         .withOpacity(0.8))
                                                ),
                                            Text(
                                              chatroomList[index].lastMessage ??
                                                  "",
                                              style: GoogleFonts.roboto(
                                                  fontSize: 13,
                                                  color: Colors.white),
                                              // TextStyle(
                                              //     color: Colors.white
                                              //         .withOpacity(0.4)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        DateFormat('h:mm a').format(
                                            chatroomList[index]
                                                .lastMessageTimestamp!
                                                .toDate()),
                                        style: GoogleFonts.roboto(
                                            fontSize: 15, color: Colors.white),
                                        //                                             TextStyle(
                                        // color:
                                        //     Colors.white.withOpacity(0.6))
                                      ),
                                      const SizedBox(
                                        width: 3,
                                      ),
                                      unReadcount == 0
                                          ? const SizedBox()
                                          : CircleAvatar(
                                              radius: 8,
                                              backgroundColor:
                                                  Colors.greenAccent,
                                              child: Center(
                                                  child: Text(
                                                "$unReadcount",
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12),
                                              )),
                                            )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  'Developed by : Abhishek H Prajapat',
                  style: TextStyle(
                      color: Colors.white54,
                      fontWeight: FontWeight.w300,
                      fontSize: 12),
                ),
              )
            ],
          ),
        ),
        // ),
      ),
    );
  }
}

/*

  Expanded(
                child: StreamBuilder<QuerySnapshot>(
              stream: MyFirebase().getAllUserList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final usersDocs = snapshot.data!.docs;

                    final userList  = usersDocs.map((e) => UserModel.fromJson(e.data() as Map<String,dynamic>)).toList();
                return ListView.builder(
                    itemCount: userList.length,
                    itemBuilder: (context, index) {

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            Get.to(() => ChatPage());
                          },
                          child: Container(
                            height: h * 0.1,
                            width: w,
                            decoration: BoxDecoration(border: Border.all()),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CircleAvatar(
                                  radius: w * 0.06,
                                  backgroundColor: Colors.red,
                                ),
                                Container(
                                  width: w * 0.55,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(userList[index].name??""),
                                      Text("${userList[index].email}"),
                                    ],
                                  ),
                                ),
                                Text("12:15 AM")
                              ],
                            ),
                          ),
                        ),
                      );
                    });
              },
            )),
 */
