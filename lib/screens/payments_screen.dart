import 'dart:developer';

import 'package:bluehorsebuild/components/custom_box.dart';
import 'package:bluehorsebuild/components/custom_button.dart';
import 'package:bluehorsebuild/components/custom_table.dart';
import 'package:bluehorsebuild/components/custom_textfield.dart';
import 'package:bluehorsebuild/services/apis.dart';
import 'package:bluehorsebuild/services/utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key, required this.role, required this.username});

  static const String id = "PaymentsScreen";

  final String role;
  final String username;

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  TextEditingController dateOfPaymentController =
      TextEditingController(text: "yyyy-mm-dd");
  TextEditingController customerIdController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController referenceController = TextEditingController();
  String? paymentMode;
  String? errorMessage;
  String? uploadedFileUrl;
  XFile? selectedFile;

  @override
  Widget build(BuildContext context) {
    double availableWidth = MediaQuery.of(context).size.width - 365;
    return FutureBuilder(
        future: Apis().getPaymentsData(context, widget.role, widget.username),
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
                title: "Payments",
                subtitle: "Create new Payment",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: (availableWidth - 50) / 3,
                      child: CustomDateTextField(
                        controller: dateOfPaymentController,
                        title: "Date of Payment",
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: (availableWidth - 50) / 3,
                          child: CustomTextField(
                            controller: customerIdController,
                            hintText: "Booking ID",
                          ),
                        ),
                        SizedBox(
                          width: (availableWidth - 50) / 3,
                          child: CustomTextField(
                            controller: amountController,
                            hintText: "Amount",
                          ),
                        ),
                        SizedBox(
                          width: (availableWidth - 50) / 3,
                          child: CustomTextField(
                            controller: referenceController,
                            hintText: "Reference",
                          ),
                        ),
                        Container()
                      ],
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Text("Payment Mode",
                        style: GoogleFonts.urbanist(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        )),
                    const SizedBox(
                      height: 5.0,
                    ),
                    SizedBox(
                      width: (availableWidth - 50) / 3,
                      child: DropdownButton2(
                        isExpanded: true,
                        buttonStyleData: const ButtonStyleData(
                          decoration: BoxDecoration(
                            border: Border.fromBorderSide(BorderSide.none),
                          ),
                        ),
                        iconStyleData: const IconStyleData(iconSize: 0),
                        menuItemStyleData: const MenuItemStyleData(height: 35),
                        dropdownStyleData:
                            const DropdownStyleData(padding: EdgeInsets.zero),
                        hint: Text(
                          "Select Payment Mode",
                          style: GoogleFonts.urbanist(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        items: [
                          "Discount",
                          "Cheque",
                          "Demand Draft",
                          "Suspense",
                          "Others"
                        ]
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    value,
                                    style: GoogleFonts.urbanist(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        value: paymentMode,
                        onChanged: (value) {
                          paymentMode = value as String;
                          setState(() {});
                        },
                      ),
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
                          : "Payment Doc",
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
                      child: CustomButton(
                        text: "SUBMIT",
                        color: Colors.purple,
                        onPressed: () async {
                          if (selectedFile == null) {
                            errorMessage = "Select a file";
                            setState(() {});
                            return;
                          }
                          if (customerIdController.text.isEmpty ||
                              amountController.text.isEmpty ||
                              referenceController.text.isEmpty ||
                              paymentMode == null) {
                            errorMessage = "Empty values are not allowed..";
                            setState(() {});
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
                                .uploadFile("doc-payment", selectedFile!)
                                .then((uploadedFileUrl) async {
                              var result = await Apis().createPayment(
                                widget.username,
                                widget.role,
                                customerIdController.text,
                                dateOfPaymentController.text,
                                amountController.text,
                                referenceController.text,
                                paymentMode!,
                                uploadedFileUrl,
                              );
                              if (result) {
                                if (mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Payment submitted successfully'),
                                    ),
                                  );
                                  customerIdController.clear();
                                  dateOfPaymentController.clear();
                                  amountController.clear();
                                  referenceController.clear();
                                  paymentMode = null;
                                  errorMessage = null;
                                  selectedFile = null;
                                  setState(() {});
                                }
                              } else {
                                Navigator.pop(context);
                                if (mounted) setState(() {});
                              }
                            });
                          } catch (error) {
                            errorMessage = error.toString();
                            setState(() {});
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              CustomBox(
                title: "Payments",
                subtitle: "All uploaded Payments",
                child: Column(
                  children: [
                    CustomTable(
                      isShowEntriesVisible: false,
                      isTableOperationsVisible: true,
                      tableData: snapshot.data!["uploadedPayments"]!,
                    ),
                  ],
                ),
              ),
              widget.role == "Admin"
                  ? CustomBox(
                      title: "Payments",
                      subtitle: "All approved Payments",
                      child: Column(
                        children: [
                          CustomTable(
                            isShowEntriesVisible: false,
                            isTableOperationsVisible: true,
                            tableData: snapshot.data!["approvedPayments"]!,
                          ),
                        ],
                      ),
                    )
                  : Container(),
              widget.role == "Admin"
                  ? CustomBox(
                      title: "Payments",
                      subtitle: "All rejected Payments",
                      child: Column(
                        children: [
                          CustomTable(
                            isShowEntriesVisible: false,
                            isTableOperationsVisible: true,
                            tableData: snapshot.data!["rejectedPayments"]!,
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
