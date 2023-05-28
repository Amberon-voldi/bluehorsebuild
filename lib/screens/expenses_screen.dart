import 'package:bluehorsebuild/components/custom_box.dart';
import 'package:bluehorsebuild/components/custom_button.dart';
import 'package:bluehorsebuild/components/custom_table.dart';
import 'package:bluehorsebuild/components/custom_textfield.dart';
import 'package:bluehorsebuild/services/apis.dart';
import 'package:bluehorsebuild/services/utils.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key, required this.role, required this.username});

  static const String id = "ExpensesScreen";

  final String role;
  final String username;

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  String? errorMessage;
  String? uploadedFileUrl;
  XFile? selectedFile;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Apis().getExpensesData(context, widget.role, widget.username),
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
                title: "Expenses",
                subtitle: "Submit new Expense",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: CustomTextField(
                        controller: titleController,
                        isDense: false,
                        hintText: "Enter Title",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: CustomTextField(
                        controller: amountController,
                        isDense: false,
                        hintText: "Enter Amount in Rupees",
                      ),
                    ),
                    CustomTextField(
                      controller: detailsController,
                      isDense: false,
                      hintText: "Enter Details",
                    ),
                    Visibility(
                      visible: errorMessage != null,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            errorMessage ?? "",
                            style: GoogleFonts.urbanist(
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Text("UPLOAD DOCUMENTS (ONLY PDF **)",
                        style: GoogleFonts.urbanist(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(
                      height: 10.0,
                    ),
                    CustomButton(
                      text: selectedFile != null
                          ? selectedFile!.name
                          : "Expense Receipt",
                      leadingIcon: selectedFile == null
                          ? const Icon(Icons.file_upload)
                          : null,
                      trailingIcon:
                          selectedFile != null ? const Icon(Icons.close) : null,
                      textStyle: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      color: Colors.purple.shade700,
                      onPressed: () async {
                        if (selectedFile != null) {
                          selectedFile = null;
                        } else {
                          selectedFile = await Utils().fileSelector();
                        }
                        setState(() {});
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          elevation: 5,
                        ),
                        onPressed: () async {
                          if (selectedFile == null) {
                            errorMessage = "Select a file";
                            return;
                          }
                          if (titleController.text.isEmpty ||
                              amountController.text.isEmpty ||
                              detailsController.text.isEmpty) {
                            errorMessage =
                                "Empty values in title, amount and details are not allowed..";
                            return;
                          }
                          showDialog(
                            context: context,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                          try {
                            Apis()
                                .uploadFile("doc-expense", selectedFile!)
                                .then((uploadedFileUrl) async {
                              var result = await Apis().createExpense(
                                  widget.username,
                                  widget.role,
                                  titleController.text,
                                  amountController.text,
                                  detailsController.text,
                                  uploadedFileUrl);
                              if (result) {
                                if (mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Expense submitted successfully')),
                                  );
                                  titleController.clear();
                                  amountController.clear();
                                  detailsController.clear();
                                  errorMessage = null;
                                  selectedFile = null;
                                  setState(() {});
                                }
                              }
                            });
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
                title: "Expenses",
                subtitle: "Submitted Expense",
                child: Column(
                  children: [
                    CustomTable(
                      tableData: snapshot.data!["submittedExpenses"]!,
                    ),
                  ],
                ),
              ),
              widget.role == "Admin"
                  ? CustomBox(
                      title: "Expenses",
                      subtitle: "Approved Expense",
                      child: Column(
                        children: [
                          CustomTable(
                            tableData: snapshot.data!["approvedExpenses"]!,
                          ),
                        ],
                      ),
                    )
                  : Container(),
              widget.role == "Admin"
                  ? CustomBox(
                      title: "Expenses",
                      subtitle: "Rejected Expense",
                      child: Column(
                        children: [
                          CustomTable(
                            tableData: snapshot.data!["rejectedExpenses"]!,
                          ),
                        ],
                      ),
                    )
                  : Container(),
            ],
          );
        });
  }
}
