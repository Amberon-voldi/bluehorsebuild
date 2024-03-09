import 'dart:convert';
import 'dart:developer';

import 'package:bluehorsebuild/services/apis.dart';
import 'package:bluehorsebuild/services/ledger_printer.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen(
      {super.key,
      required this.ledgerData,
      required this.role,
      required this.username});

  static const String id = "LedgerScreen";

  final Map<String, dynamic> ledgerData;
  final String username;
  final String role;

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  late Map<String, dynamic> data;

  @override
  void initState() {
    super.initState();
    data = widget.ledgerData;
  }

  @override
  Widget build(BuildContext context) {
    double bookingAmount =
        double.parse(data["shop_size"]) * double.parse(data["booking_rate"]);
    return Scaffold(
      body: FutureBuilder(
        future: Apis().getLedgerData(
            data["srno"],
            data["booking_interest"],
            bookingAmount,
            double.parse(
              data["gst"],
            ),
            widget.username,
            data),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            log(snapshot.error.toString());
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

          return ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const BackButton(),
                  IconButton(
                    onPressed: () async {
                      Fluttertoast.showToast(
                          msg: 'Generating Ledger PDF, please wait');
                      var snapshotData = snapshot.data!;
                      LedgerPrinter.printLedger(
                        data: data,
                        snapshotData: snapshotData["data"],
                        role: widget.role,
                        totalInterest: snapshotData["totalInterest"],
                        totalOutstanding: snapshotData["totalOutstanding"],
                        balanceAtRegistration:
                            snapshotData["balanceAtRegistration"],
                      );
                    },
                    icon: const Icon(
                      Icons.save,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Ledger(
                data: data,
                role: widget.role,
                totalInterest: snapshot.data!["totalInterest"],
                totalOutstanding: snapshot.data!["totalOutstanding"],
                balanceAtRegistration: snapshot.data!["balanceAtRegistration"],
                tableData: snapshot.data!["data"],
              )
            ],
          );
        },
      ),
    );
  }
}

class Ledger extends StatelessWidget {
  const Ledger({
    super.key,
    required this.data,
    required this.role,
    required this.balanceAtRegistration,
    required this.totalInterest,
    required this.totalOutstanding,
    required this.tableData,
  });

  final Map<String, dynamic> data;
  final String role;
  final List<List<dynamic>> tableData;
  final String totalInterest;
  final String totalOutstanding;
  final String balanceAtRegistration;

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                "assets/images/logo.png",
                fit: BoxFit.cover,
                height: 75,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "BLUE HORSE BUILDERS PRIVATE LIMITED",
                    style: GoogleFonts.urbanist(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    data["project_name"],
                    style: GoogleFonts.urbanist(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "(Customer ID: ${data["booking_id"]})",
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "(${data["status"] == null ? "Active" : "Inactive"})",
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(border: Border.all()),
          margin: const EdgeInsets.all(10.0),
          child: IntrinsicHeight(
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(5.0),
                    child: Headers(
                      data: {
                        "Name": data["name"],
                        "PAN": data["pan"],
                        "Mobile No.": data["mobile"],
                        "Address": data["address"],
                        "Email ID": data["email"],
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(left: BorderSide(), right: BorderSide()),
                    ),
                    padding: const EdgeInsets.all(5.0),
                    child: Headers(
                      data: {
                        "Co-Applicant": data["co_applicant"],
                        "Nominee": data["nominee"],
                        "PAN": data["co_applicant_pan"],
                        "Approved By": data["approved_by"],
                        "Channel Partner": data["channel_partner"],
                        "Relationship Manager": data["relationship_manager"],
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(5.0),
                    child: Headers(
                      data: {
                        "Date of Booking": data["booking_date"],
                        "Payment Plan": data["plan"],
                        "Unit Size(Sqft)": data["shop_size"],
                        "Rate(Rs./Sqft)": data["booking_rate"],
                        "Unit No.": data["shop_no"],
                        "Floor No": data["floor_no"],
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            "Statement of Account as on ${now.day} May ${now.year} at ${now.hour % 12}:${now.minute} ${now.hour >= 12 ? "PM" : "AM"} (By ${role.toUpperCase()})",
            textAlign: TextAlign.center,
            style: GoogleFonts.urbanist(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Divider(
          endIndent: 20.0,
          indent: 20.0,
        ),
        DataTable(
          dataRowMaxHeight: double.infinity,
          columns: [
            "S.NO.",
            "Date",
            "Particulars",
            "Debit(Rs.)",
            "Credit(Rs.)",
            "Balance(Rs.)",
            "Interest(Rs.)"
          ]
              .map(
                (entry) => DataColumn(
                  label: Text(
                    entry,
                    style: GoogleFonts.urbanist(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
          rows: tableData
              .map((row) => DataRow(
                  cells: row
                      .map(
                        (cell) => DataCell(
                          Text(
                            cell.toString(),
                            style: GoogleFonts.urbanist(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList()))
              .toList(),
        ),
        const Divider(
          endIndent: 20.0,
          indent: 20.0,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(right: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Payable Interest(Rs.) : $totalInterest",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Total Outstanding(Rs.) : $totalOutstanding",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "At the Time of Registration: $balanceAtRegistration",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Divider(
          endIndent: 20.0,
          indent: 20.0,
        ),
        const Text(
          "Other Charges:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Flex(
            direction: Axis.horizontal,
            children: [
              {
                "Car Parking": "Rs. ${data["car_parking"]}",
                "IFMC": "Rs. ${data["ifmc"]} per sqft",
                "ECC": "Rs. ${data["ecc"]} per sqft",
              },
              {
                "Power Backup": "Rs. ${data["power_backup"]}",
                "EEC": "Rs. ${data["eec"]}",
                "GST": "@ ${data["gst"]}%",
              },
              {
                "PLC": "${data["plc"]}% of Basic Sale Price",
                "FFC": "Rs. ${data["ffc"]} per sqft",
              }
            ]
                .map(
                  (container) => Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: container.entries
                          .map(
                            (entry) => Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    entry.key,
                                  ),
                                ),
                                const Text(
                                  ": ",
                                ),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                )
                .toList(),
          ),
        )
      ],
    );
  }
}

class Headers extends StatelessWidget {
  const Headers({
    super.key,
    required this.data,
  });

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: data.entries
          .map((entry) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    ": ",
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ))
          .toList(),
    );
  }
}
