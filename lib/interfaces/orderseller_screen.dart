import 'dart:convert';

import 'package:barterit_app/config_server.dart';
import 'package:barterit_app/interfaces/login_screen.dart';
import 'package:barterit_app/interfaces/main_screen.dart';
import 'package:barterit_app/interfaces/orderdetailsseller.dart';
import 'package:barterit_app/models/orderdetails.dart';
import 'package:barterit_app/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class OrdersSellerPage extends StatefulWidget {
  final User user;
  const OrdersSellerPage({super.key, required this.user});

  @override
  State<OrdersSellerPage> createState() => _OrdersSellerPageState();
}

class _OrdersSellerPageState extends State<OrdersSellerPage> {
  late double screenHeight, screenWidth, resWidth;
  List<OrderDetails> orderList = <OrderDetails>[];
  bool _isImageExist = false;
  String _imageUrl = "";
  var total = 0.00;
  final df = DateFormat('yyyy-MM-dd HH:mm');

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
    if (widget.user.name == "guest") {
      _imageUrl = "";
      _isImageExist = false;
      showLoginDialog();
    } else {
      loadSellerOrders();
      _imageUrl =
          "${MyConfig().server}/barterit/assets/profile/${widget.user.id}.png?timestamp=${DateTime.now().millisecondsSinceEpoch}";
      checkImageExistence();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 600) {
      resWidth = screenWidth;
    } else {
      resWidth = screenWidth * 0.75;
      screenHeight = 1080;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders List"),
      ),
      body: Container(
        child: orderList.isEmpty
            ? const Center(
                child: Text(
                  "You haven't received any orders yet. ",
                  style: TextStyle(
                      color: Color.fromARGB(255, 211, 47, 47), fontSize: 20),
                ),
              )
            : Column(
                children: [
                  SizedBox(
                    width: screenWidth,
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 8, 0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 15,
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
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          ),
                                        )
                                      : Image.asset(
                                          "assets/images/user.png",
                                          fit: BoxFit.cover,
                                        ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Text(
                              "Hello, ${widget.user.name} !",
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Your Current Order/s (${orderList.length})",
                          style: GoogleFonts.ubuntu(
                            textStyle: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade800),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.attach_money_outlined,
                            size: 22,
                            color: Colors.teal.shade800,
                          ),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15.0)),
                                    ),
                                    title: const Text(
                                      "Total Revenues",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    content: Text(
                                      "RM ${total.toStringAsFixed(2)}",
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                          child: const Text(
                                            "Close",
                                            style: TextStyle(),
                                          ),
                                          onPressed: () async {
                                            Navigator.pop(context);
                                          }),
                                    ],
                                  );
                                });
                          },
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
                    child: Divider(
                      color: Colors.black45,
                      height: 2,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: orderList.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Colors.teal.shade50,
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: InkWell(
                            onTap: () async {
                              OrderDetails myorder = OrderDetails.fromJson(
                                  orderList[index].toJson());
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (content) => OrdersSellerDetailsPage(
                                    user: widget.user,
                                    order: myorder,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                          backgroundColor: Colors.blueAccent,
                                          child: Text(
                                            (index + 1).toString(),
                                            style: TextStyle(
                                                color: Colors.grey.shade200),
                                          )),
                                      const SizedBox(width: 13),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Receipt: ${truncateString("${orderList[index].orderBill}", 23)}",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade900),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "${orderList[index].itemName}",
                                            style: GoogleFonts.concertOne(
                                              textStyle:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          Text(
                                            "Barter by ${orderList[index].buyerName}",
                                            style:
                                                const TextStyle(fontSize: 13),
                                          ),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            width: 275,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "RM ${double.parse(orderList[index].itemPrice.toString()).toStringAsFixed(2)} each",
                                                  style: const TextStyle(
                                                      fontSize: 13),
                                                ),
                                                Text(
                                                  "x ${orderList[index].orderdetailQty}",
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            width: 275,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  df.format(DateTime.parse(
                                                      orderList[index]
                                                          .orderdetailDate
                                                          .toString())),
                                                  style: const TextStyle(
                                                      fontSize: 13),
                                                ),
                                                Text(
                                                  orderList[index]
                                                      .orderStatus
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors
                                                          .tealAccent.shade700),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String truncateString(String str, int size) {
    if (str.length > size) {
      str = str.substring(0, size);
      return "$str...";
    } else {
      return str;
    }
  }

  void showLoginDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
            ),
            title: const Text(
              "View Your Purchase List?",
              style: TextStyle(),
            ),
            content: const Text(
              "Please login/register an account first.",
              style: TextStyle(),
            ),
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
                      builder: (content) => const LoginScreen(),
                    ),
                  );
                },
              ),
              TextButton(
                child: const Text(
                  "No",
                  style: TextStyle(),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (content) => MainPage(user: widget.user)));
                },
              ),
            ],
          );
        });
  }

  void loadSellerOrders() {
    http.post(
      Uri.parse("${MyConfig().server}/barterit/php/loadSellerOrders.php"),
      body: {
        "sellerid": widget.user.id.toString(),
      },
    ).then((response) {
      orderList.clear();
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);
        if (jsondata['status'] == 'success') {
          var orderdata = jsondata['data'];
          if (orderdata['orders'] != null) {
            orderdata['orders'].forEach((v) {
              orderList.add(OrderDetails.fromJson(v));
              total += double.parse(orderList.last.itemPrice.toString()) *
                  int.parse(orderList.last.orderdetailQty.toString());
            });
          }
        }
      }

      if (orderList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No received any orders.")),
        );
      }
      setState(() {});
    });
  }
}
