import 'dart:developer';
import 'dart:html' as html;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class LedgerPrinter {
  static Future<void> printLedger({
    required List<List<dynamic>> snapshotData,
    required Map<String, dynamic> data,
    required String role,
  }) async {
    final pdf = pw.Document();
    // final pdfLogoImage = pw.RawImage(
    //   bytes: File("assets/images/logo.png").readAsBytesSync(),
    //   width: 75,
    //   height: 75,
    // );

    // final imageFile = File("${Directory.current.path}/assets/images/logo.png");
    // final bytes = await imageFile.readAsBytes();
    // log(bytes.toString());

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(10),
        build: (context) => [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 10.0),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
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
          ),
          pw.Container(
            margin: const pw.EdgeInsets.all(10.0),
            decoration: pw.BoxDecoration(border: pw.Border.all()),
            child: pw.Wrap(
              children: {
                "Name": data["name"],
                "PAN": data["pan"],
                "Mobile No.": data["mobile"],
                "Address": data["address"],
                "Email ID": data["email"],
                "Co-Applicant": data["co_applicant"],
                "Nominee": data["nominee"],
                "PAN": data["co_applicant_pan"],
                "Approved By": data["approved_by"],
                "Channel Partner": data["channel_partner"],
                "Relationship Manager": data["relationship_manager"],
                "Date of Booking": data["booking_date"],
                "Payment Plan": data["plan"],
                "Unit Size(Sqft)": data["shop_size"],
                "Rate(Rs./Sqft)": data["booking_rate"],
                "Unit No.": data["shop_no"],
                "Floor No": data["floor_no"],
              }
                  .entries
                  .map(
                    (entry) => pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(),
                      ),
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10.0),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                            child: pw.Text(
                              entry.key,
                              style: const pw.TextStyle(
                                fontSize: 13,
                                // fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Text(
                            ": ",
                            style: const pw.TextStyle(
                              fontSize: 13,
                              // fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              entry.value,
                              style: const pw.TextStyle(
                                fontSize: 13,
                                // fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            // pw.Row(
            //   crossAxisAlignment: pw.CrossAxisAlignment.start,
            //   children: [
            //     pw.Expanded(
            //       child: pw.Container(
            //         padding: pw.EdgeInsets.all(5.0),
            //         child: HeadersPdf(data: {
            //           "Name": data["name"],
            //           "PAN": data["pan"],
            //           "Mobile No.": data["mobile"],
            //           "Address": data["address"],
            //           "Email ID": data["email"],
            //         }),
            //       ),
            //     ),
            //     pw.Expanded(
            //       child: pw.Container(
            //         decoration: pw.BoxDecoration(
            //           border: pw.Border(
            //             left: pw.BorderSide(),
            //             right: pw.BorderSide(),
            //           ),
            //         ),
            //         padding: pw.EdgeInsets.all(5.0),
            //         child: HeadersPdf(data: {
            //           "Co-Applicant": data["co_applicant"],
            //           "Nominee": data["nominee"],
            //           "PAN": data["co_applicant_pan"],
            //           "Approved By": data["approved_by"],
            //           "Channel Partner": data["channel_partner"],
            //           "Relationship Manager": data["relationship_manager"],
            //         }),
            //       ),
            //     ),
            //     pw.Expanded(
            //       child: pw.Container(
            //         padding: pw.EdgeInsets.all(5.0),
            //         child: HeadersPdf(data: {
            //           "Date of Booking": data["booking_date"],
            //           "Payment Plan": data["plan"],
            //           "Unit Size(Sqft)": data["shop_size"],
            //           "Rate(Rs./Sqft)": data["booking_rate"],
            //           "Unit No.": data["shop_no"],
            //           "Floor No": data["floor_no"],
            //         }),
            //       ),
            //     ),
            //   ],
            // ),
          ),
          pw.Padding(
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
          //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
          //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
          // pw.DataTable(
          //   columns: [
          //     "S.NO.",
          //     "Date",
          //     "Particulars",
          //     "Debit(Rs.)",
          //     "Credit(Rs.)",
          //     "Balance(Rs.)",
          //     "Interest(Rs.)"
          //   ]
          //       .map(
          //         (entry) => pw.DataColumn(
          //           label: pw.Text(
          //             entry,
          //             style: pw.TextStyle(
          //               fontSize: 15,
          //               fontWeight: pw.FontWeight.bold,
          //             ),
          //           ),
          //         ),
          //       )
          //       .toList(),
          //   rows: snapshotData.map(
          //     (row) {
          //       return pw.DataRow(
          //         cells: row
          //             .map(
          //               (cell) => pw.DataCell(
          //                 pw.Text(
          //                   cell.toString(),
          //                   style:
          //                       pw.TextStyle(fontWeight: pw.FontWeight.normal),
          //                 ),
          //               ),
          //             )
          //             .toList(),
          //       );
          //     },
          //   ).toList(),
          // ),
        ],
      ),
    );

    _savePdf(pdf);
  }

  // static Future<Uint8List> _getPdfLogoImage() async {
  //   final imageProvider = const AssetImage("assets/images/logo.png");
  //   final image = await imageProvider.resolve(const ImageConfiguration()).image;
  //   final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //   return byteData.buffer.asUint8List();
  // }

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

class HeadersPdf extends pw.StatelessWidget {
  HeadersPdf({
    required this.data,
  });

  final Map<String, dynamic> data;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
      children: data.entries
          .map(
            (entry) => pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    entry.key,
                    style: const pw.TextStyle(
                      fontSize: 13,
                      // fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Text(
                  ": ",
                  style: const pw.TextStyle(
                    fontSize: 13,
                    // fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    entry.value,
                    style: const pw.TextStyle(
                      fontSize: 13,
                      // fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}
