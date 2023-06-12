import 'dart:convert';
import 'dart:developer';
import 'package:bluehorsebuild/components/clickable_text.dart';
import 'package:bluehorsebuild/components/custom_button.dart';
import 'package:bluehorsebuild/components/custom_textfield.dart';
import 'package:bluehorsebuild/screens/ledger_screen.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Apis {
  final String baseUrl = "https://www.bluehorsebuild.com/flutter-api";

  Future<bool> signIn(String username, String role, String password) async {
    try {
      final url = Uri.parse('$baseUrl/auth.php');
      final response = await http.post(
        url,
        body: {
          'login_type': role.toLowerCase(),
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          log(responseData.toString());
          return true;
        } else {
          throw responseData['message'];
        }
      } else {
        throw 'Something went wrong';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> changePassword(
      String username,
      String role,
      String currentPassword,
      String newPassword,
      String repeatedPassword) async {
    try {
      final url = Uri.parse('$baseUrl/password.php');
      final response = await http.post(
        url,
        body: {
          'login_type': getRole(role),
          'username': username,
          'oldpwd': currentPassword,
          'newpwd1': newPassword,
          'newpwd2': repeatedPassword,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          log(responseData.toString());
          return true;
        } else {
          throw responseData['message'];
        }
      } else {
        throw 'Something went wrong';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadFile(String docName, XFile file) async {
    try {
      final url = Uri.parse('$baseUrl/upload.php');

      var stream = http.ByteStream(file.openRead());
      int length = await file.length();
      var request = http.MultipartRequest("POST", url);
      var multipartFile =
          http.MultipartFile('file', stream, length, filename: file.name);

      request.fields['doc_name'] = docName;
      request.files.add(multipartFile);
      var response = await request.send();

      if (response.statusCode == 200) {
        var jsonResponse = await response.stream.bytesToString();
        final responseData = jsonDecode(jsonResponse);
        if (responseData['success'] == true) {
          log(responseData.toString());
          return responseData['url'];
        } else {
          throw responseData['message'];
        }
      } else {
        throw 'Something went wrong';
      }
    } catch (e) {
      rethrow;
    }
  }

  getRole(String role) {
    role = role.toLowerCase();
    if (role == "admin") {
      return "administrator";
    } else if (role == "staff") {
      return "employee";
    } else {
      throw "Invalid login type";
    }
  }

  Future<List<dynamic>> _fetchData(String query) async {
    try {
      final url = Uri.parse('$baseUrl/query.php');
      final response = await http.post(
        url,
        body: {
          'query': query,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        log(responseData['message']);
        if (responseData['success'] != null && responseData['success']) {
          return responseData['data'] ?? [];
        }
      } else {
        throw 'Something went wrong';
      }
    } catch (e) {
      rethrow;
    }

    return [];
  }

  Future<List<List<dynamic>>> getLogbookData(
      String role, String username) async {
    try {
      final query =
          "SELECT details, createdon FROM logbook WHERE role = '${getRole(role)}' AND id = '$username' ORDER BY srno DESC";
      var data = await _fetchData(query);
      List<List<dynamic>> result = [
        ["#", "Date/time", "Details"]
      ];
      for (var i = 0; i < data.length; i++) {
        result.add([
          "${i + 1}",
          data[i]["createdon"],
          data[i]["details"],
        ]);
      }
      return result;
    } catch (error) {
      rethrow;
    }
  }

  Future<List<List<dynamic>>> getProjectsData(
      BuildContext context, String role, String username) async {
    try {
      const query =
          "SELECT srno, name, code FROM projects WHERE status IS NULL ORDER BY srno DESC";
      var data = await _fetchData(query);
      List<List<dynamic>> result = [
        ["Name", "Code", ""]
      ];
      for (var i = 0; i < data.length; i++) {
        result.add([
          data[i]["name"],
          data[i]["code"],
          CustomButton(
            text: "DELETE",
            onPressed: () async {
              var isLoading = true;
              showDialog(
                context: context,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              try {
                var result =
                    await Apis().deleteProject(username, role, data[i]["srno"]);
                if (result) {
                  if (context.mounted) {
                    if (isLoading) Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Project deleted successfully')),
                    );
                  }
                }
              } catch (error) {
                if (isLoading) Navigator.pop(context);
                log(error.toString());
              }
            },
          ),
        ]);
      }
      return result;
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> createProject(
      String username, String role, String name, String code) async {
    try {
      final url = Uri.parse('$baseUrl/projects.php');
      final response = await http.post(
        url,
        body: {
          'login_type': getRole(role),
          'username': username,
          'name': name,
          'code': code,
          'mode': 'create',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          log(responseData.toString());
          return true;
        } else {
          throw responseData['message'];
        }
      } else {
        throw 'Something went wrong';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteProject(String username, String role, String srno) async {
    try {
      final url = Uri.parse('$baseUrl/projects.php');
      final response = await http.post(
        url,
        body: {
          'login_type': getRole(role),
          'username': username,
          'srno': srno,
          'mode': 'delete',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          log(responseData.toString());
          return true;
        } else {
          throw responseData['message'];
        }
      } else {
        throw 'Something went wrong';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<List<dynamic>>> getAdminsData(
      BuildContext context, String role, String username) async {
    try {
      final query =
          "SELECT srno, name, email, id FROM login WHERE status IS NULL && role = 'administrator' && id <> '$username' ORDER BY srno DESC";
      var data = await _fetchData(query);
      List<List<dynamic>> result = [
        ["Name", "Email", "Username", ""]
      ];
      for (var i = 0; i < data.length; i++) {
        result.add([
          data[i]["name"],
          data[i]["email"],
          data[i]["id"],
          CustomButton(
            text: "BLOCK",
            onPressed: () async {
              var isLoading = true;
              showDialog(
                context: context,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              try {
                var result = await Apis().blockAdmin(username, role,
                    data[i]["name"], data[i]["email"], data[i]["srno"]);
                if (result) {
                  if (context.mounted) {
                    if (isLoading) Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Admin blocked successfully')),
                    );
                  }
                }
              } catch (error) {
                if (isLoading) Navigator.pop(context);
                log(error.toString());
              }
            },
          ),
        ]);
      }
      return result;
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> addAdmin(String myUsername, String role, String name,
      String email, String username, String password) async {
    try {
      final url = Uri.parse('$baseUrl/admins.php');
      final response = await http.post(
        url,
        body: {
          'login_type': getRole(role),
          'id': myUsername,
          'mode': 'add',
          'name': name,
          'email': email,
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          log(responseData.toString());
          return true;
        } else {
          throw responseData['message'];
        }
      } else {
        throw 'Something went wrong';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> blockAdmin(String myUsername, String role, String name,
      String email, String srno) async {
    try {
      final url = Uri.parse('$baseUrl/admins.php');
      final response = await http.post(
        url,
        body: {
          'login_type': getRole(role),
          'id': myUsername,
          'name': name,
          'email': email,
          'srno': srno,
          'mode': 'block',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          log(responseData.toString());
          return true;
        } else {
          throw responseData['message'];
        }
      } else {
        throw 'Something went wrong';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<List<dynamic>>> getUsersData(
      BuildContext context, String role, String username) async {
    try {
      const query =
          "SELECT srno, name, email, id FROM login WHERE status IS NULL && role = 'employee' ORDER BY srno DESC";
      var data = await _fetchData(query);
      List<List<dynamic>> result = [
        ["Name", "Email", "Username", ""]
      ];
      for (var i = 0; i < data.length; i++) {
        result.add([
          data[i]["name"],
          data[i]["email"],
          data[i]["id"],
          CustomButton(
            text: "BLOCK",
            onPressed: () async {
              var isLoading = true;
              showDialog(
                context: context,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              try {
                var result = await Apis().blockUser(username, role,
                    data[i]["name"], data[i]["email"], data[i]["srno"]);
                if (result) {
                  if (context.mounted) {
                    if (isLoading) Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('User blocked successfully')),
                    );
                  }
                }
              } catch (error) {
                if (isLoading) Navigator.pop(context);
                log(error.toString());
              }
            },
          ),
        ]);
      }
      return result;
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> addUser(String myUsername, String role, String name,
      String email, String username, String password) async {
    try {
      final url = Uri.parse('$baseUrl/users.php');
      final response = await http.post(
        url,
        body: {
          'login_type': getRole(role),
          'id': myUsername,
          'mode': 'add',
          'name': name,
          'email': email,
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          log(responseData.toString());
          return true;
        } else {
          throw responseData['message'];
        }
      } else {
        throw 'Something went wrong';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> blockUser(String myUsername, String role, String name,
      String email, String srno) async {
    try {
      final url = Uri.parse('$baseUrl/users.php');
      final response = await http.post(
        url,
        body: {
          'login_type': getRole(role),
          'id': myUsername,
          'name': name,
          'email': email,
          'srno': srno,
          'mode': 'block',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          log(responseData.toString());
          return true;
        } else {
          throw responseData['message'];
        }
      } else {
        throw 'Something went wrong';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MapEntry<String, String>>> getProjects() async {
    try {
      const query =
          "SELECT name, code FROM projects WHERE status IS NULL ORDER BY srno DESC";
      var data = await _fetchData(query);
      List<MapEntry<String, String>> result = data
          .map((item) =>
              MapEntry(item["code"].toString(), item["name"].toString()))
          .toList();
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<List<dynamic>>> getBookingsData(
      BuildContext context, String role, String username) async {
    try {
      final query =
          "SELECT * FROM bookings ${(role == "Admin") ? "" : "WHERE user_id = '$username' && status IS NULL "}ORDER BY srno DESC";
      var data = await _fetchData(query);
      List<List<dynamic>> result = [
        [
          "#",
          "Ledger",
          "Status",
          "Approved By",
          "Booking ID",
          "Project Name",
          "Channel",
          "Partner	Name",
          "PAN",
          "Mobile",
          "Email",
          "Address",
          "Co-Applicant",
          "Nominee",
          "Relation",
          "Date",
          "Plan",
          "Rate(per sqft)",
          "Size( in sqft)",
          "Floor No.",
          "Shop No.",
          "Car Parking",
          "Power Backup",
          "PLC (%)",
          "IFMC (per sqft)",
          "EEC (per sqft)",
          "FFC (per sqft)",
          "ECC (per sqft)",
          "GST (%)",
          "Documents",
          role == "Admin" ? "" : null,
        ]
      ];
      var approvedByList = await _fetchData("SELECT name, id FROM login");
      for (var i = 0; i < data.length; i++) {
        var approvedBy = approvedByList.firstWhere(
            (element) => element["id"] == data[i]["user_id"])['name'];
        result.add([
          i + 1,
          CustomButton(
            text: "LEDGER",
            color: Colors.blue,
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LedgerScreen(
                    ledgerData: {...data[i], "approved_by": approvedBy},
                    role: role,
                  ),
                )),
          ),
          (data[i]['status'] == null
              ? "Active"
              : Text(
                  "Inactive",
                  style: GoogleFonts.urbanist(
                    color: Colors.red,
                  ),
                )),
          "$approvedBy(${data[i]["user_id"]})",
          data[i]['booking_id'],
          data[i]['project_name'],
          data[i]['channel_partner'],
          data[i]['name'],
          data[i]['pan'],
          data[i]['mobile'],
          data[i]['email'],
          data[i]['address'],
          data[i]['co_applicant'],
          data[i]['nominee'],
          data[i]['nominee_relation'],
          data[i]['booking_date'],
          data[i]['plan'],
          data[i]['booking_rate'],
          data[i]['shop_size'],
          data[i]['floor_no'],
          data[i]['shop_no'],
          data[i]['car_parking'],
          data[i]['power_backup'],
          data[i]['plc'],
          data[i]['ifmc'],
          data[i]['eec'],
          data[i]['ffc'],
          data[i]['ecc'],
          data[i]['gst'],
          Column(children: [
            data[i]["doc_pan"] == null
                ? const ClickableText(text: "No Pan Card")
                : ClickableText(
                    text: "Pan Card",
                    onPressed: () => launchUrl(Uri.parse(data[i]["doc_pan"])),
                  ),
            data[i]["doc_address"] == null
                ? const ClickableText(text: "No Address doc")
                : ClickableText(
                    text: "Address doc",
                    onPressed: () =>
                        launchUrl(Uri.parse(data[i]["doc_address"])),
                  ),
            data[i]["doc_agreement"] == null
                ? const ClickableText(text: "No Agreement doc")
                : ClickableText(
                    text: "Agreement doc",
                    onPressed: () =>
                        launchUrl(Uri.parse(data[i]["doc_agreement"])),
                  )
          ]),
          role == "Admin"
              ? CustomButton(
                  text: "INACTIVATE",
                  onPressed: () async {
                    var isLoading = true;
                    showDialog(
                      context: context,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                    try {
                      var result = await Apis()
                          .inactivateBooking(username, role, data[i]["srno"]);
                      if (result) {
                        if (context.mounted) {
                          if (isLoading) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Booking inactivated successfully')),
                          );
                        }
                      }
                    } catch (error) {
                      if (isLoading) Navigator.pop(context);
                      log(error.toString());
                    }
                  },
                )
              : null,
        ]);
      }
      return result;
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> createBooking(
    String username,
    String role,
    String projectName,
    String projectCode,
    String floor,
    String shop,
    String channelPartner,
    String relationshipManager,
    String name,
    String pan,
    String mobile,
    String email,
    String address,
    String coApplicant,
    String coApplicantPan,
    String nominee,
    String nomineeRelation,
    String bookingDate,
    String plan,
    String interest,
    String rate,
    String size,
    String parking,
    String backup,
    String plc,
    String ifmc,
    String eec,
    String ffc,
    String ecc,
    String gst,
    String docPan,
    String docAddress,
    String docAgreement,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/bookings.php');
      final response = await http.post(
        url,
        body: {
          'login_type': getRole(role),
          'id': username,
          'mode': 'create',
          "project_name": projectName,
          "project_code": projectCode,
          "floor_number": floor,
          "shop_number": shop,
          "channel_partner": channelPartner,
          "relationship_manager": relationshipManager,
          "name": name,
          "pan_number": pan,
          "mobile_number": mobile,
          "email": email,
          "address": address,
          "coapplicant_name": coApplicant,
          "coapplicant_pan": coApplicantPan,
          "nominee_name": nominee,
          "nominee_relation": nomineeRelation,
          "booking_date": bookingDate,
          "payment_plan": plan,
          "booking_interest": interest,
          "booking_rate": rate,
          "shop_size": size,
          "car_parking": parking,
          "power_backup": backup,
          "plc": plc,
          "ifmc": ifmc,
          "eec": eec,
          "ffc": ffc,
          "ecc": ecc,
          "gst": gst,
          "doc_pan": docPan,
          "doc_address": docAddress,
          "doc_agreement": docAgreement,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          log(responseData.toString());
          return true;
        } else {
          throw responseData['message'];
        }
      } else {
        throw 'Something went wrong';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> inactivateBooking(
      String username, String role, String srno) async {
    try {
      final url = Uri.parse('$baseUrl/bookings.php');
      final response = await http.post(
        url,
        body: {
          'login_type': getRole(role),
          'username': username,
          'srno': srno,
          'mode': 'inactivate',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          log(responseData.toString());
          return true;
        } else {
          throw responseData['message'];
        }
      } else {
        throw 'Something went wrong';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<List<dynamic>>> getLedgerData(
      String srno, String bookingInterest) async {
    try {
      final query =
          "SELECT * FROM payments WHERE (ref_id = '$srno' && status = 'approved') ORDER BY payment_date";
      var data = await _fetchData(query);
      List<List<dynamic>> results = [];
      int balance = 0;
      for (var i = 0; i < data.length; i++) {
        int diff = 0;
        double interest = 0;
        var previousBalance = balance;
        balance = balance +
            int.parse(data[i]["value_out"]) -
            int.parse(data[i]["value_in"]);
        var currentPaymentDateList = data[i]['payment_date']
            .toString()
            .split("-")
            .map((e) => int.parse(e))
            .toList();
        var currentDateTime = DateTime(currentPaymentDateList[0],
            currentPaymentDateList[1], currentPaymentDateList[2]);

        var previousPaymentDateList = (i > 0)
            ? data[i - 1]['payment_date']
                .toString()
                .split("-")
                .map((e) => int.parse(e))
                .toList()
            : null;
        var previousDateTime = previousPaymentDateList != null
            ? DateTime(previousPaymentDateList[0], previousPaymentDateList[1],
                previousPaymentDateList[2])
            : null;
        if ((i > 0) && (previousDateTime != null)) {
          if (DateTime.now().isAfter(currentDateTime)) {
            DateTime date1 = previousDateTime;
            DateTime date2 = currentDateTime;
            diff = date2.difference(date1).inDays;
            interest = (previousBalance *
                    int.parse(bookingInterest) /
                    100 *
                    diff /
                    365)
                .roundToDouble();
          } else {
            diff = 0;
          }
        } else {
          diff = 0;
        }
        if ((i > 0) && (previousDateTime != null)) {
          if (DateTime.now().isAfter(currentDateTime)) {
            DateTime date1 = previousDateTime;
            DateTime date2 = currentDateTime;
            diff = date2.difference(date1).inDays;
            interest = (previousBalance *
                    int.parse(bookingInterest) /
                    100 *
                    diff /
                    365)
                .roundToDouble();
          } else {
            diff = 0;
          }
        } else {
          diff = 0;
        }

        results.add([
          i + 1,
          data[i]["payment_date"],
          data[i]["ref"],
          data[i]["value_out"] == "0" ? "-" : data[i]["value_out"],
          data[i]["value_in"] == "0" ? "-" : data[i]["value_in"],
          balance,
          interest,
        ]);
      }
      return results;
    } catch (error) {
      rethrow;
    }
  }

  Future<Map<String, List<List<dynamic>>>> getPaymentsData(
      BuildContext context, String role, String username) async {
    try {
      final queries = {
        "uploadedPayments":
            "SELECT * FROM payments WHERE status IS NULL && ref = 'Payment' ORDER BY srno DESC",
        ...role == "Admin"
            ? {
                "approvedPayments":
                    "SELECT * FROM payments WHERE status = 'approved' && ref = 'Payment' ORDER BY srno DESC"
              }
            : {},
        ...role == "Admin"
            ? {
                "rejectedPayments":
                    "SELECT * FROM payments WHERE status = 'rejected' && ref = 'Payment' ORDER BY srno DESC"
              }
            : {},
      };
      var headerList = [
        "#",
        "Uploaded On",
        "Booking ID",
        "Uploaded By",
        "Amount",
        "Date",
        "Mode",
        "Reference",
        "Documents",
      ];
      Map<String, List<List<dynamic>>> result = {
        "uploadedPayments": [
          [
            ...headerList,
            ...role == "Admin" ? ["", ""] : []
          ]
        ],
        ...role == "Admin"
            ? {
                "approvedPayments": [headerList]
              }
            : {},
        ...role == "Admin"
            ? {
                "rejectedPayments": [headerList]
              }
            : {},
      };
      var bookingId = await _fetchData("SELECT srno, booking_id FROM bookings");
      for (var entry in queries.entries) {
        var data = await _fetchData(entry.value);
        for (var i = 0; i < data.length; i++) {
          result[entry.key]!.add([
            data[i]["srno"],
            data[i]["createdon"],
            bookingId.firstWhere((element) =>
                element["srno"] == data[i]["ref_id"])["booking_id"],
            "(${data[i]["id"]})",
            data[i]["value_in"],
            data[i]["payment_date"],
            data[i]["mode"],
            data[i]["reference"] ?? "N/A",
            data[i]["doc"] != null
                ? ClickableText(
                    text: "Document",
                    onPressed: () => launchUrl(Uri.parse(data[i]["doc"])),
                  )
                : "N/A",
            ...(((entry.key == "submittedExpenses") && (role == "Admin"))
                ? List.generate(2, (index) {
                    TextEditingController controller = TextEditingController();
                    return Column(
                      children: [
                        SizedBox(
                          width: 150,
                          child: CustomTextField(
                            controller: controller,
                            hintText: "Enter Remarks",
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        CustomButton(
                          text: index == 0 ? "APPROVE" : "REJECT",
                          onPressed: () async {
                            var isLoading = true;
                            showDialog(
                              context: context,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                            try {
                              var result = await ((index == 0)
                                  ? Apis().approvePayment(
                                      username,
                                      role,
                                      data[i]["srno"],
                                    )
                                  : Apis().rejectPayment(
                                      username,
                                      role,
                                      data[i]["srno"],
                                    ));
                              if (result) {
                                if (context.mounted) {
                                  if (isLoading) Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Payment ${index == 0 ? "approved" : "rejected"} successfully')),
                                  );
                                }
                              }
                            } catch (error) {
                              if (isLoading) Navigator.pop(context);
                              log(error.toString());
                            }
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    );
                  })
                : []),
          ]);
        }
      }
      return result;
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  Future<bool> createPayment(
    String username,
    String role,
    String bookingId,
    String paymentDate,
    String amount,
    String reference,
    String paymentMode,
    String paymentDocLink,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/payments.php');
      final response = await http.post(
        url,
        body: {
          'login_type': getRole(role),
          'id': username,
          'mode': 'create',
          'booking_id': bookingId,
          'payment_date': paymentDate,
          'amount': amount,
          'reference': reference,
          'payment_mode': paymentMode,
          'payment_doc': paymentDocLink,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          log(responseData.toString());
          return true;
        } else {
          throw responseData['message'];
        }
      } else {
        throw 'Something went wrong';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> approvePayment(String username, String role, String srno) async {
    try {
      final url = Uri.parse('$baseUrl/payments.php');
      final response = await http.post(
        url,
        body: {
          'login_type': getRole(role),
          'id': username,
          'mode': 'approve',
          'srno': srno,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          log(responseData.toString());
          return true;
        } else {
          throw responseData['message'];
        }
      } else {
        throw 'Something went wrong';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> rejectPayment(String username, String role, String srno) async {
    try {
      final url = Uri.parse('$baseUrl/payments.php');
      final response = await http.post(
        url,
        body: {
          'login_type': getRole(role),
          'id': username,
          'mode': 'reject',
          'srno': srno,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          log(responseData.toString());
          return true;
        } else {
          throw responseData['message'];
        }
      } else {
        throw 'Something went wrong';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<List<dynamic>>> getDebitsData(
      BuildContext context, String role, String username) async {
    try {
      final query =
          "SELECT * FROM payments WHERE id = '$username' && ref = 'Debit' ORDER BY srno DESC";
      var data = await _fetchData(query);
      var headerList = [
        "#",
        "Uploaded On",
        "Booking ID",
        "Amount",
        "Date",
        "Mode",
        "Reference",
        "Documents"
      ];
      List<List<dynamic>> result = [headerList];
      var bookingId = await _fetchData("SELECT srno, booking_id FROM bookings");
      for (var i = 0; i < data.length; i++) {
        result.add([
          data[i]["srno"],
          data[i]["createdon"],
          bookingId.firstWhere(
              (element) => element["srno"] == data[i]["ref_id"])["booking_id"],
          data[i]["value_out"],
          data[i]["payment_date"],
          data[i]["mode"],
          data[i]["reference"] ?? "N/A",
          data[i]["doc"] != null
              ? ClickableText(
                  text: "Document",
                  onPressed: () => launchUrl(Uri.parse(data[i]["doc"])),
                )
              : "No Doc",
        ]);
      }
      return result;
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  Future<bool> createDebit(
    String username,
    String role,
    String bookingId,
    String paymentDate,
    String amount,
    String reference,
    String paymentMode,
    String paymentDocLink,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/debits.php');
      final response = await http.post(
        url,
        body: {
          'login_type': getRole(role),
          'id': username,
          'booking_id': bookingId,
          'payment_date': paymentDate,
          'amount': amount,
          'reference': reference,
          'payment_mode': paymentMode,
          'payment_doc': paymentDocLink,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          log(responseData.toString());
          return true;
        } else {
          throw responseData['message'];
        }
      } else {
        throw 'Something went wrong';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, List<List<dynamic>>>> getExpensesData(
      BuildContext context, String role, String username) async {
    try {
      final queries = {
        "submittedExpenses":
            "SELECT * FROM expenses WHERE ${role == "Admin" ? "status IS NULL " : "user_id = '$username' "}ORDER BY srno DESC",
        ...role == "Admin"
            ? {
                "approvedExpenses":
                    "SELECT * FROM expenses WHERE status = 'approved' ORDER BY srno DESC"
              }
            : {},
        ...role == "Admin"
            ? {
                "rejectedExpenses":
                    "SELECT * FROM expenses WHERE status = 'rejected' ORDER BY srno DESC"
              }
            : {},
      };
      var headerList = ["Title", "Amount", "Details", "Receipt"];
      Map<String, List<List<dynamic>>> result = {
        "submittedExpenses": [
          [...headerList, "", ""]
        ],
        ...role == "Admin"
            ? {
                "approvedExpenses": [
                  [...headerList, "Remarks"]
                ]
              }
            : {},
        ...role == "Admin"
            ? {
                "rejectedExpenses": [
                  [...headerList, "Remarks"]
                ]
              }
            : {},
      };
      for (var entry in queries.entries) {
        var data = await _fetchData(entry.value);
        for (var i = 0; i < data.length; i++) {
          result[entry.key]!.add([
            data[i]["title"],
            data[i]["amount"],
            data[i]["details"],
            data[i]["doc"] != null
                ? ClickableText(
                    text: "Document",
                    onPressed: () => launchUrl(Uri.parse(data[i]["doc"])),
                  )
                : "No Receipt",
            ...(((entry.key == "submittedExpenses") && (role == "Admin"))
                ? List.generate(2, (index) {
                    TextEditingController controller = TextEditingController();
                    return Column(
                      children: [
                        SizedBox(
                          width: 150,
                          child: CustomTextField(
                            controller: controller,
                            hintText: "Enter Remarks",
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        CustomButton(
                          text: index == 0 ? "APPROVE" : "REJECT",
                          onPressed: () async {
                            var isLoading = true;
                            showDialog(
                              context: context,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                            try {
                              var result = await ((index == 0)
                                  ? Apis().approveExpense(
                                      username,
                                      role,
                                      data[i]["srno"],
                                      controller.text,
                                    )
                                  : Apis().rejectExpense(
                                      username,
                                      role,
                                      data[i]["srno"],
                                      controller.text,
                                    ));
                              if (result) {
                                if (context.mounted) {
                                  if (isLoading) Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Expense ${index == 0 ? "approved" : "rejected"} successfully')),
                                  );
                                }
                              }
                            } catch (error) {
                              if (isLoading) Navigator.pop(context);
                              log(error.toString());
                            }
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    );
                  })
                : [data[i]["remarks"]]),
          ]);
        }
      }
      return result;
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  Future<bool> createExpense(String username, String role, String title,
      String amount, String details, String expenseDocLink) async {
    try {
      final url = Uri.parse('$baseUrl/expenses.php');
      final response = await http.post(
        url,
        body: {
          'login_type': getRole(role),
          'id': username,
          'mode': 'create',
          'title': title,
          'amount': amount,
          'details': details,
          'expense_doc': expenseDocLink,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          log(responseData.toString());
          return true;
        } else {
          throw responseData['message'];
        }
      } else {
        throw 'Something went wrong';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> approveExpense(
      String username, String role, String srno, String remarks) async {
    try {
      final url = Uri.parse('$baseUrl/expenses.php');
      final response = await http.post(
        url,
        body: {
          'login_type': getRole(role),
          'id': username,
          'mode': 'approve',
          'srno': srno,
          'remarks': remarks,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          log(responseData.toString());
          return true;
        } else {
          throw responseData['message'];
        }
      } else {
        throw 'Something went wrong';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> rejectExpense(
      String username, String role, String srno, String remarks) async {
    try {
      final url = Uri.parse('$baseUrl/expenses.php');
      final response = await http.post(
        url,
        body: {
          'login_type': getRole(role),
          'id': username,
          'mode': 'reject',
          'srno': srno,
          'remarks': remarks,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          log(responseData.toString());
          return true;
        } else {
          throw responseData['message'];
        }
      } else {
        throw 'Something went wrong';
      }
    } catch (e) {
      rethrow;
    }
  }
}
