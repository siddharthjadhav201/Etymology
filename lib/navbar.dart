import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
              Image.asset("assets/Logo.png",
              height: 40,)
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
              Icon(Icons.account_circle_outlined, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                "Guest",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 30,)
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
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
