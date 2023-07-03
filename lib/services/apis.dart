import 'dart:convert';
import 'dart:developer';
import 'package:bluehorsebuild/components/clickable_text.dart';
import 'package:bluehorsebuild/components/custom_button.dart';
import 'package:bluehorsebuild/components/custom_textfield.dart';
import 'package:bluehorsebuild/screens/ledger_screen.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
        Fluttertoast.showToast(
          msg: 'Something went wrong',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return false;
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
        Fluttertoast.showToast(
          msg: 'Something went wrong',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return false;
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
        Fluttertoast.showToast(
          msg: 'Something went wrong',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return "";
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
        Fluttertoast.showToast(
          msg: 'Something went wrong',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
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
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return [];
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
                  Fluttertoast.showToast(
                    msg: 'Project deleted successfully',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              } catch (error) {
                log(error.toString());
                Fluttertoast.showToast(
                  msg: 'Something went wrong',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              } finally {
                if (context.mounted && isLoading) {
                  Navigator.pop(context);
                }
              }
            },
          ),
        ]);
      }
      return result;
    } catch (error) {
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return [];
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
        Fluttertoast.showToast(
          msg: 'Something went wrong',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return false;
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
        Fluttertoast.showToast(
          msg: 'Something went wrong',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return false;
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
                  Fluttertoast.showToast(
                    msg: 'Admin blocked successfully',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              } catch (error) {
                log(error.toString());
                Fluttertoast.showToast(
                  msg: 'Something went wrong',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              }
              if (context.mounted && isLoading) {
                Navigator.pop(context);
              }
            },
          ),
        ]);
      }
      return result;
    } catch (error) {
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return [];
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
        Fluttertoast.showToast(
          msg: 'Something went wrong',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return false;
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
        Fluttertoast.showToast(
          msg: 'Something went wrong',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return false;
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
                  Fluttertoast.showToast(
                    msg: 'User blocked successfully',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              } catch (error) {
                log(error.toString());
                Fluttertoast.showToast(
                  msg: 'Something went wrong',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              } finally {
                if (context.mounted && isLoading) {
                  Navigator.pop(context);
                }
              }
            },
          ),
        ]);
      }
      return result;
    } catch (error) {
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return [];
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
        Fluttertoast.showToast(
          msg: 'Something went wrong',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return false;
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
        Fluttertoast.showToast(
          msg: 'Something went wrong',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return false;
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
    } catch (error) {
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return [];
  }

  Future<bool> updateLedger(String userid, String srno) async {
    try {
      final url = Uri.parse('$baseUrl/updateLedger.php');
      final response = await http.post(
        url,
        body: {
          'userid': userid.toString(),
          'srno': srno.toString(),
        },
      );
      log(response.body.toString());

      if (response.statusCode == 200) {
        log("Ledger Updated");

        return true;
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to update ledger',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Failed to update ledger',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return false;
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
          "Partner Name",
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
          data[i]["srno"],
          CustomButton(
            text: "LEDGER",
            color: Colors.blue,
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LedgerScreen(
                    ledgerData: {...data[i], "approved_by": approvedBy},
                    role: role,
                    username: username,
                  ),
                )),
          ),
          (data[i]['status'] == null
              ? Text(
                  "Active",
                  style: GoogleFonts.urbanist(),
                )
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
                        Fluttertoast.showToast(
                          msg: 'Booking inactivated successfully',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }
                    } catch (error) {
                      log(error.toString());
                      Fluttertoast.showToast(
                        msg: 'Something went wrong',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    } finally {
                      if (context.mounted && isLoading) {
                        Navigator.pop(context);
                      }
                    }
                  },
                )
              : null,
        ]);
      }
      return result;
    } catch (error) {
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return [];
  }

  Future<bool> editBooking(Map<String, String> editedRow) async {
    try {
      String query = "UPDATE bookings SET ";

      // TODO
      // if (editedRow["Approved By"] != null) {
      //   query += "Approved By = '${editedRow["Approved By"]}' ";
      // }
      if (editedRow["Booking ID"] != null) {
        query += "booking_id = '${editedRow["Booking ID"]}' ";
      }
      if (editedRow["Project Name"] != null) {
        query += "project_name = '${editedRow["Project Name"]}' ";
      }
      if (editedRow["Channel"] != null) {
        query += "channel_partner = '${editedRow["Channel"]}' ";
      }
      if (editedRow["Partner Name"] != null) {
        query += "name = '${editedRow["Partner Name"]}' ";
      }
      if (editedRow["PAN"] != null) {
        query += "pan = '${editedRow["PAN"]}' ";
      }
      if (editedRow["Mobile"] != null) {
        query += "mobile = '${editedRow["Mobile"]}' ";
      }
      if (editedRow["Email"] != null) {
        query += "email = '${editedRow["Email"]}' ";
      }
      if (editedRow["Address"] != null) {
        query += "address = '${editedRow["Address"]}' ";
      }
      if (editedRow["Co-Applicant"] != null) {
        query += "co_applicant = '${editedRow["Co-Applicant"]}' ";
      }
      if (editedRow["Nominee"] != null) {
        query += "nominee = '${editedRow["Nominee"]}' ";
      }
      if (editedRow["Relation"] != null) {
        query += "nominee_relation = '${editedRow["Relation"]}' ";
      }
      if (editedRow["Date"] != null) {
        query += "booking_date = '${editedRow["Date"]}' ";
      }
      if (editedRow["Plan"] != null) {
        query += "plan = '${editedRow["Plan"]}' ";
      }
      if (editedRow["Rate(per sqft)"] != null) {
        query += "booking_rate = '${editedRow["Rate(per sqft)"]}' ";
      }
      if (editedRow["Size( in sqft)"] != null) {
        query += "shop_size = '${editedRow["Size( in sqft)"]}' ";
      }
      if (editedRow["Floor No."] != null) {
        query += "floor_no = '${editedRow["Floor No."]}' ";
      }
      if (editedRow["Shop No."] != null) {
        query += "shop_no = '${editedRow["Shop No."]}' ";
      }
      if (editedRow["Car Parking"] != null) {
        query += "car_parking = '${editedRow["Car Parking"]}' ";
      }
      if (editedRow["Power Backup"] != null) {
        query += "power_backup = '${editedRow["Power Backup"]}' ";
      }
      if (editedRow["PLC (%)"] != null) {
        query += "plc = '${editedRow["PLC (%)"]}' ";
      }
      if (editedRow["IFMC (per sqft)"] != null) {
        query += "ifmc = '${editedRow["IFMC (per sqft)"]}' ";
      }
      if (editedRow["EEC (per sqft)"] != null) {
        query += "eec = '${editedRow["EEC (per sqft)"]}' ";
      }
      if (editedRow["FFC (per sqft)"] != null) {
        query += "ffc = '${editedRow["FFC (per sqft)"]}' ";
      }
      if (editedRow["ECC (per sqft)"] != null) {
        query += "ecc = '${editedRow["ECC (per sqft)"]}' ";
      }
      if (editedRow["GST (%)"] != null) {
        query += "gst = '${editedRow["GST (%)"]}' ";
      }
      query += "WHERE srno = '${editedRow["#"]}' ";

      final url = Uri.parse('$baseUrl/query.php');
      final response = await http.post(
        url,
        body: {
          'query': query,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (!responseData['message'].startsWith("Database error:")) {
          log(responseData.toString());
          return true;
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Something went wrong',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return false;
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

      // Check for empty fields
      final Map<String, String> requestBody = {
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
      };

      // Validate and log empty fields
      final List<String> emptyFields = [];
      requestBody.forEach((key, value) {
        if (value == null || value.isEmpty) {
          emptyFields.add(key);
        }
      });
      if (emptyFields.isNotEmpty) {
        // Log the empty fields
        debugPrint('Empty fields: $emptyFields');
        throw 'Empty fields found.';
      }

      final response = await http.post(
        url,
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          log(responseData.toString());
          return true;
        } else {
          Fluttertoast.showToast(
            msg: responseData['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          log(responseData['message'].toString());
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Something went wrong',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        log(response.toString());
      }
    } catch (error) {
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
    return false;
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
        Fluttertoast.showToast(
          msg: 'Something went wrong',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return false;
  }

  Future<Map> getLedgerData(String srno, String bookingInterest,
      double bookingAmount, double gst, String username) async {
    await updateLedger(username, srno);

    try {
      final query =
          "SELECT * FROM payments WHERE (ref_id = '$srno' && status = 'approved') ORDER BY payment_date";
      var data = await _fetchData(query);
      List<List<dynamic>> results = [];
      double balance = 0;
      double totalInterest = 0;
      double totalCredit = 0;
      int bookingIndex = -1;
      for (var i = 0; i < data.length; i++) {
        int diff = 0;
        double interest = 0;
        var previousBalance = balance;
        balance = balance +
            double.parse(data[i]["value_out"]) -
            double.parse(data[i]["value_in"]);
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
          // if (DateTime.now().isAfter(currentDateTime)) {
          DateTime date1 = previousDateTime;
          DateTime date2 = currentDateTime;
          diff = date2.difference(date1).inDays;
          interest = (previousBalance *
                  (double.parse(bookingInterest) / 100 / 365) *
                  diff)
              .roundToDouble();
        } else {
          diff = 0;
        }
        // } else {
        //   diff = 0;
        // }

        results.add([
          i + 1,
          DateFormat('dd-MM-yyyy')
              .format(DateTime.parse(data[i]["payment_date"])),
          data[i]["ref"],
          data[i]["value_out"] == "0"
              ? "-"
              : double.parse(data[i]["value_out"]) % 1 == 0
                  ? double.parse(data[i]["value_out"]).toInt().toString()
                  : double.parse(data[i]["value_out"]).toStringAsFixed(2),
          data[i]["value_in"] == "0"
              ? "-"
              : double.parse(data[i]["value_in"]) % 1 == 0
                  ? double.parse(data[i]["value_in"]).toInt().toString()
                  : double.parse(data[i]["value_in"]).toStringAsFixed(2),
          balance % 1 == 0
              ? balance.toInt().toString()
              : balance.toStringAsFixed(2),
          interest <= 0
              ? "($diff)" + "0"
              : "($diff)${interest % 1 == 0 ? interest.toInt().toString() : interest.toStringAsFixed(2)}",
        ]);

        totalInterest += interest;
        totalCredit += double.parse(data[i]["value_in"]);
        // Check if the current item's reference contains "at the time of booking"
        if (data[i]["ref"].toString().contains("At the time of booking")) {
          bookingIndex =
              i; // Store the index of the "at the time of booking" item
        }
      }
      if (bookingIndex != -1) {
        List<dynamic> bookingItem = results.removeAt(bookingIndex);

        results.insert(0, bookingItem);
        for (var i = 0; i < results.length; i++) {
          results[i][0] = i + 1;
        }
      }
      double balanceAtRegistration =
          (balance + totalInterest) >= (bookingAmount + totalInterest)
              ? ((balance + totalInterest)) +
                  (gst / 100 * (balance + totalInterest))
              : ((bookingAmount + totalInterest)) -
                  totalCredit +
                  (gst / 100 * (bookingAmount + totalInterest));
      return {
        "data": results,
        "totalInterest": totalInterest.toStringAsFixed(2).toString(),
        "totalOutstanding":
            (balance + totalInterest).toStringAsFixed(2).toString(),
        "balanceAtRegistration": balanceAtRegistration <= 0
            ? "0"
            : balanceAtRegistration.toStringAsFixed(2).toString(),
      };
    } catch (error) {
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return {};
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
            ...(((entry.key == "uploadedPayments") && (role == "Admin"))
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
                                Fluttertoast.showToast(
                                  msg:
                                      'Payment ${index == 0 ? "approved" : "rejected"} successfully',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                              }
                            } catch (error) {
                              log(error.toString());
                              Fluttertoast.showToast(
                                msg: 'Something went wrong',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            } finally {
                              if (context.mounted && isLoading) {
                                Navigator.pop(context);
                              }
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
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return {};
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
          Fluttertoast.showToast(
            msg: responseData['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } else {
        log(response.body.toString());
        Fluttertoast.showToast(
          msg: 'Something went wrong',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return false;
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
        Fluttertoast.showToast(
          msg: 'Something went wrong',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return false;
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
        Fluttertoast.showToast(
          msg: 'Something went wrong',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return false;
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
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return [];
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
          Fluttertoast.showToast(
            msg: responseData['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } else {
        log(response.body.toString());
        Fluttertoast.showToast(
          msg: 'Something went wrong',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return false;
  }

  Future<Map<String, List<List<dynamic>>>> getExpensesData(
      BuildContext context, String role, String username) async {
    log(username);
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
            ...((entry.key == "submittedExpenses") && (role == "Admin")
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
                                Fluttertoast.showToast(
                                  msg:
                                      'Expense ${index == 0 ? "approved" : "rejected"} successfully',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                              }
                            } catch (error) {
                              log(error.toString());
                              Fluttertoast.showToast(
                                msg: 'Something went wrong',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            } finally {
                              if (context.mounted && isLoading) {
                                Navigator.pop(context);
                              }
                            }
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    );
                  })
                : [
                    data[i]["remarks"] ?? "No remarks yet",
                    if (entry.key == "submittedExpenses") " "
                  ]),
          ]);
        }
      }

      return result;
    } catch (error) {
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return {};
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
        Fluttertoast.showToast(
          msg: 'Something went wrong',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return false;
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
        Fluttertoast.showToast(
          msg: 'Something went wrong',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return false;
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
        Fluttertoast.showToast(
          msg: 'Something went wrong',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      log(error.toString());
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return false;
  }
}
