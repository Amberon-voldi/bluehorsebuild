import 'dart:developer';

import 'package:bluehorsebuild/screens/auth_screen.dart';
import 'package:bluehorsebuild/screens/main_screen.dart';
import 'package:bluehorsebuild/services/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  Future<Map> getData() async {
    var role = await SharedPreferencesHelper.getRole();
    var username = await SharedPreferencesHelper.getUsername();
    if ((role != null) && (username != null)) {
      return {"role": role, "username": username};
    } else {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Something went wrong",
                style: GoogleFonts.urbanist(
                  fontSize: 20,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.isNotEmpty) {
            log("Main Screen");
            return MainScreen(
              role: snapshot.data!["role"],
              username: snapshot.data!['username'],
            );
          } else {
            log("Auth Screen");
            return const AuthScreen();
          }
        },
      ),
    );
  }
}
