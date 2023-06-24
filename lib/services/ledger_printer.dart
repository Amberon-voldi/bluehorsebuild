import 'dart:html' as html;
import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

class LedgerPrinter {
  static Future<void> printLedger({
    required List<List<dynamic>> snapshotData,
    required Map<String, dynamic> data,
    required String role,
    required String totalInterest,
    required String totalOutstanding,
    required String balanceAtRegistration,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(10),
        build: (context) {
          var address = data["address"].toString();
          return [
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 40.0, vertical: 10.0),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        "BLUE HORSE BUILDERS PRIVATE LIMITED",
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        data["project_name"],
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        "(Customer ID: ${data["booking_id"]})",
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        "(${data["status"] == null ? "Active" : "Inactive"})",
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.Container(
              decoration: pw.BoxDecoration(border: pw.Border.all()),
              margin: const pw.EdgeInsets.all(10.0),
              child: pw.Flex(
                direction: pw.Axis.horizontal,
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(5.0),
                      child: buildHeaders({
                        "Name": data["name"],
                        "PAN": data["pan"],
                        "Mobile No.": data["mobile"],
                        "Address": address.substring(
                                0, address.length > 48 ? 48 : address.length) +
                            (address.length > 45 ? "..." : ""),
                        "Email ID": data["email"],
                      }),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Container(
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                            left: pw.BorderSide(), right: pw.BorderSide()),
                      ),
                      padding: const pw.EdgeInsets.all(5.0),
                      child: buildHeaders({
                        "Co-Applicant": data["co_applicant"],
                        "Nominee": data["nominee"],
                        "PAN": data["co_applicant_pan"],
                        "Approved By": data["approved_by"],
                        "Channel Partner": data["channel_partner"],
                        "Relationship Manager": data["relationship_manager"],
                      }),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(5.0),
                      child: buildHeaders({
                        "Date of Booking": data["booking_date"],
                        "Payment Plan": data["plan"],
                        "Unit Size(Sqft)": data["shop_size"],
                        "Rate(Rs./Sqft)": data["booking_rate"],
                        "Unit No.": data["shop_no"],
                        "Floor No": data["floor_no"],
                      }),
                    ),
                  ),
                ],
              ),
            ),
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 10.0),
                child: pw.Text(
                  "Statement of Account as on ${DateTime.now().day} May ${DateTime.now().year} at ${DateTime.now().hour % 12}:${DateTime.now().minute} ${DateTime.now().hour >= 12 ? "PM" : "AM"} (By ${role.toUpperCase()})",
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
            pw.Divider(
              endIndent: 20.0,
              indent: 20.0,
            ),
            pw.TableHelper.fromTextArray(
              headers: [
                "S.NO.",
                "Date",
                "Particulars",
                "Debit(Rs.)",
                "Credit(Rs.)",
                "Balance(Rs.)",
                "Interest(Rs.)"
              ],
              data: snapshotData,
            ),
            pw.Divider(
              endIndent: 20.0,
              indent: 20.0,
            ),
            pw.Text(
              "Payable Interest(Rs.) : $totalInterest",
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              "Payable Interest(Rs.) : $totalOutstanding",
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              "At the Time of Registration: $balanceAtRegistration",
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Divider(
              endIndent: 20.0,
              indent: 20.0,
            ),
            pw.Text(
              "Other Charges:",
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(10.0),
              child: pw.Flex(
                direction: pw.Axis.horizontal,
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
                      (container) => pw.Expanded(
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          mainAxisSize: pw.MainAxisSize.max,
                          children: container.entries
                              .map(
                                (entry) => pw.Row(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Expanded(
                                      child: pw.Text(
                                        entry.key,
                                      ),
                                    ),
                                    pw.Text(
                                      ": ",
                                    ),
                                    pw.Expanded(
                                      child: pw.Text(
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
          ];
        },
      ),
    );

    _savePdf(pdf);
  }

  static pw.Widget buildHeaders(Map<String, dynamic> data) {
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
      children: data.entries
          .map((entry) => pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      entry.key,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Text(
                    ": ",
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      entry.value.toString(),
                      maxLines: 3,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ))
          .toList(),
    );
  }

  static Future<void> _savePdf(pw.Document pdf) async {
    final Uint8List bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final html.AnchorElement anchor =
        html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download = 'ledger.pdf';

    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
}
