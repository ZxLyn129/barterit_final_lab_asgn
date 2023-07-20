import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../config_server.dart';
import '../models/user.dart';
import 'main_screen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    checkNAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                    image: AssetImage('assets/images/splash.png'),
                    fit: BoxFit.fill,
                  ))),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 50, 0, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircularProgressIndicator(),
                Text(
                  "Version 1.0",
                  style: GoogleFonts.noticiaText(
                    textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: .5),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> checkNAutoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = (prefs.getString('email')) ?? '';
    String password = (prefs.getString('pass')) ?? '';
    bool ischeck = (prefs.getBool('checkbox')) ?? false;
    late User user;
    if (ischeck) {
      http.post(Uri.parse("${MyConfig().server}/barterit/php/loginUser.php"),
          body: {
            "email": email,
            "password": password,
          }).then((response) {
        if (response.statusCode == 200) {
          var jsondata = jsonDecode(response.body);
          if (jsondata['status'] == 'success') {
            user = User.fromJson(jsondata['data']);
            Timer(
                const Duration(seconds: 3),
                () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (content) => MainPage(user: user))));
          } else {
            User user = User(
                id: "0",
                email: "guest@gmail.com",
                name: "guest",
                phone: '-',
                dateregister: '0',
                otp: '0');
            Timer(
                const Duration(seconds: 3),
                () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (content) => MainPage(user: user))));
          }
        } else {
          User user = User(
              id: "0",
              email: "guest@gmail.com",
              name: "guest",
              phone: '-',
              dateregister: '0',
              otp: '0');
          Timer(
              const Duration(seconds: 3),
              () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (content) => MainPage(user: user))));
        }
      }).timeout(const Duration(seconds: 5), onTimeout: () {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Time Out")));
      });
    } else {
      User user = User(
          id: "0",
          email: "guest@gmail.com",
          name: "guest",
          phone: '-',
          dateregister: '0',
          otp: '0');
      Timer(
          const Duration(seconds: 3),
          () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (content) => MainPage(user: user))));
    }
  }
}
