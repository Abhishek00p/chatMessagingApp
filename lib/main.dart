import 'package:chatmassegeapp/Auth/login.dart';
import 'package:chatmassegeapp/Auth/register.dart';
import 'package:chatmassegeapp/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'getControllers/loginController.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
      GetMaterialApp(debugShowCheckedModeBanner: false, home: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final pages = [LoginPage(), RegisterPage()];
  final _pageController = PageController();
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final loginController = Get.put(LoginSignUpController());

    return Scaffold(
      body: SafeArea(
        child: Container(
          height: h,
          width: w,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Obx(
              () => Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          loginController.currentPageInd.value = 0;
                        },
                        child: Column(
                          children: [
                            Text(
                              "Login",
                              style: TextStyle(
                                color: loginController.currentPageInd.value == 0
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            loginController.currentPageInd.value == 0
                                ? Container(
                                    width: w * 0.12,
                                    child: Divider(
                                      color: Colors.black,
                                    ),
                                  )
                                : SizedBox()
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      InkWell(
                        onTap: () {
                          loginController.currentPageInd.value = 1;
                        },
                        child: Column(
                          children: [
                            Text(
                              "Sign Up",
                              style: TextStyle(
                                color: loginController.currentPageInd.value == 1
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            loginController.currentPageInd.value == 1
                                ? Container(
                                    width: w * 0.12,
                                    child: Divider(
                                      color: Colors.black,
                                    ),
                                  )
                                : SizedBox()
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                        width: w,
                        child: PageView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: 2,
                            controller: _pageController,
                            onPageChanged: (ind) {
                              loginController.currentPageInd.value = ind;
                            },
                            itemBuilder: (context, ind) {
                              return pages[
                                  loginController.currentPageInd.value];
                            })),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
