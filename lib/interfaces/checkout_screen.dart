import 'dart:convert';

import 'package:barterit_app/config_server.dart';
import 'package:barterit_app/interfaces/itemdetails_screen.dart';
import 'package:barterit_app/interfaces/main_screen.dart';
import 'package:barterit_app/interfaces/stripepay_screen.dart';
import 'package:barterit_app/models/item.dart';
import 'package:barterit_app/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class CheckoutPage extends StatefulWidget {
  final User user;
  final Item item;
  final int orderqty;
  final double total;
  const CheckoutPage(
      {super.key,
      required this.user,
      required this.item,
      required this.total,
      required this.orderqty});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late double screenHeight, screenWidth, resWidth;

  var sellername = " ";
  var tax = 0.00;
  var totalpaid = 0.00;
  var aftertax = 0.00;
  String address = "";
  @override
  void initState() {
    super.initState();
    loadSeller();
    calculateTaxNTotal();
  }

  void calculateTaxNTotal() {
    setState(() {
      tax = widget.total * 0.06;
      totalpaid = widget.total + tax + 6;
      aftertax = double.parse(widget.item.itmPrice.toString()) +
          double.parse(widget.item.itmPrice.toString()) * 0.06;
    });
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
          title: const Text("Checkout Item"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 25, 18, 10),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Your Item",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                child: Container(
                    height: 130,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 234, 255, 253),
                      border: Border.all(color: Colors.black26, width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 13, 8, 15),
                          child: CachedNetworkImage(
                            width: 140,
                            fit: BoxFit.cover,
                            imageUrl:
                                "${MyConfig().server}/barterit/assets/itemImages/${widget.item.itmId}i.png?timestamp=${DateTime.now().millisecondsSinceEpoch}",
                            placeholder: (context, url) =>
                                const LinearProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 13, 8, 8),
                              child: Text(
                                truncateString(
                                    widget.item.itmName.toString(), 20),
                                style: GoogleFonts.lilitaOne(
                                  textStyle: const TextStyle(fontSize: 18),
                                  color: Colors.blueGrey.shade700,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                              child: Text(
                                "by $sellername",
                                style: const TextStyle(fontSize: 15),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                              child: Text(
                                "RM ${double.parse(widget.item.itmPrice.toString()).toStringAsFixed(2)}",
                                style: const TextStyle(fontSize: 15),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                              child: Text(
                                "${widget.orderqty.toString()} units",
                                style: const TextStyle(fontSize: 15),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 5, 18, 15),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Cost Summary",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 30),
                child: Container(
                  height: 165,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 234, 255, 253),
                    border: Border.all(color: Colors.black26, width: 1),
                  ),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(1),
                    },
                    children: [
                      TableRow(
                        children: [
                          const TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                'Subtotal',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                "RM ${double.parse(widget.total.toString()).toStringAsFixed(2)}",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const TableRow(
                        children: [
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                'Shipping Fee',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                'RM 6.00',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const TableCell(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(8, 8, 8, 15),
                              child: Text(
                                'Tax (6%)',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 15),
                              child: Text(
                                'RM${tax.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          TableCell(
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.black26,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.black26,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'RM${totalpaid.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  TextEditingController addressController =
                      TextEditingController();

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text(
                          "Please enter your delivery address",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: SingleChildScrollView(
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 300),
                            child: TextField(
                              controller: addressController,
                              maxLines: null,
                              decoration: const InputDecoration(
                                hintText: 'Enter your address',
                                labelText: 'Address',
                                labelStyle: TextStyle(),
                                icon: Icon(
                                  Icons.map,
                                  color: Colors.teal,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 2.0,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              address = addressController.text;
                              if (address != "") {
                                var items = [
                                  {
                                    "itemPrice": aftertax.toString(),
                                    "itemName": widget.item.itmName,
                                    "qty": widget.orderqty,
                                  },
                                ];

                                await StripeService.stripePaymentCheckout(
                                  items,
                                  totalpaid,
                                  6.00,
                                  context,
                                  mounted,
                                  onSuccess: (paymentIntent) {
                                    Navigator.of(context).pop();
                                    http.post(
                                        Uri.parse(
                                            "${MyConfig().server}/barterit/php/insertOrder.php"),
                                        body: {
                                          "receiptid": paymentIntent,
                                          "itemid":
                                              widget.item.itmId.toString(),
                                          "orderqty":
                                              widget.orderqty.toString(),
                                          "paid": totalpaid.toString(),
                                          "buyerid": widget.user.id.toString(),
                                          "sellerid":
                                              widget.item.itmOwnerId.toString(),
                                          "address": address,
                                        }).then((response) {
                                      var data = jsonDecode(response.body);
                                      if (response.statusCode == 200 &&
                                          data['status'] == "success") {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  15.0))),
                                              title: const Text(
                                                "Payment Successfully!",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              content: Text(
                                                  "Payment receipt: $paymentIntent"),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text(
                                                    "Done",
                                                    style: TextStyle(),
                                                  ),
                                                  onPressed: () async {
                                                    Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (content) =>
                                                                    MainPage(
                                                                      user: widget
                                                                          .user,
                                                                    )));
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        return;
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    "Payment Failed! Please try again.")));
                                        return;
                                      }
                                    });
                                  },
                                  onCancel: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (content) =>
                                                BuyerItemDetailsScreen(
                                                  itemdetails: widget.item,
                                                  user: widget.user,
                                                )));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Checkout Canceled"),
                                      ),
                                    );
                                  },
                                  onError: (e) {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (content) =>
                                                BuyerItemDetailsScreen(
                                                  itemdetails: widget.item,
                                                  user: widget.user,
                                                )));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text("Error! Please try again."),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Please ensure your delivery address no empty.")));
                              }
                            },
                            child: const Text(
                              "Submit",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ))
                        ],
                      );
                    },
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(120, 10, 120, 10),
                  child: Text(
                    "CHECK OUT",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  String truncateString(String str, int size) {
    if (str.length > size) {
      str = str.substring(0, size);
      return "$str...";
    } else {
      return str;
    }
  }

  loadSeller() async {
    var response = await http.post(
        Uri.parse("${MyConfig().server}/barterit/php/loadUserName.php"),
        body: {
          "sellerid": widget.item.itmOwnerId,
        });
    var jsonResponse = json.decode(response.body);

    if (response.statusCode == 200 && jsonResponse['status'] == "success") {
      setState(() {
        sellername = jsonResponse['data']['name'];
      });
    }
  }
}
