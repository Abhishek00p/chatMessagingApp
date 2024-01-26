import 'package:chatmassegeapp/Auth/login.dart';
import 'package:chatmassegeapp/Screen/home.dart';
import 'package:chatmassegeapp/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'getControllers/loginController.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final loginController = Get.put(LoginSignUpController());

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home:
          FirebaseAuth.instance.currentUser != null ? const HomePage() : const LoginPage(),
    );
  }
}
