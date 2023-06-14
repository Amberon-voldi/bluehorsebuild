import 'package:bluehorsebuild/components/custom_box.dart';
import 'package:bluehorsebuild/components/custom_table.dart';
import 'package:bluehorsebuild/components/custom_textfield.dart';
import 'package:bluehorsebuild/services/apis.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key, required this.role, required this.username});

  static const String id = "ProjectsScreen";

  final String role;
  final String username;

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Apis().getProjectsData(context, widget.role, widget.username),
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
                title: "Project",
                subtitle: "Create new project",
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
                    CustomTextField(
                      controller: codeController,
                      isDense: false,
                      hintText: "Enter Code (In 3 letters like BHB etc.)",
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
                            var result = await Apis().createProject(
                              widget.username,
                              widget.role,
                              nameController.text,
                              codeController.text,
                            );
                            if (result) {
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Project created successfully')),
                                );
                                nameController.clear();
                                codeController.clear();
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
                title: "Projects",
                subtitle: "Active Projects",
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
