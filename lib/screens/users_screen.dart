import 'package:bluehorsebuild/components/custom_box.dart';
import 'package:bluehorsebuild/components/custom_table.dart';
import 'package:bluehorsebuild/components/custom_textfield.dart';
import 'package:bluehorsebuild/services/apis.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key, required this.role, required this.username});

  static const String id = "UsersScreen";

  final String role;
  final String username;

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Apis().getUsersData(context, widget.role, widget.username),
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

          return Column(
            children: [
              CustomBox(
                title: "User",
                subtitle: "Create new User",
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: CustomTextField(
                        controller: nameController,
                        isDense: false,
                        hintText: "Enter Name",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: CustomTextField(
                        controller: emailController,
                        isDense: false,
                        hintText: "Enter Email",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: CustomTextField(
                        controller: usernameController,
                        isDense: false,
                        hintText: "Enter Username (Min 6 characters)",
                      ),
                    ),
                    CustomTextField(
                      controller: passwordController,
                      isDense: false,
                      hintText:
                          "Enter Password (Min 6 alphanumeric characters)",
                    ),
                    Visibility(
                      visible: errorMessage != null,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: Text(
                        errorMessage ?? "",
                        style: GoogleFonts.urbanist(
                          color: Colors.red,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          elevation: 5,
                        ),
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                          try {
                            var result = await Apis().addUser(
                              widget.username,
                              widget.role,
                              nameController.text,
                              emailController.text,
                              usernameController.text,
                              passwordController.text,
                            );
                            if (result) {
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('User added successfully')),
                                );
                                nameController.clear();
                                emailController.clear();
                                usernameController.clear();
                                passwordController.clear();
                                errorMessage = null;
                                setState(() {});
                              }
                            } else {
                              Navigator.pop(context);
                              if (mounted) setState(() {});
                            }
                          } catch (error) {
                            errorMessage = error.toString();
                            setState(() {});
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text(
                            "SUBMIT",
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              CustomBox(
                title: "Users",
                subtitle: "Active Users",
                child: Column(
                  children: [
                    CustomTable(
                      tableData: snapshot.data!,
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }
}
