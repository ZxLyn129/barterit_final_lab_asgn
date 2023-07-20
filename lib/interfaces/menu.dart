import 'package:barterit_app/config_server.dart';
import 'package:barterit_app/interfaces/login_screen.dart';
import 'package:barterit_app/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'main_screen.dart';
import 'profile_screen.dart';
import 'seller_screen.dart';

class MenuWidget extends StatefulWidget {
  final User user;
  const MenuWidget({super.key, required this.user});

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  late double screenHeight;
  bool _isImageExist = false;
  String _imageUrl = "";

  Future<void> checkImageExistence() async {
    try {
      final response = await http.head(Uri.parse(_imageUrl));
      setState(() {
        _isImageExist = response.statusCode == 200;
      });
    } catch (error) {
      setState(() {
        _isImageExist = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.user.id == '0') {
      _imageUrl = "";
      _isImageExist = false;
    } else {
      _imageUrl =
          "${MyConfig().server}/barterit/assets/profile/${widget.user.id}.png?timestamp=${DateTime.now().millisecondsSinceEpoch}";
      checkImageExistence();
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    return Drawer(
      width: 280,
      elevation: 10,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.primary),
            currentAccountPicture: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.tealAccent,
              child: widget.user.id == '0'
                  ? Image.asset(
                      "assets/images/user.png",
                      fit: BoxFit.cover,
                    )
                  : _isImageExist
                      ? ClipOval(
                          child: CachedNetworkImage(
                            key: ValueKey(_imageUrl),
                            imageUrl: _imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        )
                      : Image.asset(
                          "assets/images/user.png",
                          fit: BoxFit.cover,
                        ),
            ),
            accountName: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Column(
                    children: [
                      Text(
                        widget.user.name.toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      )
                    ],
                  ),
                )
              ],
            ),
            accountEmail: Text(
              widget.user.email.toString(),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          ListTile(
            title: const Text(
              'Home',
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MainPage(
                            user: widget.user,
                          )));
            },
          ),
          const Divider(
            color: Colors.black54,
            height: 2,
          ),
          ListTile(
            title: const Text(
              'Selling',
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              if (widget.user.name.toString() == 'guest') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(15.0))),
                      title: const Text(
                        "Want to selling things?",
                        style: TextStyle(),
                      ),
                      content: const Text(
                          "Please login / register an account first",
                          style: TextStyle()),
                      actions: <Widget>[
                        TextButton(
                          child: const Text(
                            "Yes",
                            style: TextStyle(),
                          ),
                          onPressed: () async {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (content) => const LoginScreen()));
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
              } else {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SellerScreen(
                              user: widget.user,
                            )));
              }
            },
          ),
          const Divider(
            color: Colors.black54,
            height: 2,
          ),
          ListTile(
            title: const Text(
              'Profile',
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                            user: widget.user,
                          )));
            },
          ),
          const Divider(
            color: Colors.black54,
            height: 2,
          ),
        ],
      ),
    );
  }
}
