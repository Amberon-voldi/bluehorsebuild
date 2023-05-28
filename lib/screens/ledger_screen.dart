import 'dart:developer';

import 'package:bluehorsebuild/services/apis.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key, required this.ledgerData, required this.role});

  static const String id = "LedgerScreen";

  final Map<String, dynamic> ledgerData;
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
    var now = DateTime.now();
    return Scaffold(
      // appBar: AppBar(
      //   foregroundColor: Colors.black,
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      // ),
      body: FutureBuilder(
          future: Apis().getLedgerData(data["srno"], data["booking_interest"]),
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
                Stack(
                  children: [
                    const BackButton(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50.0, vertical: 20.0),
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
                                  fontSize: 24,
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
                  ],
                ),
                Container(
                  height: 200,
                  decoration: BoxDecoration(border: Border.all()),
                  margin: const EdgeInsets.all(10.0),
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
                            border:
                                Border(left: BorderSide(), right: BorderSide()),
                          ),
                          padding: const EdgeInsets.all(5.0),
                          child: Headers(
                            data: {
                              "Co-Applicant": data["co_applicant"],
                              "Nominee": data["nominee"],
                              "PAN": data["co_applicant_pan"],
                              "Approved By": data["approved_by"],
                              "Channel Partner": data["channel_partner"],
                              "Relationship Manager":
                                  data["relationship_manager"],
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    "Statement of Account as on ${now.day} May ${now.year} at ${now.hour % 12}:${now.minute} ${now.hour >= 12 ? "PM" : "AM"} (By ${widget.role.toUpperCase()})",
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
                  rows: snapshot.data!
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
              ],
            );
          }),
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
                        // fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    ": ",
                    style: GoogleFonts.urbanist(
                      // fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: GoogleFonts.urbanist(
                        // fontSize: 16,
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
