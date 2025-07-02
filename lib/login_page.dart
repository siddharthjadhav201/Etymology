
import 'package:etymology/providers.dart';
import 'package:etymology/register_page.dart';
import 'package:etymology/services/remote_services.dart';
import 'package:etymology/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var isOpen = true;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.only(top:50),
                height: 400,
                width: 500,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: const BorderRadius.all( Radius.circular(25)),
                  color: const Color.fromRGBO(255, 255, 255, 1),
                ),
                child: ListView(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(20),
                          child: TextField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              hintText: "Enter your username",
                              labelText: "Username",
                              labelStyle: const TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
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
                            if(usernameController.text.isNotEmpty && passwordController.text.isNotEmpty){
                              int respose=await loginUser(usernameController.text,passwordController.text);
                              if(respose==0){
                                showCenterPopup(context, "⚠️ User Not Found");
                              }else if(respose==1){
                                showCenterPopup(context, "⚠️ Incorrect Password");
                              }else if(respose==2){
                               
                                 context.read<LoginProvider>().setUsername(usernameController.text);
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: 
                                (context)=>NotesEditor()));
                              }else{
                                showCenterPopup(context, "⚠️ Network Error");
                              }
                            }
                          },
                          child: Container(
                            height: 50,
                            width: 300,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color.fromARGB(255, 0, 166, 227),
                            ),
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 243, 240, 240),
                                  fontSize: 20),
                            ),
                          ),
                        ),
              
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder:(context)=> RegisterScreen()));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 20),
                            child: const Text(
                              "New User ? Register",
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
