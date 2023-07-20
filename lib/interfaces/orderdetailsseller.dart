import 'dart:convert';

import 'package:barterit_app/config_server.dart';
import 'package:barterit_app/interfaces/orderseller_screen.dart';
import 'package:barterit_app/models/orderdetails.dart';
import 'package:barterit_app/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class OrdersSellerDetailsPage extends StatefulWidget {
  final User user;
  final OrderDetails order;
  const OrdersSellerDetailsPage(
      {super.key, required this.order, required this.user});

  @override
  State<OrdersSellerDetailsPage> createState() =>
      _OrdersSellerDetailsPageState();
}

class _OrdersSellerDetailsPageState extends State<OrdersSellerDetailsPage> {
  late double screenHeight, screenWidth, resWidth;
  var tax = 0.00;
  var total = 0.00;
  final df = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void initState() {
    super.initState();
    calculate();
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
        title: const Text("Order Details"),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Container(
            height: 85,
            width: screenWidth,
            color: Colors.teal.shade100,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.playlist_add_check_circle,
                        size: 50,
                        color: Colors.grey.shade800,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order is ${widget.order.orderStatus}",
                            style: GoogleFonts.acme(
                              textStyle: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "The barter person has already paid for this order",
                            style: GoogleFonts.alegreyaSans(
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 10,
            color: Colors.grey.shade300,
          ),
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 25,
                        color: Colors.grey.shade800,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Delivery Address",
                        style: GoogleFonts.acme(
                          textStyle: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      widget.order.deliveryAddress ?? "No address provided",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 10,
            color: Colors.grey.shade300,
          ),
          Card(
            color: Colors.teal.shade50,
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.shopping_bag,
                        size: 25,
                        color: Colors.grey.shade800,
                      ),
                      const SizedBox(width: 20),
                      Text(
                        widget.order.buyerName.toString(),
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const Expanded(
                        child: Text(
                          "Bartered",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Container(
                      height: 2,
                      color: Colors.black38,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CachedNetworkImage(
                        width: 100,
                        fit: BoxFit.cover,
                        imageUrl:
                            "${MyConfig().server}/barterit/assets/itemImages/${widget.order.itemId}i.png",
                        placeholder: (context, url) =>
                            const LinearProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              truncateString(
                                  widget.order.itemName.toString(), 30),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "x ${widget.order.orderdetailQty}",
                                style: const TextStyle(fontSize: 13),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "RM ${double.parse(widget.order.itemPrice.toString()).toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(1),
                    },
                    children: [
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
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    SizedBox(height: 5),
                                    Text(
                                      'Subtotal',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
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
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 5),
                                      Text(
                                        "RM ${total.toStringAsFixed(2)}",
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
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
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Text(
                                  'RM 6.00',
                                  style: TextStyle(fontSize: 14),
                                ),
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
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 8, 8, 15),
                                child: Text(
                                  'RM${tax.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 14),
                                ),
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
                                  'Total Payment',
                                  style: TextStyle(
                                    fontSize: 16,
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
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'RM${double.parse(widget.order.orderdetailPaid.toString()).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
            child: Container(
              height: 10,
              color: Colors.grey.shade300,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(0.55),
                1: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  children: [
                    const TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Receipt ID',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "${widget.order.orderBill}",
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          'Order Time',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            df.format(DateTime.parse(
                                widget.order.orderdetailDate.toString())),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          'Payment Time',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            df.format(DateTime.parse(
                                widget.order.orderdetailDate.toString())),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          'Shipping Time',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            widget.order.orderShipDate.toString(),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          'Completed Time',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            widget.order.orderCompleteDate.toString(),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          widget.order.orderStatus == "Shipping" ||
                  widget.order.orderStatus == "Completed"
              ? Container()
              : ElevatedButton(
                  onPressed: () {
                    updateStatus();
                  },
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(125, 10, 125, 10),
                    child: Text(
                      "Ship Item",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
          const SizedBox(
            height: 10,
          ),
        ],
      )),
    );
  }

  void calculate() {
    setState(() {
      total = double.parse(widget.order.itemPrice.toString()) *
          int.parse(widget.order.orderdetailQty.toString());
      tax = total * 0.06;
    });
  }

  String truncateString(String str, int size) {
    if (str.length > size) {
      str = str.substring(0, size);
      return "$str...";
    } else {
      return str;
    }
  }

  void updateStatus() {
    try {
      DateTime now = DateTime.now();
      var date = DateFormat('yyyy-MM-dd HH:mm').format(now);
      http.post(
        Uri.parse("${MyConfig().server}/barterit/php/updateStatus.php"),
        body: {
          "sellerid": widget.user.id.toString(),
          "orderbill": widget.order.orderBill.toString(),
          "date": date,
        },
      ).then((response) {
        if (response.statusCode == 200) {
          var jsondata = jsonDecode(response.body);
          if (jsondata['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Update Status Success")),
            );
            setState(() {
              widget.order.orderStatus = 'Shipping';
              widget.order.orderShipDate = date;
            });
            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (content) => OrdersSellerPage(
                  user: widget.user,
                ),
              ),
            );
            return;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Update Status Failed")),
            );
            return;
          }
        }
      });
      setState(() {});
    } catch (e) {
      print("Error loading seller: $e");
    }
  }
}
