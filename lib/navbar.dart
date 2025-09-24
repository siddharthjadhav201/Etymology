import 'package:etymology/human_in_loop.dart';
import 'package:etymology/login_page.dart';
import 'package:etymology/providers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomNavbar extends StatelessWidget {
  const CustomNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: const Color(0xFF363BBA), // Blue navbar background
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Title
          Row(
            children: [
              Image.asset(
                "assets/Logo.png",
                height: 40,
              )
            ],
          ),

          // Nav Items
          Row(
            children: [
              _navItem("About"),
              _navItem("Feedback"),
              _navItem("Contact"),
              _navItem("Help"),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final username = prefs.getString('username');
                  final loginTime = prefs.getInt('loginTime');

                  if (username != null && loginTime != null) {
                    final currentTime = DateTime.now().millisecondsSinceEpoch;
                    final oneHour = 30 * 60 * 1000;

                    if (currentTime - loginTime < oneHour) {
                      // ✅ Already logged in and valid session
                      context.read<LoginProvider>().setUsername(username);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MedicalTermsEtymoPage()),
                      );
                      return;
                    }
                  }

                  // ❌ Not logged in or session expired → go to Login
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.account_circle_outlined,
                        color: Colors.white, size: 30),
                    const SizedBox(width: 4),
                    Text(
                      "Admin",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 30,
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _navItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
