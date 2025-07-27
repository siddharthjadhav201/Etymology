import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomNavbar extends StatelessWidget {
  const CustomNavbar({super.key});
  

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    bool isMobile = width < 600;
    Widget _navItem(String title) {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: width*0.0084),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w400,
          fontSize: width*0.0152
        ),
      ),
    );
  }
    return Container(
      height: isMobile ? 50 : width*0.048,
      padding:  EdgeInsets.symmetric(horizontal: width*0.0166),
      color: const Color(0xFF363BBA), // Blue navbar background
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          
          Row(
            children: [
              Image.asset(
                "assets/Logo.png",
                height: width*0.031,
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
              SizedBox(width: width*0.0084),
              Text(
                String.fromCharCode(Icons.account_circle_outlined.codePoint),
                style: TextStyle(
                  fontFamily: Icons.account_circle_outlined.fontFamily,
                  package: Icons.account_circle.fontPackage,
                  fontSize: width*0.0194,
                  fontWeight: FontWeight.w300, 
                  color: Colors.white,
                ),
              ),
              SizedBox(width: width*0.0028),
              Text(
                "Guest",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: width*0.0152
                ),
              ),
              SizedBox(
                width: width*0.0208,
              )
            ],
          ),
        ],
      ),
    );
  }

  
}
