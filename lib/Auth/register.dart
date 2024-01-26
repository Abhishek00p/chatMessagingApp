/*
RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 24.0, color: Colors.black),
        children: <TextSpan>[
          TextSpan(text: 'Hello ', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: 'Beautiful', style: TextStyle(color: Colors.blue)),
          TextSpan(text: ' .', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
    */
import 'package:chatmassegeapp/Auth/login.dart';
import 'package:chatmassegeapp/Firebase/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Backend/funtions.dart';
import '../getControllers/loginController.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _regFormKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final loginController = Get.put(LoginSignUpController());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 0.1,
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Get.delete<LoginSignUpController>();
                        Get.offAll(() => const LoginPage(),
                            transition: Transition.rightToLeftWithFade,
                            duration: const Duration(seconds: 1));
                      },
                      child: SizedBox(
                        width: w * 0.2,
                        child: const Column(
                          children: [
                            Text("Login"),
                            SizedBox(
                              height: 5,
                            ),
                            // loginController.currentPageInd.value == 0
                            //     ? Divider(
                            //         color: Colors.black,
                            //       )
                            //     : SizedBox()
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        // loginController.currentPageInd.value = 1;
                        // Get.to(() => RegisterPage(),
                        //     transition: Transition.leftToRightWithFade,
                        //     duration: Duration(seconds: 1));
                      },
                      child: SizedBox(
                        width: w * 0.2,
                        child: const Column(
                          children: [
                            Text("Sign Up"),
                            SizedBox(
                              height: 5,
                            ),
                            Divider(
                              color: Colors.black,
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: h * 0.1,
                ),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 24.0, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'Hello ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: 'Beautiful',
                          style: TextStyle(color: Colors.deepOrange)),
                      TextSpan(
                          text: ' .',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                SizedBox(
                  height: h * 0.1,
                ),
                Form(
                  key: _regFormKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Enter Name',
                          hintStyle: TextStyle(color: Colors.grey),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange),
                          ),
                        ),
                        onChanged: (value) {
                          loginController.regName.value = value;
                        },
                        validator: (value) {
                          if (value!.length > 5) {
                            return null;
                          } else {
                            return "Name not Valid";
                          }
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Enter Email',
                          hintStyle: TextStyle(color: Colors.grey),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange),
                          ),
                        ),
                        onChanged: (value) {
                          loginController.regEmail.value = value;
                        },
                        validator: (value) {
                          if (MyFunctions().checkIsEmailValid(value!)) {
                            return null;
                          } else {
                            return "Email not Valid";
                          }
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Enter Password',
                          hintStyle: TextStyle(color: Colors.grey),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange),
                          ),
                        ),
                        onChanged: (value) {
                          loginController.regPassword.value = value;
                        },
                        validator: (value) {
                          if (value!.length < 5 || value.length > 8) {
                            return "Password length should be 5-8 long";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Confirm Password',
                          hintStyle: TextStyle(color: Colors.grey),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange),
                          ),
                        ),
                        onChanged: (value) {
                          // loginController.regPassword.value = value;
                        },
                        validator: (value) {
                          if (value!.length < 5 || value.length > 8) {
                            return "Password length should be 5-8 long";
                          }
                          if (value.length <= 8 && value.length >= 5) {
                            if (value == loginController.regPassword.value) {
                              return null;
                            } else {
                              return "Password Doesn't Matched ";
                            }
                          }
                          return null;
                        },
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: h * 0.04,
                ),
                Row(
                  children: [
                    const Icon(Icons.facebook_outlined),
                    InkWell(
                      onTap: () {
                        //TODO: Login via Google
                      },
                      child: Image.asset(
                        "assets/google.jfif",
                        height: h * 0.03,
                        width: w * 0.3,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: h * 0.1,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: InkWell(
                    onTap: () async {
                      const CircularProgressIndicator();
                      if (_regFormKey.currentState!.validate()) {
                        User? user = await MyFirebase()
                            .registerWithEmailPassword(
                                loginController.regEmail.value,
                                loginController.regPassword.value,
                                loginController.regName.value);
                        if (user != null) {
                          Get.delete<LoginSignUpController>();

                          Get.to(() => const LoginPage());
                        }
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      constraints: BoxConstraints(
                          minHeight: h * 0.04, maxWidth: w * 0.2),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.deepPurple[300]),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
