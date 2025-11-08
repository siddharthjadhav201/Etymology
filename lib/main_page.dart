import 'package:etymology/navbar.dart';
import 'package:etymology/homepage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    //double height = MediaQuery.of(context).size.height;
    print(MediaQuery.of(context).size.width);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomNavbar(),

            // Hero Section
            Container(
              padding: EdgeInsets.symmetric(horizontal: width * 0.0326),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      margin: EdgeInsets.only(
                          right: width * 0.013, left: width * 0.052),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Make scientific Learning Simpler \nwith Word Origins",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: width * 0.042,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: width * 0.013),
                          Text(
                            "Paste or type your notes and get instant \netymological enrichment",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              fontSize: width * 0.017,
                            ),
                          ),
                          SizedBox(height: width * 0.0195),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NotesEditor(),
                                    ),
                                  );
                                },
                                child: MouseRegion(
                                  onEnter: (_) =>
                                      setState(() => isHovered = true),
                                  onExit: (_) =>
                                      setState(() => isHovered = false),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    transform: Matrix4.translationValues(
                                        0, isHovered ? -3 : 0, 0),
                                    child: Container( 
                                      padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.0156,
                                          vertical: width * 0.0078),
                                      decoration: BoxDecoration(
                                        boxShadow: isHovered
                                            ? [
                                                BoxShadow(
                                                  color: Colors.blueAccent
                                                      .withValues(alpha: 0.6),
                                                  blurRadius: 20,
                                                  spreadRadius: 2,
                                                ),
                                              ]
                                            : [],
                                        color: isHovered? Color.fromARGB(255, 47, 115, 154) : Color(0xFF1E3A8A),
                                        borderRadius: BorderRadius.circular(
                                            width * 0.0052),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.add,
                                              color: Colors.white,
                                              size: width * 0.013),
                                          SizedBox(width: width * 0.0052),
                                          Text(
                                            "Create New Note",
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: width * 0.0104,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: width * 0.0104),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.0156,
                                    vertical: width * 0.0078),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFD700),
                                  borderRadius:
                                      BorderRadius.circular(width * 0.0052),
                                ),
                                child: Text(
                                  "Explore Sample Note",
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: width * 0.0104,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(
                      height: width * 0.4,
                      child: Image.asset(
                        "assets/Illustratrion-1.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                ],
              ),
            ),

            SizedBox(height: width * 0.052),

            // Features Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  vertical: width * 0.039, horizontal: width * 0.0326),
              decoration: BoxDecoration(
                color: Color(0xFFF3F4F6),
                image: DecorationImage(
                  image: AssetImage(
                      "assets/grid_pattern.png"), // You'll need to add this
                  repeat: ImageRepeat.repeat,
                  opacity: 0.1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFeatureCard(
                      "Highlighted \nTerms",
                      width * 0.0293,
                      Image.asset("assets/award.png"),
                      Colors.black,
                      Color(0x509B9BFF),
                      width),
                  _buildFeatureCard(
                      "Etymology \nAnnotations",
                      width * 0.0293,
                      Image.asset("assets/Icon_annotion.png"),
                      Colors.white,
                      Color(0xFF363BBA),
                      width),
                  _buildFeatureCard(
                      "Editable Note Interface",
                      width * 0.0293,
                      Image.asset("assets/award.png"),
                      Colors.black,
                      Color(0x509B9BFF),
                      width),
                  _buildFeatureCard(
                      "Export Notes",
                      width * 0.0228,
                      Image.asset("assets/Vector_download.png"),
                      Colors.white,
                      Color(0xFF363BBA),
                      width),
                ],
              ),
            ),

            SizedBox(height: width * 0.052),

            // Interactive Example Section
            Container(
              padding: EdgeInsets.symmetric(horizontal: width * 0.0456),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: width * 0.0163,
                        ),
                        Text(
                          "Paste or type\nyour notes",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: width * 0.042,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: width * 0.0065),
                        Text(
                          "and get instant \netymological \nenrichment",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                            fontSize: width * 0.026,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        Container(
                          height: width * 0.20,
                          width: width * 0.63,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(width * 0.0078),
                            child: Image.asset(
                              "assets/Illustratrion-2.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(height: width * 0.013),
                        Text(
                          "Highlight the word to see meanings in the footer",
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: width * 0.0182,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            SizedBox(height: width * 0.052),

            // How It Works Section
            Container(
              color: Color(0xFFFCFCFE),
              padding: EdgeInsets.symmetric(horizontal: width * 0.0326),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "How It Works",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: width * 0.0313,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(height: width * 0.026),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStepCard(
                          "1", "Paste or type \nyour study \nmaterial", width),
                      _buildStepCard(
                          "2", "Select the \nscientific terms", width),
                      _buildStepCard(
                          "3", "Click on the \n'Annotate' button.", width),
                      _buildStepCard(
                          "4", "Export/share \nenriched notes", width),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: width * 0.052),

            // Etymology Learning Section
            Container(
              padding: EdgeInsets.symmetric(horizontal: width * 0.0326),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: width * 0.0326,
                        ),
                        Text(
                          "How Etymology \nEnhances Your Learning?",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: width * 0.0313,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: width * 0.0065),
                        Text(
                          "Discover the meaning behind scientific language",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontSize: width * 0.014,
                          ),
                        ),
                        SizedBox(
                          height: width * 0.0846,
                        ),
                        //Spacer(),
                        Text(
                          "EtymoNotes is an intelligent platform that helps you \nunderstand complex scientific terms through their",
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: width * 0.0156,
                            // height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(
                      width: width * 0.3288,
                      height: width * 0.263,
                      margin: EdgeInsets.only(right: width * 0.0456),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(width * 0.0078),
                        child: Image.asset(
                          "assets/Illustratrion-3.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding:
                  EdgeInsets.only(left: width * 0.0326, right: width * 0.0911),
              child: Text(
                "origins. By revealing the roots, prefixes, and historical meanings of words, directly within your notes. It transforms difficult terminology into clear, memorable concepts.",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: width * 0.0156,
                  // height: 1.5,
                ),
              ),
            ),
            SizedBox(height: width * 0.0651),
            // Who is EtymoNotes for? Section
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: width * 0.0326, vertical: width * 0.052),
              child: Column(
                children: [
                  Text(
                    "Who is EtymoNotes for?",
                    style: GoogleFonts.poppins(
                      fontSize: width * 0.0156,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: width * 0.013),
                  Container(
                    // padding: EdgeInsets.all(20),
                    // decoration: BoxDecoration(
                    //   border: Border.all(
                    //     color: Color(0xFF87CEEB),
                    //     style: BorderStyle.solid,
                    //     width: 2,
                    //   ),
                    //   borderRadius: BorderRadius.circular(12),
                    // ),
                    child: Text(
                      "Making science simpler for \nevery curious mind",
                      style: GoogleFonts.poppins(
                        fontSize: width * 0.0313,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: width * 0.013),
                  Container(
                    width: width * 0.6,
                    child: Text(
                      "EtymoNotes is designed for anyone who wants to understand the &apos;why&apos; behind scientific terms, bridging the gap between language and learning. Whether you&apos;re studying, teaching, or researching, EtymoNotes makes complex concepts easier to grasp by revealing the story behind every word.",
                      style: GoogleFonts.poppins(
                        fontSize: width * 0.0117,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: width * 0.039),
                  // Four Categories Grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCategoryCard(
                          "Students",
                          "Build stronger understanding of scientific terms through clear, word-by-word meaning. Improve memory retention and exam readiness with context-based learning",
                          Image.asset("assets/student.png"),
                          width * 0.0911,
                          width),
                      _buildCategoryCard(
                          "Teachers & Educators",
                          "Enhance classroom learning with annotated notes and word origin explanations. Simplify complex topics using etymological insights.",
                          Image.asset("assets/teacher.png"),
                          width * 0.0911,
                          width),
                      _buildCategoryCard(
                          "Researchers & Professionals",
                          "Trace the historical and linguistic roots of scientific terminology to strengthen writing, research, and subject clarity.",
                          Image.asset("assets/profes.png"),
                          width * 0.0911,
                          width),
                      _buildCategoryCard(
                          "Lifelong Learners",
                          "For anyone passionate about science, language, and knowledge - uncover the fascinating origins of the words you use every day.",
                          Image.asset("assets/globe.png"),
                          width * 0.0911,
                          width),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.white,
              // padding: EdgeInsets.symmetric(vertical: 40, horizontal: 50),
              child: Column(
                children: [
                  // Container(
                  //   width: width * 0.7,
                  //   child: Text(
                  //     "This is a PoC version. Features like subscriptions, login system, full admin access, and real-time deployment will be added in future releases.",
                  //     style: GoogleFonts.poppins(
                  //       fontSize: 14,
                  //       color: Colors.grey[600],
                  //       height: 1.4,
                  //     ),
                  //     textAlign: TextAlign.center,
                  //   ),
                  // ),
                  SizedBox(height: width * 0.013),
                  Container(
                    width: double.infinity,
                    height: width * 0.0326,
                    color: Color(0xFF1E3A8A),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: width * 0.013),
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              "Terms & Conditions",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: width * 0.0091,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: width * 0.013),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: width * 0.013),
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              "Privacy",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: width * 0.0091,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, double w, Image icon, Color textc,
      Color color, double width) {
    return Container(
      padding: EdgeInsets.all(width * 0.013),
      height: width * 0.0977,
      width: width * 0.2083,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(width * 0.0078),
      ),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(right: width * 0.0098),
            width: w,
            height: w,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(width * 0.0052),
              child: FittedBox(
                fit: BoxFit.contain,
                child: icon,
              ),
            ),
          ),
          SizedBox(width: width * 0.0078),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: textc,
                fontWeight: FontWeight.w400,
                fontSize: width * 0.0156,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(String number, String text, double width) {
    return Container(
      width: width * 0.2148,
      height: width * 0.0651,
      padding: EdgeInsets.all(width * 0.013),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            width: width * 0.0326,
            height: width * 0.0326,
            decoration: BoxDecoration(
              color: Color(0xFF8DB4DD),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.0156,
                ),
              ),
            ),
          ),
          SizedBox(width: width * 0.0104),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: width * 0.0156,
              height: 1.3,
            ),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
      String title, String description, Image icon, double w, double width) {
    return Container(
      width: width * 0.2188,
      padding: EdgeInsets.all(width * 0.013),
      decoration: BoxDecoration(
        color: Color(0xFFFAFCFF),
        borderRadius: BorderRadius.circular(width * 0.0078),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(right: width * 0.0098),
            width: w,
            height: w,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(width * 0.0052),
              child: FittedBox(
                fit: BoxFit.contain,
                child: icon,
              ),
            ),
          ),
          SizedBox(height: width * 0.0098),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: width * 0.0234,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: width * 0.026),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: width * 0.0156,
              color: Colors.black87,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
