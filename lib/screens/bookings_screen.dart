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

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key, required this.role, required this.username});

  static const String id = "BookingsScreen";

  final String role;
  final String username;

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  List<MapEntry<String, String>> projectsMap = [];
  TextEditingController dateOfBookingController =
      TextEditingController(text: "dd-mm-yyyy");
  TextEditingController channelPartnerController = TextEditingController();
  TextEditingController relationshipManagerController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController panController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController mailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController coApplicantController = TextEditingController();
  TextEditingController coApplicantPanController = TextEditingController();
  TextEditingController nomineeController = TextEditingController();
  TextEditingController nomineeRelationController = TextEditingController();
  TextEditingController bookingRateController = TextEditingController();
  TextEditingController sizeController = TextEditingController();
  TextEditingController annualInterestRateController = TextEditingController();
  TextEditingController floorController = TextEditingController();
  TextEditingController shopController = TextEditingController();
  TextEditingController parkingController = TextEditingController();
  TextEditingController backupController = TextEditingController();
  TextEditingController plcController = TextEditingController();
  TextEditingController ifmcController = TextEditingController();
  TextEditingController eecController = TextEditingController();
  TextEditingController ffcController = TextEditingController();
  TextEditingController eccController = TextEditingController();
  TextEditingController gstController = TextEditingController();
  late List<TextEditingController> controllers;

  String? selectedProject;
  String? selectedPaymentPlan;
  String? errorMessage;
  String? uploadedPanUrl;
  XFile? selectedPan;
  String? uploadedAddressProofUrl;
  XFile? selectedAddressProof;
  String? uploadedAgreementCopyUrl;
  XFile? selectedAgreementCopy;

  @override
  void initState() {
    super.initState();
    getProjectList();
    controllers = [
      channelPartnerController,
      relationshipManagerController,
      nameController,
      panController,
      mobileController,
      mailController,
      addressController,
      coApplicantController,
      coApplicantPanController,
      nomineeController,
      nomineeRelationController,
      bookingRateController,
      sizeController,
      annualInterestRateController,
      floorController,
      shopController,
      parkingController,
      backupController,
      plcController,
      ifmcController,
      eecController,
      ffcController,
      eccController,
      gstController,
    ];
  }

  Future<void> getProjectList() async {
    projectsMap =
        List<MapEntry<String, String>>.from(await Apis().getProjects());
  }

  @override
  Widget build(BuildContext context) {
    double availableWidth = MediaQuery.of(context).size.width - 365;

    return FutureBuilder(
        future: Apis().getBookingsData(context, widget.role, widget.username),
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
                title: "Bookings",
                subtitle: "Create new booking",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: (availableWidth - 50) / 3,
                          child: DropdownButton2(
                            isExpanded: true,
                            buttonStyleData: const ButtonStyleData(
                              padding: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                border: Border.fromBorderSide(BorderSide.none),
                              ),
                            ),
                            iconStyleData: const IconStyleData(iconSize: 0),
                            dropdownStyleData: const DropdownStyleData(
                                padding: EdgeInsets.zero),
                            hint: Text(
                              "Select a project",
                              style: GoogleFonts.urbanist(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            items: projectsMap
                                .map(
                                  (entry) => DropdownMenuItem(
                                    value: entry.key,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        entry.value,
                                        style: GoogleFonts.urbanist(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            value: selectedProject,
                            onChanged: (value) {
                              selectedProject = value as String;
                              setState(() {});
                            },
                          ),
                        ),
                        SizedBox(
                          width: (availableWidth - 50) / 3,
                          child: CustomTextField(
                            controller: channelPartnerController,
                            hintText: "Channel Partner",
                          ),
                        ),
                        SizedBox(
                          width: (availableWidth - 50) / 3,
                          child: CustomTextField(
                            controller: relationshipManagerController,
                            hintText: "Relationship Manager",
                          ),
                        ),
                        Container()
                      ],
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      "KYC DETAILS",
                      style: GoogleFonts.urbanist(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: (availableWidth - 60) / 4,
                          child: CustomTextField(
                            controller: nameController,
                            hintText: "Name",
                          ),
                        ),
                        SizedBox(
                          width: (availableWidth - 60) / 4,
                          child: CustomTextField(
                            controller: panController,
                            hintText: "PAN No.",
                          ),
                        ),
                        SizedBox(
                          width: (availableWidth - 60) / 4,
                          child: CustomTextField(
                            controller: mobileController,
                            hintText: "Mobile No.",
                          ),
                        ),
                        SizedBox(
                          width: (availableWidth - 60) / 4,
                          child: CustomTextField(
                            controller: mailController,
                            hintText: "Mail ID",
                          ),
                        ),
                        Container()
                      ],
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    CustomTextField(
                      controller: addressController,
                      hintText: "Address",
                      maxLines: 3,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: (availableWidth - 30) / 2,
                          child: CustomTextField(
                            controller: coApplicantController,
                            hintText: "Co Applicant Name",
                          ),
                        ),
                        SizedBox(
                          width: (availableWidth - 30) / 2,
                          child: CustomTextField(
                            controller: coApplicantPanController,
                            hintText: "Co Applicant PAN",
                          ),
                        ),
                        Container()
                      ],
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: (availableWidth - 30) / 2,
                          child: CustomTextField(
                            controller: nomineeController,
                            hintText: "Nominee Name",
                          ),
                        ),
                        SizedBox(
                          width: (availableWidth - 30) / 2,
                          child: CustomTextField(
                            controller: nomineeRelationController,
                            hintText: "Nominee Relation",
                          ),
                        ),
                        Container()
                      ],
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      "BOOKING DETAILS",
                      style: GoogleFonts.urbanist(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: (availableWidth - 50) / 3,
                          child: CustomDateTextField(
                            controller: dateOfBookingController,
                            title: "Date of Booking",
                          ),
                        ),
                        const SizedBox(
                          width: 25,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Payment Plan",
                              style: GoogleFonts.urbanist(
                                color: Colors.grey,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              width: (availableWidth - 50) / 3,
                              child: DropdownButton2(
                                isExpanded: true,
                                buttonStyleData: const ButtonStyleData(
                                  padding: EdgeInsets.zero,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.fromBorderSide(BorderSide.none),
                                  ),
                                ),
                                iconStyleData: const IconStyleData(iconSize: 0),
                                dropdownStyleData: const DropdownStyleData(
                                    padding: EdgeInsets.zero),
                                hint: Text(
                                  "Select Payment Plan",
                                  style: GoogleFonts.urbanist(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                items: [
                                  "Select Payment Plan",
                                  "TLP",
                                  "FLEXI",
                                  "DP",
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
                                value: selectedPaymentPlan,
                                onChanged: (value) {
                                  selectedPaymentPlan = value as String;
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: (availableWidth - 30) / 2,
                          child: CustomTextField(
                            controller: bookingRateController,
                            hintText: "Rate of Booking (per sqft)",
                          ),
                        ),
                        SizedBox(
                          width: (availableWidth - 30) / 2,
                          child: CustomTextField(
                            controller: sizeController,
                            hintText: "Shop Size (in sqft)",
                          ),
                        ),
                        Container()
                      ],
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
                            controller: annualInterestRateController,
                            hintText: "Annual Rate of Interest",
                          ),
                        ),
                        SizedBox(
                          width: (availableWidth - 50) / 3,
                          child: CustomTextField(
                            controller: floorController,
                            hintText:
                                "Preferred Floor No.(In 2 digits like 01, 00, 02 etc,)",
                          ),
                        ),
                        SizedBox(
                          width: (availableWidth - 50) / 3,
                          child: CustomTextField(
                            controller: shopController,
                            hintText:
                                "Preferred Shop No.(In 2 digits like 01, 00, 02 etc,)",
                          ),
                        ),
                        Container()
                      ],
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: (availableWidth - 60) / 4,
                          child: CustomTextField(
                            controller: parkingController,
                            hintText: "Car Parking",
                          ),
                        ),
                        SizedBox(
                          width: (availableWidth - 60) / 4,
                          child: CustomTextField(
                            controller: backupController,
                            hintText: "Power Backup",
                          ),
                        ),
                        SizedBox(
                          width: (availableWidth - 60) / 4,
                          child: CustomTextField(
                            controller: plcController,
                            hintText: "PLC (%)",
                          ),
                        ),
                        SizedBox(
                          width: (availableWidth - 60) / 4,
                          child: CustomTextField(
                            controller: ifmcController,
                            hintText: "IFMC (per sqft)",
                          ),
                        ),
                        Container()
                      ],
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: (availableWidth - 60) / 4,
                          child: CustomTextField(
                            controller: eecController,
                            hintText: "EEC (per sqft)",
                          ),
                        ),
                        SizedBox(
                          width: (availableWidth - 60) / 4,
                          child: CustomTextField(
                            controller: ffcController,
                            hintText: "FFC (per sqft)",
                          ),
                        ),
                        SizedBox(
                          width: (availableWidth - 60) / 4,
                          child: CustomTextField(
                            controller: eccController,
                            hintText: "ECC (per sqft)",
                          ),
                        ),
                        SizedBox(
                          width: (availableWidth - 60) / 4,
                          child: CustomTextField(
                            controller: gstController,
                            hintText: "GST (%)",
                          ),
                        ),
                        Container()
                      ],
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
                    Text(
                      "UPLOAD DOCUMENTS (ONLY PDF **)",
                      style: GoogleFonts.urbanist(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    CustomButton(
                      text: selectedPan != null
                          ? selectedPan!.name
                          : "PAN Card *",
                      leadingIcon: selectedPan == null
                          ? const Icon(Icons.file_upload)
                          : null,
                      trailingIcon:
                          selectedPan != null ? const Icon(Icons.close) : null,
                      textStyle: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      color: Colors.purple.shade700,
                      onPressed: () async {
                        if (selectedPan != null) {
                          selectedPan = null;
                        } else {
                          selectedPan = await Utils().fileSelector();
                        }
                        setState(() {});
                      },
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    CustomButton(
                      text: selectedAddressProof != null
                          ? selectedAddressProof!.name
                          : "Address Proof *",
                      leadingIcon: selectedAddressProof == null
                          ? const Icon(Icons.file_upload)
                          : null,
                      trailingIcon: selectedAddressProof != null
                          ? const Icon(Icons.close)
                          : null,
                      textStyle: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      color: Colors.purple.shade700,
                      onPressed: () async {
                        if (selectedAddressProof != null) {
                          selectedAddressProof = null;
                        } else {
                          selectedAddressProof = await Utils().fileSelector();
                        }
                        setState(() {});
                      },
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    CustomButton(
                      text: selectedAgreementCopy != null
                          ? selectedAgreementCopy!.name
                          : "Agreement Copy *",
                      leadingIcon: selectedAgreementCopy == null
                          ? const Icon(Icons.file_upload)
                          : null,
                      trailingIcon: selectedAgreementCopy != null
                          ? const Icon(Icons.close)
                          : null,
                      textStyle: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      color: Colors.purple.shade700,
                      onPressed: () async {
                        if (selectedAgreementCopy != null) {
                          selectedAgreementCopy = null;
                        } else {
                          selectedAgreementCopy = await Utils().fileSelector();
                        }
                        setState(() {});
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CustomButton(
                        text: "SUBMIT",
                        color: Colors.purple,
                        onPressed: () {
                          var project = projectsMap.firstWhere(
                              (element) => element.key == selectedProject);
                          var projectName = project.value;
                          var projectCode = project.key;

                          if (selectedPan == null ||
                              selectedAddressProof == null ||
                              selectedAddressProof == null) {
                            errorMessage = "Select files";
                            return;
                          }
                          if (controllers.any(
                                  (controller) => controller.text.isEmpty) ||
                              selectedProject == null ||
                              selectedPaymentPlan == null) {
                            errorMessage = "Empty values not allowed..";
                            return;
                          }
                          showDialog(
                            context: context,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                          try {
                            Future.wait([
                              Apis().uploadFile("doc-pan", selectedPan!),
                              Apis().uploadFile(
                                  "doc-address", selectedAddressProof!),
                              Apis().uploadFile(
                                  "doc-agreement", selectedAgreementCopy!),
                            ]).then((fileUrls) {
                              uploadedPanUrl = fileUrls[0];
                              uploadedAddressProofUrl = fileUrls[1];
                              uploadedAgreementCopyUrl = fileUrls[2];
                            }).then((_) async {
                              var result = await Apis().createBooking(
                                widget.username,
                                widget.role,
                                projectName,
                                projectCode,
                                floorController.text,
                                shopController.text,
                                channelPartnerController.text,
                                relationshipManagerController.text,
                                nameController.text,
                                panController.text,
                                mobileController.text,
                                mailController.text,
                                addressController.text,
                                coApplicantController.text,
                                coApplicantPanController.text,
                                nomineeController.text,
                                nomineeRelationController.text,
                                dateOfBookingController.text,
                                selectedPaymentPlan!,
                                annualInterestRateController.text,
                                bookingRateController.text,
                                sizeController.text,
                                parkingController.text,
                                backupController.text,
                                plcController.text,
                                ifmcController.text,
                                eecController.text,
                                ffcController.text,
                                eccController.text,
                                gstController.text,
                                uploadedPanUrl!,
                                uploadedAddressProofUrl!,
                                uploadedAgreementCopyUrl!,
                              );
                              if (result) {
                                if (mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Booking submitted successfully')),
                                  );
                                  for (var controller in controllers) {
                                    controller.clear();
                                  }
                                  errorMessage = null;
                                  selectedPan = null;
                                  selectedAddressProof = null;
                                  selectedAgreementCopy = null;
                                  setState(() {});
                                }
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
                title: "Bookings",
                subtitle: "All Uploaded Bookings",
                child: Column(
                  children: [
                    CustomTable(
                      isTopScrollbarVisible: true,
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
