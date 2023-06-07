import 'package:bluehorsebuild/screens/bookings_screen.dart';
import 'package:bluehorsebuild/wrapper.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: BookingsScreen(
            role: "Admin",
            username: "rajanmishra",
          ),
        ),
      ),
    );
  }
}
