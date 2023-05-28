import 'dart:developer';

import 'package:bluehorsebuild/services/apis.dart';
import 'package:bluehorsebuild/screens/main_screen.dart';
import 'package:bluehorsebuild/services/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  static const String id = "AuthScreen";

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  String role = "Staff";

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: role == "Admin" ? Colors.black12 : null,
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background_image.png"),
            fit: BoxFit.cover,
          ),
        ),
        alignment: Alignment.center,
        child: SizedBox(
          height: 550,
          width: 400,
          child: Column(
            children: [
              Container(
                height: 480,
                width: 400,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(80.0)),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: kElevationToShadow[24],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 90.0),
                      child: Text(
                        role == "Admin" ? "ADMIN" : "STAFF",
                        style: GoogleFonts.urbanist(
                          color: Colors.white,
                          fontSize: 50,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                    ),
                    Container(
                      width: 200,
                      margin: const EdgeInsets.only(bottom: 40.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              hintText: "Username",
                              hintStyle: GoogleFonts.urbanist(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          TextFormField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              hintText: "Password",
                              hintStyle: GoogleFonts.urbanist(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF691616),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      onPressed: () {
                        Apis()
                            .signIn(usernameController.text, role,
                                passwordController.text)
                            .then((signInResult) {
                          if (signInResult) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Authentication successful')),
                            );
                            SharedPreferencesHelper.setUsername(
                                usernameController.text);
                            SharedPreferencesHelper.setRole(role);
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MainScreen(
                                      role: role,
                                      username: usernameController.text),
                                ),
                                (route) => false);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Authentication failed')),
                            );
                          }
                        }).catchError((error) {
                          log(error.toString());
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$error')),
                          );
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 50.0),
                        child: Text(
                          "Sign In",
                          style: GoogleFonts.urbanist(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: InkWell(
                  onTap: () {
                    if (role == "Staff") {
                      role = "Admin";
                    } else {
                      role = "Staff";
                    }
                    usernameController.clear();
                    passwordController.clear();
                    setState(() {});
                  },
                  child: Text(
                    "Switch to ${role == "Admin" ? "Staff" : "Admin"} Login",
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
