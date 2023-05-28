import 'dart:developer';

import 'package:bluehorsebuild/components/custom_textfield.dart';
import 'package:bluehorsebuild/screens/admins_screen.dart';
import 'package:bluehorsebuild/screens/auth_screen.dart';
import 'package:bluehorsebuild/screens/bookings_screen.dart';
import 'package:bluehorsebuild/screens/change_password_screen.dart';
import 'package:bluehorsebuild/screens/dashboard_screen.dart';
import 'package:bluehorsebuild/screens/debits_screen.dart';
import 'package:bluehorsebuild/screens/expenses_screen.dart';
import 'package:bluehorsebuild/screens/payments_screen.dart';
import 'package:bluehorsebuild/screens/projects_screen.dart';
import 'package:bluehorsebuild/screens/users_screen.dart';
import 'package:bluehorsebuild/services/shared_preferences_helper.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.role, required this.username});

  static const String id = "MainScreen";

  final String role;
  final String username;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late List<OptionTile> options;
  late int selectedIndex;
  late Widget openedScreen;
  late String openedScreenTitle;

  @override
  void initState() {
    super.initState();
    List<OptionTile> adminOptions = [
      OptionTile(
        optionTitle: "Dashboard",
        screenTitle: "Dashboard",
        icon: Icons.dashboard,
        screen: DashboardScreen(
          role: widget.role,
          username: widget.username,
        ),
      ),
      OptionTile(
        optionTitle: "Projects",
        screenTitle: "Projects",
        icon: Icons.apartment,
        screen: ProjectsScreen(
          role: widget.role,
          username: widget.username,
        ),
      ),
      OptionTile(
        optionTitle: "Admins",
        screenTitle: "Administrators",
        icon: Icons.people,
        screen: AdminsScreen(
          role: widget.role,
          username: widget.username,
        ),
      ),
      OptionTile(
        optionTitle: "Users",
        screenTitle: "User Management",
        icon: Icons.people,
        screen: UsersScreen(
          role: widget.role,
          username: widget.username,
        ),
      ),
      OptionTile(
        optionTitle: "Bookings",
        screenTitle: "Bookings",
        icon: Icons.library_books,
        screen: BookingsScreen(
          role: widget.role,
          username: widget.username,
        ),
      ),
      OptionTile(
        optionTitle: "Payments",
        screenTitle: "Payments",
        icon: Icons.payment,
        screen: PaymentsScreen(
          role: widget.role,
          username: widget.username,
        ),
      ),
      OptionTile(
        optionTitle: "Debits",
        screenTitle: "Debits",
        icon: Icons.payment,
        screen: DebitsScreen(
          role: widget.role,
          username: widget.username,
        ),
      ),
      OptionTile(
        optionTitle: "Expenses",
        screenTitle: "Expenses",
        icon: Icons.receipt,
        screen: ExpensesScreen(
          role: widget.role,
          username: widget.username,
        ),
      ),
    ];
    List<OptionTile> userOptions = [
      OptionTile(
        optionTitle: "Dashboard",
        screenTitle: "Dashboard",
        icon: Icons.dashboard,
        screen: DashboardScreen(
          role: widget.role,
          username: widget.username,
        ),
      ),
      OptionTile(
        optionTitle: "Bookings",
        screenTitle: "Bookings",
        icon: Icons.library_books,
        screen: BookingsScreen(
          role: widget.role,
          username: widget.username,
        ),
      ),
      OptionTile(
        optionTitle: "Payments",
        screenTitle: "Payments",
        icon: Icons.payment,
        screen: PaymentsScreen(
          role: widget.role,
          username: widget.username,
        ),
      ),
      OptionTile(
        optionTitle: "Expenses",
        screenTitle: "Expenses",
        icon: Icons.receipt,
        screen: ExpensesScreen(
          role: widget.role,
          username: widget.username,
        ),
      ),
    ];
    if (widget.role == "Admin") {
      options = adminOptions;
    } else {
      options = userOptions;
    }
    changeScreen(0, options[0].screen, options[0].screenTitle);
  }

  void changeScreen(int index, Widget screen, String screenName) {
    selectedIndex = index;
    openedScreen = screen;
    openedScreenTitle = screenName;
    if (context.mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      body: Row(
        children: [
          Container(
            height: height,
            width: 275,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage("assets/images/sidebar_image.jpg"),
                fit: BoxFit.cover,
              ),
              boxShadow: kElevationToShadow[24],
            ),
            child: Container(
              color: const Color(0xFAEFEFEF),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          changeScreen(
                              0, options[0].screen, options[0].screenTitle);
                        },
                        child: Text(
                          "BLUE HORSE BUILDERS",
                          style: GoogleFonts.urbanist(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: InkWell(
                          onTap: () {
                            changeScreen(
                                0, options[0].screen, options[0].screenTitle);
                          },
                          child: Text(
                            widget.role == "Admin" ? "ADMIN" : "STAFF",
                            style: GoogleFonts.urbanist(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const Divider(
                        height: 50,
                        color: Colors.grey,
                        thickness: 0.5,
                      ),
                    ],
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) => Card(
                      color: (index != 0 && index == selectedIndex)
                          ? Colors.purple
                          : Colors.transparent,
                      elevation:
                          (index != 0 && index == selectedIndex) ? 10 : 0,
                      margin: const EdgeInsets.symmetric(vertical: 5.0),
                      child: ListTile(
                        leading: Icon(
                          options[index].icon,
                          color: (index != 0 && index == selectedIndex)
                              ? Colors.white
                              : Colors.grey,
                        ),
                        title: Text(
                          options[index].optionTitle,
                          style: GoogleFonts.urbanist(
                            color: (index != 0 && index == selectedIndex)
                                ? Colors.white
                                : Colors.black54,
                          ),
                        ),
                        onTap: () {
                          changeScreen(index, options[index].screen,
                              options[index].screenTitle);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
              children: [
                HeaderRow(
                  screenName: openedScreenTitle,
                  changeScreenCallback: changeScreen,
                  username: widget.username,
                  role: widget.role,
                ),
                const SizedBox(
                  height: 50,
                ),
                openedScreen,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderRow extends StatelessWidget {
  const HeaderRow({
    super.key,
    required this.screenName,
    required this.changeScreenCallback,
    required this.username,
    required this.role,
  });
  final String screenName;
  final Function(int, Widget, String) changeScreenCallback;
  final String username;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          screenName,
          style: GoogleFonts.urbanist(
            color: Colors.black54,
            fontStyle: FontStyle.italic,
            fontSize: 20,
          ),
        ),
        const Spacer(),
        const SizedBox(
          width: 150,
          child: CustomTextField(
            showLabel: false,
            hintText: "Search...",
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () {},
          child: const Card(
            shape: CircleBorder(),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.search,
                color: Colors.grey,
                size: 22,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 15.0,
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            customButton: const Icon(
              Icons.person,
              color: Colors.black87,
              size: 22,
            ),
            dropdownStyleData: DropdownStyleData(
              width: 160,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              elevation: 8,
              offset: const Offset(-125, -10),
            ),
            items: [
              DropdownMenuItem(
                value: "Password",
                child: Text(
                  "Password",
                  style: GoogleFonts.urbanist(
                    fontSize: 13,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: "Log out",
                child: Text(
                  "Log out",
                  style: GoogleFonts.urbanist(
                    fontSize: 13,
                  ),
                ),
              ),
            ],
            onChanged: (String? newValue) {
              if (newValue == 'Password') {
                changeScreenCallback(
                    -1,
                    ChangePasswordScreen(username: username, role: role),
                    "Change Password");
              } else if (newValue == 'Log out') {
                log("Logged out");
                SharedPreferencesHelper.setUsername('');
                SharedPreferencesHelper.setRole('');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out')),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AuthScreen(),
                  ),
                );
              }
            },
          ),
        ),
        const SizedBox(
          width: 10.0,
        ),
      ],
    );
  }
}

class OptionTile {
  OptionTile({
    required this.optionTitle,
    required this.icon,
    required this.screen,
    required this.screenTitle,
  });

  final String optionTitle;
  final String screenTitle;
  final IconData icon;
  final Widget screen;
}
