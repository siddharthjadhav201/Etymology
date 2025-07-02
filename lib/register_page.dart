import 'dart:developer';

import 'package:etymology/login_page.dart';
import 'package:etymology/providers.dart';
import 'package:etymology/services/remote_services.dart';
import 'package:etymology/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? selectedRole;
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailNameController = TextEditingController();
  bool isOpen = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 500,
                height: 550,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                  color: const Color.fromRGBO(255, 255, 255, 1),
                ),
                child: ListView(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin: const EdgeInsets.all(20),
                          child: TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: "Name",
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    bottomRight:
                                        Radius.circular(25)), // Green border
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.green, width: 2.0),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    bottomRight: Radius.circular(
                                        25)), // Border when focused
                              ),
                              errorBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red, width: 1.0),
                              ),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    bottomRight: Radius.circular(25)),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(20),
                          child: TextField(
                            controller: emailNameController,
                            decoration: InputDecoration(
                              labelText: "Email",
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    bottomRight:
                                        Radius.circular(25)), // Green border
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.green, width: 2.0),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    bottomRight: Radius.circular(
                                        25)), // Border when focused
                              ),
                              errorBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red, width: 1.0),
                              ),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    bottomRight: Radius.circular(25)),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Select your Role",
                                style: TextStyle(fontSize: 16),
                              ),
                              DropdownButton<String>(
                                value: selectedRole,
                                hint: const Text("Choose Role"),
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 16),
                                dropdownColor:
                                    const Color.fromARGB(255, 255, 137, 68),
                                borderRadius: BorderRadius.circular(10),
                                items: const [
                                  DropdownMenuItem<String>(
                                    value: 'admin',
                                    child: Text('Admin'),
                                  ),
                                  DropdownMenuItem<String>(
                                    value: 'student',
                                    child: Text('Student'),
                                  ),
                                  DropdownMenuItem<String>(
                                    value: 'teacher',
                                    child: Text('Teacher'),
                                  ),
                                ],
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedRole = newValue!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(20),
                          child: TextField(
                            controller: userNameController,
                            decoration: InputDecoration(
                              labelText: "Username",
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    bottomRight:
                                        Radius.circular(25)), // Green border
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.green, width: 2.0),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    bottomRight: Radius.circular(
                                        25)), // Border when focused
                              ),
                              errorBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red, width: 1.0),
                              ),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    bottomRight: Radius.circular(25)),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(20),
                          child: TextField(
                            controller: passwordController,
                            obscureText: isOpen ? true : false,
                            decoration: InputDecoration(
                              hintText: "12345",
                              labelText: "password",
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(12),
                                child: SvgPicture.asset(
                                  "assets/Svg/password.svg",
                                  height: 5,
                                  width: 5,
                                ),
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  if (isOpen) {
                                    isOpen = false;
                                  } else {
                                    isOpen = true;
                                  }
                                  setState(() {});
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(8),
                                  child: SvgPicture.asset(
                                    isOpen
                                        ? "assets/Svg/hidden.svg"
                                        : "assets/Svg/notHidden.svg",
                                    height: 5,
                                    width: 5,
                                  ),
                                ),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    bottomRight: Radius.circular(25)),
                                borderSide: BorderSide(
                                    color: Colors.green), // Green border
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    bottomRight: Radius.circular(25)),
                                borderSide: BorderSide(
                                    color: Colors.green, // Green border
                                    width: 2.0), // Border when focused
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (nameController.text.isEmpty ||
                                emailNameController.text.isEmpty ||
                                userNameController.text.isEmpty ||
                                passwordController.text.isEmpty ||
                                passwordController.text.length < 4 ||
                                selectedRole == null) {
                              log("enter valid information");
                              showCenterPopup(
                                  context, "⚠️ Please Enter Valid Information");
                            } else {
                              int response = await registerUser(
                                  nameController.text,
                                  emailNameController.text,
                                  userNameController.text,
                                  selectedRole!,
                                  passwordController.text);
                              if (response == -1) {
                                showCenterPopup(context, "⚠️ Network Error");
                              } else if (response == -1) {
                                showCenterPopup(
                                    context, "⚠️ Username Already Taken");
                              } else {
                                context.read<LoginProvider>()
                                    .setUsername(userNameController.text);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => NotesEditor()));
                              }
                            }
                          },
                          child: Container(
                            height: 40,
                            width: 300,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.green,
                            ),
                            child: const Text(
                              "Register",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 20),
                            child: const Text(
                              "Already Login ? Login",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
