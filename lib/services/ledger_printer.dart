import 'dart:html' as html;
import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

class LedgerPrinter {
  static Future<void> printLedger({
    required List<List<dynamic>> snapshotData,
    required Map<String, dynamic> data,
    required String role,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(10),
        build: (context) => [
          pw.Padding(
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
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
          pw.Wrap(
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
                  ),
                )
                .toList(),
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
        ],
      ),
    );

    _savePdf(pdf);
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
