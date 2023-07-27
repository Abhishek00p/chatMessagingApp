import 'package:chatmassegeapp/Backend/funtions.dart';
import 'package:chatmassegeapp/getControllers/loginController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginFormKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final loginController = Get.find<LoginSignUpController>();
    loginController.email.value = "";
    loginController.password.value = "";
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: h * 0.2,
          ),
          Text(
            "Welcome Back,",
            style: TextStyle(fontSize: h * 0.04),
          ),
          Text(
            "Rebecca",
            style: TextStyle(fontSize: h * 0.04, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 20,
          ),
          Form(
            key: _loginFormKey,
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
                    loginController.email.value = value;
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
                    loginController.password.value = value;
                  },
                  validator: (value) {
                    if (value!.length < 5 || value.length > 8) {
                      return "Password length should be 5-8 long";
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
              },
              child: Container(
                margin: EdgeInsets.all(10),
                constraints:
                    BoxConstraints(minHeight: h * 0.04, maxWidth: w * 0.2),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.orange),
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
