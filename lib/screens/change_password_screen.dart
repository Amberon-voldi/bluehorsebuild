import 'package:bluehorsebuild/components/custom_box.dart';
import 'package:bluehorsebuild/components/custom_textfield.dart';
import 'package:bluehorsebuild/services/apis.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({
    super.key,
    required this.username,
    required this.role,
  });

  static const String id = "ChangePasswordScreen";

  final String username;
  final String role;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController repeatedPasswordController = TextEditingController();

  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomBox(
          title: "Settings",
          subtitle: "Change your password",
          child: Column(
            children: [
              Form(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: CustomTextField(
                        controller: currentPasswordController,
                        isDense: false,
                        hintText: "Enter old Password",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: CustomTextField(
                        controller: newPasswordController,
                        isDense: false,
                        hintText: "Enter new Password",
                      ),
                    ),
                    CustomTextField(
                      controller: repeatedPasswordController,
                      isDense: false,
                      hintText: "Repeat new Password",
                    ),
                  ],
                ),
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
                      var result = await Apis().changePassword(
                        widget.username,
                        widget.role,
                        currentPasswordController.text,
                        newPasswordController.text,
                        repeatedPasswordController.text,
                      );
                      if (result) {
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Password changed successfully')),
                          );
                          currentPasswordController.clear();
                          newPasswordController.clear();
                          repeatedPasswordController.clear();
                          errorMessage = null;
                          setState(() {});
                        }
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
      ],
    );
  }
}
