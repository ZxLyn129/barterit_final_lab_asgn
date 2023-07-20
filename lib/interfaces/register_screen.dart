import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../config_server.dart';
import '../models/user.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  void initState() {
    super.initState();
    loadEula();
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _repassController = TextEditingController();

  bool _check = false;
  bool _passwordVisit = true;
  final _formKey = GlobalKey<FormState>();
  String eula = '';
  late double screenHeight, screenWidth, cardwitdh;

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
              title: const Text("Registrations"),
              automaticallyImplyLeading: false,
            ),
            body: Center(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                      height: screenHeight * 0.3,
                      width: screenWidth,
                      child: Image.asset(
                        "assets/images/register.png",
                        fit: BoxFit.fill,
                      )),
                  SizedBox(
                    width: cardwitdh,
                    child: Card(
                      color: const Color.fromARGB(255, 221, 243, 239),
                      elevation: 10,
                      margin: const EdgeInsets.all(12),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        child: Form(
                          key: _formKey,
                          //form other details' fields
                          child: Column(children: <Widget>[
                            Text(
                              "Register New Account",
                              style: GoogleFonts.carterOne(
                                textStyle: const TextStyle(fontSize: 20),
                              ),
                            ),
                            TextFormField(
                                controller: _nameController,
                                keyboardType: TextInputType.text,
                                validator: (val) =>
                                    val!.isEmpty || (val.length < 3)
                                        ? "Name must be longer than 3"
                                        : null,
                                decoration: const InputDecoration(
                                    labelText: 'Name',
                                    labelStyle: TextStyle(),
                                    icon: Icon(Icons.person),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 2.0,
                                            color: Colors.blueGrey)))),
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
                                keyboardType: TextInputType.phone,
                                validator: (val) => val!.isEmpty ||
                                        (val.length < 10)
                                    ? "phone must be longer or equal than 10"
                                    : null,
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                    labelText: 'Phone',
                                    labelStyle: TextStyle(),
                                    icon: Icon(Icons.phone),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(width: 2.0),
                                    ))),
                            TextFormField(
                                controller: _passController,
                                keyboardType: TextInputType.visiblePassword,
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
                                          width: 2.0, color: Colors.blueGrey)),
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
                                keyboardType: TextInputType.visiblePassword,
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
                                          width: 2.0, color: Colors.blueGrey)),
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
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _check,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _check = value!;
                                    });
                                  },
                                ),
                                Flexible(
                                  child: GestureDetector(
                                    onTap: showEula,
                                    child: const Text('Agree with T&C',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic)),
                                  ),
                                ),
                              ],
                            ),
                            MaterialButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                              minWidth: 110,
                              height: 50,
                              elevation: 10,
                              onPressed: _registerAccountDialog,
                              color: Theme.of(context).colorScheme.primary,
                              child: Text('Register',
                                  style: GoogleFonts.secularOne(
                                    textStyle: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w200,
                                        color: Colors.white),
                                  )),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        "Already Register?",
                        style: TextStyle(fontSize: 16),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (content) => const LoginScreen()));
                        },
                        child: const Text(
                          "  Login here",
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
                  const SizedBox(height: 10),
                ],
              ),
            ))));
  }

  void _registerAccountDialog() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please complete your registration form first")));
      return;
    }
    if (!_check) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please accept the terms and conditions")));
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          title: const Text(
            "Register a new account",
            style: TextStyle(),
          ),
          content: const Text("Are you sure?", style: TextStyle()),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(),
              ),
              onPressed: () {
                registerNewUser();
              },
            ),
            TextButton(
              child: const Text(
                "No",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void registerNewUser() {
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passController.text;
    String phone = _phoneController.text;

    try {
      http.post(Uri.parse("${MyConfig().server}/barterit/php/registerUser.php"),
          body: {
            "name": name,
            "email": email,
            "phone": phone,
            "password": password,
          }).then((response) {
        var jsondata = jsonDecode(response.body);
        if (response.statusCode == 200 && jsondata['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Registration Success")));
          Navigator.push(context,
              MaterialPageRoute(builder: (content) => const LoginScreen()));
          return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Registration Failed")));
          Navigator.pop(context);
          return;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Registration Failed")));
      Navigator.pop(context);
    }
  }

  loadEula() async {
    eula = await rootBundle.loadString('assets/eula.txt');
  }

  showEula() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "EULA",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            height: 350,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                      child: RichText(
                    softWrap: true,
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                        text: eula),
                  )),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Close",
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void goHome() {
    User user = User(
        id: "0",
        email: "guest@gmail.com",
        name: "guest",
        phone: '-',
        dateregister: '0',
        otp: '0');
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (content) => MainPage(
                  user: user,
                )));
  }
}
