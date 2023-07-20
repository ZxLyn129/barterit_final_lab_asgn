import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../config_server.dart';
import '../models/user.dart';
import 'main_screen.dart';
import 'register_screen.dart';
import 'resetpass_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  late double screenHeight, screenWidth, cardwitdh;
  final _formKey = GlobalKey<FormState>();
  bool _check = false;

  User user = User(
      id: "0",
      email: "guest@gmail.com",
      name: "guest",
      phone: '-',
      dateregister: '0',
      otp: '0');

  @override
  void initState() {
    super.initState();
    loadPref();
  }

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
        onWillPop: () async => false,
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Login'),
              automaticallyImplyLeading: false,
            ),
            body: SingleChildScrollView(
              child: Column(children: [
                SizedBox(
                    height: screenHeight * 0.3,
                    width: screenWidth,
                    child: Image.asset(
                      "assets/images/login.png",
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
                            child: Column(
                              children: <Widget>[
                                Text(
                                  "Login Account",
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
                                    keyboardType: TextInputType.visiblePassword,
                                    validator: (val) =>
                                        val!.isEmpty || (val.length < 8)
                                            ? "Password must be longer than 8"
                                            : null,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Password',
                                      labelStyle: TextStyle(),
                                      icon: Icon(Icons.lock),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 2.0,
                                              color: Colors.blueGrey)),
                                    )),
                                const SizedBox(
                                  height: 8,
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Checkbox(
                                        value: _check,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            saveremovepref(value!);
                                            _check = value;
                                          });
                                        },
                                      ),
                                      Flexible(
                                        child: GestureDetector(
                                          onTap: null,
                                          child: const Text('Remember Me',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              )),
                                        ),
                                      ),
                                    ]),
                                MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0)),
                                  minWidth: 110,
                                  height: 50,
                                  elevation: 10,
                                  onPressed: _loginAccountDialog,
                                  color: Theme.of(context).colorScheme.primary,
                                  child: Text('Login',
                                      style: GoogleFonts.secularOne(
                                        textStyle: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w200,
                                            color: Colors.white),
                                      )),
                                ),
                              ],
                            )),
                      )),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "No Account?",
                      style: TextStyle(fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (content) => const RegisterScreen()));
                      },
                      child: const Text(
                        "  Create now",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "Forgot Password?",
                      style: TextStyle(fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (content) => const ResetPassword()),
                        );
                      },
                      child: const Text(
                        "  Reset here",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "Back Home?",
                      style: TextStyle(fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: goHome,
                      child: const Text(
                        "  Click here",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                    )
                  ],
                ),
              ]),
            )));
  }

  void saveremovepref(bool value) async {
    String email = _emailController.text;
    String password = _passController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value) {
      if (!_formKey.currentState!.validate()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please complete your login details first'),
          ),
        );
        _check = false;
        return;
      }
      await prefs.setString('email', email);
      await prefs.setString('pass', password);
      await prefs.setBool("checkbox", value);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Your details is stored")));
    } else {
      await prefs.setString('email', '');
      await prefs.setString('pass', '');
      await prefs.setBool('checkbox', false);
      setState(() {
        _emailController.text = '';
        _passController.text = '';
        _check = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Your details is removed")));
    }
  }

  Future<void> loadPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = (prefs.getString('email')) ?? '';
    String password = (prefs.getString('pass')) ?? '';
    _check = (prefs.getBool('checkbox')) ?? false;
    if (_check) {
      setState(() {
        _emailController.text = email;
        _passController.text = password;
      });
    }
  }

  void _loginAccountDialog() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete your login details first'),
        ),
      );
      return;
    }
    String email = _emailController.text;
    String password = _passController.text;

    try {
      http.post(Uri.parse("${MyConfig().server}/barterit/php/loginUser.php"),
          body: {
            "email": email,
            "password": password,
          }).then((response) {
        if (response.statusCode == 200) {
          var jsondata = jsonDecode(response.body);
          if (jsondata['status'] == 'success') {
            user = User.fromJson(jsondata['data']);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const AlertDialog(
                  title: Text("Please Wait"),
                  content: Text("Login..."),
                );
              },
            );
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Login Success")));
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (content) => MainPage(
                          user: user,
                        )));
          } else {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Login Failed")));
          }
        }
      }).timeout(const Duration(seconds: 60), onTimeout: () {});
    } on TimeoutException catch (_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Time Out")));
    }
  }

  void goHome() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (content) => MainPage(
                  user: user,
                )));
  }
}
