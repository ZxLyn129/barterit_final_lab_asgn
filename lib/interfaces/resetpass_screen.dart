import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../config_server.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _repassController = TextEditingController();

  late double screenHeight, screenWidth, cardwitdh;
  bool _passwordVisit = true;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 600) {
      cardwitdh = screenWidth;
    } else {
      cardwitdh = 600;
      screenHeight = 1080;
    }

    return WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Reset Password'),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                    height: screenHeight * 0.3,
                    width: screenWidth,
                    child: Image.asset(
                      "assets/images/reset.png",
                      fit: BoxFit.fill,
                    )),
                SizedBox(
                    width: cardwitdh,
                    child: Card(
                        color: const Color.fromARGB(255, 221, 243, 239),
                        elevation: 10,
                        margin: const EdgeInsets.all(15),
                        child: Container(
                            padding: const EdgeInsets.all(15),
                            child: Form(
                                key: _formKey,
                                child: Column(children: <Widget>[
                                  Text(
                                    "Reset Password",
                                    style: GoogleFonts.carterOne(
                                      textStyle: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (val) => val!.isEmpty ||
                                              !val.contains("@") ||
                                              !val.contains(".")
                                          ? "Enter a valid email"
                                          : null,
                                      decoration: const InputDecoration(
                                          labelText: 'Email',
                                          labelStyle: TextStyle(),
                                          icon: Icon(Icons.email),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 2.0,
                                                  color: Colors.blueGrey)))),
                                  TextFormField(
                                      controller: _passController,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      validator: (val) =>
                                          val!.isEmpty || (val.length < 8)
                                              ? "Password must be longer than 8"
                                              : null,
                                      obscureText: _passwordVisit,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        labelStyle: const TextStyle(),
                                        icon: const Icon(Icons.lock),
                                        focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 2.0,
                                                color: Colors.blueGrey)),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _passwordVisit
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _passwordVisit = !_passwordVisit;
                                            });
                                          },
                                        ),
                                      )),
                                  TextFormField(
                                      controller: _repassController,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      validator: (val) {
                                        if (val == "") {
                                          return 'Please do not make it empty';
                                        }
                                        if (val != _passController.text) {
                                          return 'Password do not match';
                                        }
                                        return null;
                                      },
                                      obscureText: _passwordVisit,
                                      decoration: InputDecoration(
                                        labelText: 'Confirm Password',
                                        labelStyle: const TextStyle(),
                                        icon: const Icon(Icons.lock),
                                        focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 2.0,
                                                color: Colors.blueGrey)),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _passwordVisit
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _passwordVisit = !_passwordVisit;
                                            });
                                          },
                                        ),
                                      )),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  MaterialButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0)),
                                    minWidth: 110,
                                    height: 50,
                                    elevation: 10,
                                    onPressed: _resetPasswordDialog,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    child: Text('Reset',
                                        style: GoogleFonts.secularOne(
                                          textStyle: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w200,
                                              color: Colors.white),
                                        )),
                                  ),
                                ]))))),
              ],
            ),
          ),
        ));
  }

  void _resetPasswordDialog() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete the details first'),
        ),
      );
      return;
    }
    String email = _emailController.text;
    String password = _passController.text;
    try {
      http.post(Uri.parse("${MyConfig().server}/barterit/php/editProfile.php"),
          body: {
            "email": email,
            "password": password,
          }).then((response) {
        if (response.statusCode == 200) {
          var jsondata = jsonDecode(response.body);
          if (jsondata['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Reset Password Success")));
            Navigator.pop(context);
            return;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Reset Password Failed")));
            return;
          }
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Reset Password Failed")));
      Navigator.pop(context);
    }
  }
}
