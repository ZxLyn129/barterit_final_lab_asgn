import 'dart:convert';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../config_server.dart';
import '../models/user.dart';

class AddProductScreen extends StatefulWidget {
  final User user;
  const AddProductScreen({super.key, required this.user});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemDesController = TextEditingController();
  final TextEditingController _itemPriceController = TextEditingController();
  final TextEditingController _itemQtyController = TextEditingController();
  final TextEditingController _currentStateController = TextEditingController();
  final TextEditingController _currentLocalityController =
      TextEditingController();

  late String selectedType;
  List<String> type = [
    "Item Types...",
    "Appliances",
    "Baby and Kids",
    "Books, Music, and Movies",
    "Collectibles and Antiques",
    "Clothing and Accessories",
    "Electronic",
    "Furniture and Home Decor",
    "Miscellaneous",
    "Sports and Fitness Equipment",
    "Vehicles",
    "Others",
  ];

  final List<File?> _image = [null, null, null];

  late double screenHeight, screenWidth, cardwitdh, resWidth;
  //File? _image;
  var pathAsset = "assets/images/camera.png";
  final _formKey = GlobalKey<FormState>();
  late Position _currentPosition;
  String latitude = "";
  String longitude = "";

  @override
  void initState() {
    super.initState();
    selectedType = type[0];
    _checkPosition();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 600) {
      resWidth = cardwitdh = screenWidth;
    } else {
      resWidth = screenWidth * 0.8;
      cardwitdh = 600;
      screenHeight = 1080;
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("New Item Registration"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                  child: CarouselSlider(
                      items: [image1(), image2(), image3()],
                      options: CarouselOptions(
                        height: 180.0,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        aspectRatio: 16 / 9,
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enableInfiniteScroll: true,
                        autoPlayAnimationDuration:
                            const Duration(milliseconds: 800),
                        viewportFraction: 0.8,
                      ))),
              SizedBox(
                width: cardwitdh,
                child: Card(
                  color: const Color.fromARGB(255, 221, 243, 239),
                  elevation: 10,
                  margin: const EdgeInsets.all(10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          Text(
                            "Add New Item",
                            style: GoogleFonts.carterOne(
                              textStyle: const TextStyle(fontSize: 20),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.category,
                                color: Color.fromARGB(255, 120, 120, 120),
                              ),
                              const SizedBox(width: 15),
                              SizedBox(
                                height: 50,
                                child: DropdownButton(
                                  value: selectedType,
                                  onChanged: (newValue) {
                                    if (newValue == type[0]) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  "Please select the item type")));
                                      return;
                                    }
                                    setState(() {
                                      selectedType = newValue!;
                                      //print(selectedType);
                                    });
                                  },
                                  items: type.map((selectedType) {
                                    return DropdownMenuItem(
                                      value: selectedType,
                                      child: Text(
                                        selectedType,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                          TextFormField(
                              textInputAction: TextInputAction.next,
                              controller: _itemNameController,
                              keyboardType: TextInputType.text,
                              validator: (val) =>
                                  val!.isEmpty || (val.length < 5)
                                      ? "Name must be longer than 5"
                                      : null,
                              decoration: const InputDecoration(
                                  labelText: 'Item Name',
                                  labelStyle: TextStyle(),
                                  icon: Icon(Icons.type_specimen),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 2.0,
                                          color: Colors.blueGrey)))),
                          TextFormField(
                              textInputAction: TextInputAction.next,
                              validator: (val) => val!.isEmpty ||
                                      (val.length < 15)
                                  ? "Item description must be longer than 15"
                                  : null,
                              maxLines: 4,
                              controller: _itemDesController,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                  labelText: 'Item Description',
                                  alignLabelWithHint: true,
                                  labelStyle: TextStyle(),
                                  icon: Icon(
                                    Icons.description,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 2.0,
                                          color: Colors.blueGrey)))),
                          Row(children: [
                            Flexible(
                              flex: 5,
                              child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  validator: (val) => val!.isEmpty
                                      ? "Item price must contain value"
                                      : null,
                                  onFieldSubmitted: (v) {},
                                  controller: _itemPriceController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                      labelText: 'Item Price',
                                      labelStyle: TextStyle(),
                                      icon: Icon(Icons.price_change),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 2.0,
                                              color: Colors.blueGrey)))),
                            ),
                            Flexible(
                              flex: 5,
                              child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  validator: (val) => val!.isEmpty
                                      ? "Quantity should be more than 0"
                                      : null,
                                  controller: _itemQtyController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                      labelText: 'Item Quantity',
                                      labelStyle: TextStyle(),
                                      icon: Icon(Icons.numbers),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 2.0,
                                              color: Colors.blueGrey)))),
                            ),
                          ]),
                          Row(children: [
                            Flexible(
                              flex: 5,
                              child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  validator: (val) =>
                                      val!.isEmpty || (val.length < 3)
                                          ? "Current State"
                                          : null,
                                  enabled: false,
                                  controller: _currentStateController,
                                  keyboardType: TextInputType.text,
                                  decoration: const InputDecoration(
                                      labelText: 'Current State',
                                      labelStyle: TextStyle(),
                                      icon: Icon(Icons.flag),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 2.0, color: Colors.blueGrey),
                                      ))),
                            ),
                            Flexible(
                              flex: 5,
                              child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  enabled: false,
                                  validator: (val) =>
                                      val!.isEmpty || (val.length < 3)
                                          ? "Current Locality"
                                          : null,
                                  controller: _currentLocalityController,
                                  keyboardType: TextInputType.text,
                                  decoration: const InputDecoration(
                                      labelText: 'Current Locality',
                                      labelStyle: TextStyle(),
                                      icon: Icon(Icons.map),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 2.0, color: Colors.blueGrey),
                                      ))),
                            ),
                          ]),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                            child: MaterialButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                              minWidth: 110,
                              height: 50,
                              elevation: 10,
                              onPressed: insertItemDialog,
                              color: Theme.of(context).colorScheme.primary,
                              child: Text('Insert',
                                  style: GoogleFonts.secularOne(
                                    textStyle: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w200,
                                        color: Colors.white),
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget image1() {
    int i = 0;
    if (_image[0] == null) {
      return GestureDetector(
          onTap: () {
            _selectImageDialog(i);
          },
          child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 10,
              child: Container(
                height: screenHeight * 0.25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: AssetImage(pathAsset),
                    fit: BoxFit.contain,
                  ),
                ),
                child: const Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      "Image 1",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              )));
    } else {
      return GestureDetector(
          onTap: () {
            _selectImageDialog(i);
          },
          child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 10,
              child: Container(
                height: screenHeight * 0.25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: FileImage(_image[0]!),
                    fit: BoxFit.contain,
                  ),
                ),
              )));
    }
  }

  Widget image2() {
    int i = 1;
    if (_image[1] == null) {
      return GestureDetector(
          onTap: () {
            _selectImageDialog(i);
          },
          child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 10,
              child: Container(
                height: screenHeight * 0.25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: AssetImage(pathAsset),
                    fit: BoxFit.contain,
                  ),
                ),
                child: const Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      "Image 2",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              )));
    } else {
      return GestureDetector(
          onTap: () {
            _selectImageDialog(i);
          },
          child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 10,
              child: Container(
                height: screenHeight * 0.25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: FileImage(_image[1]!),
                    fit: BoxFit.contain,
                  ),
                ),
              )));
    }
  }

  Widget image3() {
    int i = 2;
    if (_image[2] == null) {
      return GestureDetector(
          onTap: () {
            _selectImageDialog(i);
          },
          child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 10,
              child: Container(
                height: screenHeight * 0.25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: AssetImage(pathAsset),
                    fit: BoxFit.contain,
                  ),
                ),
                child: const Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      "Image 3",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              )));
    } else {
      return GestureDetector(
          onTap: () {
            _selectImageDialog(i);
          },
          child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 10,
              child: Container(
                height: screenHeight * 0.25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: FileImage(_image[2]!),
                    fit: BoxFit.contain,
                  ),
                ),
              )));
    }
  }

  void _selectImageDialog(int i) {
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
                      fixedSize: Size(resWidth * 0.3, resWidth * 0.15)),
                  label: const Text('Gallery'),
                  onPressed: () => {
                    Navigator.of(context).pop(),
                    _selectfromGallery(i),
                  },
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera),
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size(resWidth * 0.3, resWidth * 0.15)),
                  label: const Text('Camera'),
                  onPressed: () => {
                    Navigator.of(context).pop(),
                    _selectFromCamera(i),
                  },
                ),
              ],
            ));
      },
    );
  }

  Future<void> _selectfromGallery(int i) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 1200,
      maxWidth: 1000,
    );

    if (pickedFile != null) {
      if (i == 0) {
        _image[0] = File(pickedFile.path);
      } else if (i == 1) {
        _image[1] = File(pickedFile.path);
      } else {
        _image[2] = File(pickedFile.path);
      }

      cropImage(i);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select an image.")));
    }
  }

  Future<void> _selectFromCamera(int i) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 1200,
      maxWidth: 1000,
    );

    if (pickedFile != null) {
      if (i == 0) {
        _image[0] = File(pickedFile.path);
      } else if (i == 1) {
        _image[1] = File(pickedFile.path);
      } else {
        _image[2] = File(pickedFile.path);
      }
      cropImage(i);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please take an image.")));
    }
  }

  Future<void> cropImage(int i) async {
    CroppedFile? croppedFile;
    if (_image[i] != null) {
      croppedFile = await ImageCropper().cropImage(
        sourcePath: _image[i]!.path,
        aspectRatioPresets: [CropAspectRatioPreset.ratio4x3],
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
      _image[i] = imageFile;

      setState(() {});
    }
  }

  Future<void> _checkPosition() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Please allow the app to access the location.")));
          await Future.delayed(const Duration(seconds: 3));
          if (!mounted) return;
          Navigator.of(context).pop();
          Geolocator.openLocationSettings();
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Please allow the app to access the location.")));
        await Future.delayed(const Duration(seconds: 3));
        if (!mounted) return;
        Navigator.of(context).pop();
        Geolocator.openLocationSettings();
      }
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      _getAddress(_currentPosition);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please allow the app to access the location.")));
    }
  }

  void _getAddress(Position position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isEmpty) {
        _currentStateController.text = "Changlun";
        _currentLocalityController.text = "Kedah";
        latitude = "6.443455345";
        longitude = "100.05488449";
      } else {
        _currentStateController.text = placemarks[0].locality.toString();
        _currentLocalityController.text =
            placemarks[0].administrativeArea.toString();
        latitude = _currentPosition.latitude.toString();
        longitude = _currentPosition.longitude.toString();
      }
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "Error in fixing your location. Make sure internet connection is available and try again.")));
    }
  }

  Future<void> insertItemDialog() async {
    if (_image[0] == null && _image[1] == null && _image[2] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please take the item images.")));
      return;
    }
    if (selectedType == type[0]) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select the item type")));
      return;
    }
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please fill in all the required fields.")));
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: const Text(
            "Insert your item?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Are you sure?", style: TextStyle(fontSize: 18)),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                insertItem();
              },
            ),
            TextButton(
              child: const Text(
                "No",
                style: TextStyle(fontSize: 16),
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

  void insertItem() {
    String itmName = _itemNameController.text;
    String itmDes = _itemDesController.text;
    String itmPrice = _itemPriceController.text;
    String itmQty = _itemQtyController.text;
    String state = _currentStateController.text;
    String locality = _currentLocalityController.text;
    String base64Image1 = base64Encode(_image[0]!.readAsBytesSync());
    String base64Image2 = base64Encode(_image[1]!.readAsBytesSync());
    String base64Image3 = base64Encode(_image[2]!.readAsBytesSync());

    http.post(Uri.parse("${MyConfig().server}/barterit/php/insertItem.php"),
        body: {
          "itm_owner_id": widget.user.id,
          "itm_name": itmName,
          "itm_type": selectedType,
          "itm_des": itmDes,
          "itm_price": itmPrice,
          "itm_qty": itmQty,
          "itm_state": state,
          "itm_locality": locality,
          "itm_latitude": latitude,
          "itm_longitude": longitude,
          "itm_image1": base64Image1,
          "itm_image2": base64Image2,
          "itm_image3": base64Image3,
        }).then((response) {
      //print(response.body);
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Insert New Item Success")));
        Navigator.of(context).pop();
        return;
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Insert Failed")));
        return;
      }
    });
  }
}
