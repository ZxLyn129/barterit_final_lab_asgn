import 'dart:convert';
import 'package:barterit_app/config_server.dart';
import 'package:barterit_app/interfaces/login_screen.dart';
import 'package:barterit_app/interfaces/main_screen.dart';
import 'package:barterit_app/interfaces/orderdetailsbuyer.dart';
import 'package:barterit_app/models/orderdetails.dart';
import 'package:barterit_app/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class MyPurchsePage extends StatefulWidget {
  final User user;
  const MyPurchsePage({Key? key, required this.user}) : super(key: key);

  @override
  State<MyPurchsePage> createState() => _MyPurchsePageState();
}

class _MyPurchsePageState extends State<MyPurchsePage> {
  late double screenHeight, screenWidth, resWidth;

  List<OrderDetails> orderList = <OrderDetails>[];
  final df = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void initState() {
    super.initState();
    if (widget.user.name == "guest") {
      showLoginDialog();
    } else {
      loadbuyerorders();
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
        title: const Text("My Barters"),
      ),
      body: Container(
        child: orderList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "You haven't barter any items yet. ",
                      style: TextStyle(
                          color: Color.fromARGB(255, 211, 47, 47),
                          fontSize: 20),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainPage(
                              user: widget.user,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "View More",
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Colors.black),
                      ),
                    )
                  ],
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 25, 0, 10),
                    child: Center(
                      child: Text(
                        "${widget.user.name}'s Recent Barters",
                        style: GoogleFonts.mogra(
                          textStyle: const TextStyle(
                            fontSize: 25,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(65, 0, 65, 10),
                    child: Container(
                      height: 3,
                      color: Colors.teal.shade300,
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
                              OrderDetails mybarter = OrderDetails.fromJson(
                                  orderList[index].toJson());
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (content) => MyPurchasesDetailsPage(
                                    user: widget.user,
                                    order: mybarter,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.store,
                                        size: 25,
                                        color: Colors.grey.shade800,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        orderList[index]
                                            .sellerName
                                            .toString()
                                            .toUpperCase(),
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer(),
                                      Text(
                                        "${orderList[index].orderStatus}",
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 15, 0, 10),
                                    child: Container(
                                      height: 2,
                                      color: Colors.black26,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      CachedNetworkImage(
                                        width: 100,
                                        fit: BoxFit.cover,
                                        imageUrl:
                                            "${MyConfig().server}/barterit/assets/itemImages/${orderList[index].itemId}i.png",
                                        placeholder: (context, url) =>
                                            const LinearProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Receipt: ${truncateString("${orderList[index].orderBill}", 13)}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            df.format(DateTime.parse(
                                                orderList[index]
                                                    .orderdetailDate
                                                    .toString())),
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "x ${orderList[index].orderdetailQty}",
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Total Amount:  ",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.teal.shade700,
                                                ),
                                              ),
                                              Text(
                                                "RM ${double.parse(orderList[index].orderdetailPaid.toString()).toStringAsFixed(2)}",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.teal.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
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

  void loadbuyerorders() {
    http.post(
      Uri.parse("${MyConfig().server}/barterit/php/loadBuyerOrders.php"),
      body: {
        "buyerid": widget.user.id.toString(),
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
            });
          }
        }
      }

      if (orderList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No purchased items.")),
        );
      }
      setState(() {});
    });
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
}
