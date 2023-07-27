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
    final loginController = Get.find<LoginSignUpController>();

    loginController.email.value = "";
    loginController.password.value = "";
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: h * 0.1,
          ),
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 24.0, color: Colors.black),
              children: <TextSpan>[
                TextSpan(
                    text: 'Hello ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text: 'Beautiful',
                    style: TextStyle(color: Colors.deepOrange)),
                TextSpan(
                    text: ' .', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  decoration: InputDecoration(
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
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  decoration: InputDecoration(
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
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  decoration: InputDecoration(
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
              Icon(Icons.facebook_outlined),
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
            height: h * 0.2,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: InkWell(
              onTap: () {
                //TODO: Verify Login

                if (_regFormKey.currentState!.validate()) {
                  //TODo: Login user
                }
              },
              child: Container(
                margin: EdgeInsets.all(10),
                constraints:
                    BoxConstraints(minHeight: h * 0.04, maxWidth: w * 0.2),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.deepPurple[300]),
                child: Center(
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
    );
  }
}
