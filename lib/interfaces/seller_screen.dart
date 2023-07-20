import 'dart:convert';

import 'package:barterit_app/interfaces/main_screen.dart';
import 'package:barterit_app/interfaces/orderseller_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../config_server.dart';
import '../models/item.dart';
import '../models/user.dart';
import 'addproduct_screen.dart';
import 'login_screen.dart';
import 'menu.dart';
import 'updateproduct_screen.dart';

class SellerScreen extends StatefulWidget {
  final User user;
  const SellerScreen({super.key, required this.user});

  @override
  State<SellerScreen> createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen> {
  late double screenHeight, screenWidth, resWidth;
  late int axiscount = 2;
  List<Item> itemlist = <Item>[];
  GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadItems();
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
      axiscount = 2;
    } else {
      resWidth = screenWidth * 0.75;
      axiscount = 3;
      screenHeight = 1080;
    }
    return WillPopScope(
      onWillPop: () async => false,
      child: Builder(builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Sell Item Listing"),
            actions: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: IconButton(
                  icon: const Icon(
                    Icons.list_alt,
                    size: 28,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (widget.user.name == "guest") {
                      showLoginDialog();
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (content) => OrdersSellerPage(
                                    user: widget.user,
                                  )));
                    }
                  },
                ),
              )
            ],
          ),
          body: RefreshIndicator(
              key: refreshKey,
              onRefresh: _refreshItems,
              child: itemlist.isEmpty
                  ? Center(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "You haven't added any items yet. ",
                          style: TextStyle(
                              color: Color.fromARGB(255, 211, 47, 47),
                              fontSize: 20),
                        ),
                        Text(
                          "Please press the add button on your right bottom.",
                          style: TextStyle(color: Colors.black54, fontSize: 15),
                        ),
                      ],
                    ))
                  : Column(children: [
                      Container(
                        height: 25,
                        color: Colors.tealAccent.shade100,
                        alignment: Alignment.center,
                        child: Text(
                          "${itemlist.length} Items Found",
                          style: GoogleFonts.eczar(
                            textStyle: const TextStyle(fontSize: 17),
                          ),
                        ),
                      ),
                      const Padding(padding: EdgeInsets.all(3.0)),
                      Expanded(
                          child: GridView.count(
                              crossAxisCount: axiscount,
                              children: List.generate(
                                itemlist.length,
                                (index) {
                                  return Card(
                                      color: const Color.fromARGB(
                                          255, 255, 253, 244),
                                      child: InkWell(
                                        onTap: () {
                                          updateItemDetails(index);
                                        },
                                        onLongPress: () {
                                          deleteDialog(index);
                                        },
                                        child: Column(children: [
                                          Flexible(
                                            flex: 6,
                                            child: CachedNetworkImage(
                                              width: 180,
                                              fit: BoxFit.cover,
                                              imageUrl:
                                                  "${MyConfig().server}/barterit/assets/itemImages/${itemlist[index].itmId}i.png?timestamp=${DateTime.now().millisecondsSinceEpoch}",
                                              placeholder: (context, url) =>
                                                  const LinearProgressIndicator(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                            ),
                                          ),
                                          Flexible(
                                              flex: 4,
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            3.0),
                                                    child: Text(
                                                      truncateString(
                                                          itemlist[index]
                                                              .itmName
                                                              .toString(),
                                                          15),
                                                      style:
                                                          GoogleFonts.lilitaOne(
                                                        textStyle:
                                                            const TextStyle(
                                                                fontSize: 20),
                                                        color: Colors
                                                            .blueGrey.shade700,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            1.0),
                                                    child: Text(
                                                      "RM ${double.parse(itemlist[index].itmPrice.toString()).toStringAsFixed(2)}",
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            1.0),
                                                    child: itemlist[index]
                                                                .itmQty ==
                                                            '0'
                                                        ? Text(
                                                            "Out of Stock",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .orange
                                                                    .shade900),
                                                          )
                                                        : Text(
                                                            "${itemlist[index].itmQty} in stock",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        14),
                                                          ),
                                                  ),
                                                ],
                                              ))
                                        ]),
                                      ));
                                },
                              )))
                    ])),
          drawer: MenuWidget(
            user: widget.user,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (content) => AddProductScreen(
                            user: widget.user,
                          )));
              _loadItems();
            },
            child: const Icon(Icons.add),
          ),
        );
      }),
    );
  }

  Future<void> _refreshItems() async {
    refreshKey.currentState?.show(atTop: true);
    await Future.delayed(const Duration(seconds: 1));

    _loadItems();
  }

  void _loadItems() {
    if (widget.user.name.toString() != "guest" &&
        widget.user.id.toString() != '0') {
      http.post(
          Uri.parse("${MyConfig().server}/barterit/php/loadSellerItem.php"),
          body: {
            "itm_owner_id": widget.user.id.toString(),
          }).then((response) {
        itemlist.clear();
        var jsondata = jsonDecode(response.body);
        if (response.statusCode == 200 && jsondata['status'] == 'success') {
          var itemdata = jsondata['data'];
          if (itemdata['items'] != null) {
            itemdata['items'].forEach((v) {
              itemlist.add(Item.fromJson(v));
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No Item Available.")));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No Item Available.")));
        }
        setState(() {});
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            title: const Text(
              "Want to selling things?",
              style: TextStyle(),
            ),
            content: const Text("Please login / register an account first",
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
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (content) => MainPage(user: widget.user)));
                },
              ),
            ],
          );
        },
      );
      return;
    }
  }

  String truncateString(String str, int size) {
    if (str.length > size) {
      str = str.substring(0, size);
      return "$str...";
    } else {
      return str;
    }
  }

  void deleteDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(
              "Delete ${truncateString(itemlist[index].itmName.toString(), 15)}",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("Are you sure?", style: TextStyle(fontSize: 18)),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                deleteItem(index);
                Navigator.of(context).pop();
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

  void deleteItem(int index) {
    Future.delayed(Duration.zero, () {
      http.post(Uri.parse("${MyConfig().server}/barterit/php/deleteItem.php"),
          body: {
            "owner_id": widget.user.id,
            "itmid": itemlist[index].itmId,
          }).then((response) {
        if (response.statusCode == 200) {
          var jsondata = jsonDecode(response.body);
          if (jsondata['status'] == "success") {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Delete Item Success")));
            _loadItems();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Failed to Delete Item")));
          }
        }
      });
    });
  }

  Future<void> updateItemDetails(int index) async {
    Item item = Item.fromJson(itemlist[index].toJson());

    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (content) => UpdateDetailsScreen(
                  item: item,
                  user: widget.user,
                )));
    _loadItems();
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
