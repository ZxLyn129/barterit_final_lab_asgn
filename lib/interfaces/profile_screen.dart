import 'dart:convert';
import 'dart:io';

import 'package:barterit_app/config_server.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/user.dart';
import 'login_screen.dart';
import 'main_screen.dart';
import 'menu.dart';
import 'register_screen.dart';
import 'resetpass_screen.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late double screenHeight, screenWidth, cardWidth;
  File? _image;
  var pathAsset = "assets/images/user.png";
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
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 600) {
      cardWidth = screenWidth;
    } else {
      cardWidth = 600;
      screenHeight = 1080;
    }

    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(title: const Text("Profile")),
          body: SingleChildScrollView(
            child: SizedBox(
              height: screenHeight,
              child: Center(
                child: Column(
                  children: [
                    Flexible(
                      flex: 3,
                      child: Card(
                        margin: const EdgeInsets.all(12),
                        elevation: 10,
                        color: Colors.blue.shade50,
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(15, 15, 15, 20),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Profile Information",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 0, 25, 5),
                                    child: Container(
                                      margin: const EdgeInsets.all(4),
                                      width: 100,
                                      child: ClipOval(
                                        child: CircleAvatar(
                                          radius: 50,
                                          backgroundColor:
                                              Colors.blueGrey.shade300,
                                          child: _image != null
                                              ? Image.file(_image!)
                                              : _isImageExist == true
                                                  ? CachedNetworkImage(
                                                      key: ValueKey(_imageUrl),
                                                      imageUrl: _imageUrl,
                                                      fit: BoxFit.contain,
                                                      placeholder: (context,
                                                              url) =>
                                                          const CircularProgressIndicator(),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const Icon(
                                                              Icons.error),
                                                    )
                                                  : Image.asset(pathAsset),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: SizedBox(
                                          height: 35,
                                          child: Text(
                                            widget.user.name.toString(),
                                            style:
                                                const TextStyle(fontSize: 24),
                                          ),
                                        ),
                                      ),
                                      const Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 2, 15, 8),
                                        child: Divider(
                                          color:
                                              Color.fromARGB(255, 13, 71, 161),
                                          height: 2,
                                          thickness: 1.3,
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: SizedBox(
                                          height: 25,
                                          child: Row(
                                            children: [
                                              const Icon(Icons.email),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 0, 15, 0),
                                                child: Text(
                                                  widget.user.email.toString(),
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: SizedBox(
                                          height: 25,
                                          child: Row(
                                            children: [
                                              const Icon(Icons.phone),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 0, 15, 0),
                                                child: widget.user.name ==
                                                        "guest"
                                                    ? Text(
                                                        widget.user.phone
                                                            .toString(),
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      )
                                                    : Text(
                                                        widget.user.phone
                                                            .toString(),
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: SizedBox(
                                          height: 25,
                                          child: Row(
                                            children: [
                                              const Icon(Icons.date_range),
                                              widget.user.dateregister
                                                          .toString() ==
                                                      '0'
                                                  ? Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          10, 0, 15, 0),
                                                      child: Text(
                                                        DateFormat('dd/MM/yyyy')
                                                            .format(
                                                                DateTime.now()),
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                    )
                                                  : Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          10, 0, 15, 0),
                                                      child: Text(
                                                        DateFormat('dd/MM/yyyy')
                                                            .format(DateTime
                                                                .parse(widget
                                                                    .user
                                                                    .dateregister
                                                                    .toString())),
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            color: Colors.tealAccent,
                            margin: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                            height: 55,
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(5, 15, 5, 15),
                                  child: Text(
                                    "PROFILE SETTINGS",
                                    style: GoogleFonts.mogra(
                                      textStyle: const TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: widget.user.email.toString() ==
                                    'guest@gmail.com'
                                ? ListView(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 3, 10, 3),
                                    shrinkWrap: true,
                                    children: [
                                      MaterialButton(
                                        onPressed: _loginDialog,
                                        child: Text(
                                          "Login",
                                          style: GoogleFonts.secularOne(
                                            textStyle: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w200,
                                              color: Color.fromARGB(
                                                  255, 2, 171, 149),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Divider(
                                        color: Colors.black54,
                                        height: 2,
                                      ),
                                      MaterialButton(
                                        onPressed: _registerDialog,
                                        child: Text(
                                          "New Registration",
                                          style: GoogleFonts.secularOne(
                                            textStyle: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w200,
                                              color: Color.fromARGB(
                                                  255, 2, 171, 149),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Divider(
                                        color: Colors.black38,
                                        height: 2,
                                      ),
                                    ],
                                  )
                                : ListView(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 3, 10, 3),
                                    shrinkWrap: true,
                                    children: [
                                      MaterialButton(
                                        onPressed: _editdetails,
                                        child: Text(
                                          "Edit Details",
                                          style: GoogleFonts.secularOne(
                                            textStyle: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w200,
                                              color: Color.fromARGB(
                                                  255, 2, 171, 149),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Divider(
                                        color: Colors.black38,
                                        height: 2,
                                      ),
                                      MaterialButton(
                                        onPressed: _selectImage,
                                        child: Text(
                                          "Update Image",
                                          style: GoogleFonts.secularOne(
                                            textStyle: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w200,
                                              color: Color.fromARGB(
                                                  255, 2, 171, 149),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Divider(
                                        color: Colors.black38,
                                        height: 2,
                                      ),
                                      MaterialButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (content) =>
                                                  const ResetPassword(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "Reset Password",
                                          style: GoogleFonts.secularOne(
                                            textStyle: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w200,
                                              color: Color.fromARGB(
                                                  255, 2, 171, 149),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Divider(
                                        color: Colors.black26,
                                        height: 2,
                                      ),
                                      MaterialButton(
                                        onPressed: _logout,
                                        child: Text(
                                          "Logout",
                                          style: GoogleFonts.secularOne(
                                            textStyle: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w200,
                                              color: Color.fromARGB(
                                                  255, 2, 171, 149),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Divider(
                                        color: Colors.black,
                                        height: 2,
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
            ),
          ),
          drawer: MenuWidget(
            user: widget.user,
          ),
        ));
  }

  void _loginDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          title: const Text(
            "Login",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: const Text("Are you sure?"),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.push(
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
  }

  void _registerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          title: const Text(
            "New Account Registration",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: const Text("Are you sure?"),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (content) => const RegisterScreen()));
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

  void _logout() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          title: const Text(
            "Logout",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Are you sure?", style: TextStyle()),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(),
              ),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('email', '');
                await prefs.setString('pass', '');
                await prefs.setBool('checkbox', false);
                User user = User(
                    id: "0",
                    email: "guest@gmail.com",
                    name: "guest",
                    phone: '-',
                    dateregister: '0',
                    otp: '0');
                if (!mounted) return;
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (content) => MainPage(user: user)));
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

  void _editdetails() {
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController phoneController = TextEditingController();

    nameController.text = widget.user.name.toString();
    emailController.text = widget.user.email.toString();
    phoneController.text = widget.user.phone.toString();

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            title: const Text(
              "Edit Your Details",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: 400,
              height: screenHeight / 3.5,
              child: Column(
                children: [
                  TextField(
                      controller: nameController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(),
                          icon: Icon(
                            Icons.person,
                            color: Colors.teal,
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2.0, color: Colors.blueGrey)))),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(),
                          icon: Icon(
                            Icons.email,
                            color: Colors.teal,
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2.0, color: Colors.blueGrey)))),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                          labelText: 'Phone',
                          labelStyle: TextStyle(),
                          icon: Icon(
                            Icons.phone,
                            color: Colors.teal,
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2.0, color: Colors.blueGrey)))),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  "Save",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  http.post(
                      Uri.parse(
                          "${MyConfig().server}/barterit/php/editProfile.php"),
                      body: {
                        "name": nameController.text,
                        "email": emailController.text,
                        "phone": phoneController.text,
                        "userid": widget.user.id,
                      }).then((response) {
                    if (response.statusCode == 200) {
                      var jsondata = jsonDecode(response.body);
                      if (jsondata['status'] == 'success') {
                        setState(() {
                          widget.user.name = nameController.text;
                          widget.user.email = emailController.text;
                          widget.user.phone = phoneController.text;
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (content) => ProfileScreen(
                                        user: widget.user,
                                      )));
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Edit Details Success")));
                        setState(() {});
                        return;
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Edit Details Failed")));
                        return;
                      }
                    }
                  });
                },
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ))
            ],
          );
        });
  }

  void _selectImage() {
    if (widget.user.id == "0") {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please login / resiter first.")));
      Navigator.push(context,
          MaterialPageRoute(builder: (content) => const LoginScreen()));
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
            title: const Text(
              "Select from",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size(screenWidth / 3.5, screenHeight / 15)),
                  label: const Text('Gallery'),
                  onPressed: () => {
                    Navigator.of(context).pop(),
                    _selectfromGallery(),
                  },
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera),
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size(screenWidth / 3.5, screenHeight / 15)),
                  label: const Text('Camera'),
                  onPressed: () => {
                    Navigator.of(context).pop(),
                    _selectFromCamera(),
                  },
                ),
              ],
            ));
      },
    );
  }

  Future<void> _selectfromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 800,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      cropImage();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select an image.")));
    }
  }

  Future<void> _selectFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 800,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      cropImage();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please take an image.")));
    }
  }

  Future<void> cropImage() async {
    CroppedFile? croppedFile;
    if (_image != null) {
      croppedFile = await ImageCropper().cropImage(
        sourcePath: _image!.path,
        aspectRatioPresets: [CropAspectRatioPreset.square],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.teal,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.ratio16x9,
              lockAspectRatio: true),
          IOSUiSettings(
            title: 'Cropper',
          ),
        ],
      );
    }

    if (croppedFile != null) {
      File imageFile = File(croppedFile.path);
      _image = imageFile;
      _updateProfileImage(_image);
    }
  }

  void _updateProfileImage(image) {
    String base64Image = base64Encode(image!.readAsBytesSync());
    http.post(Uri.parse("${MyConfig().server}/barterit/php/editProfile.php"),
        body: {
          "id": widget.user.id,
          "image": base64Image,
        }).then((response) {
      var jsondata = jsonDecode(response.body);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Success")));
        setState(() {});
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Failed")));
      }
    });
  }
}
