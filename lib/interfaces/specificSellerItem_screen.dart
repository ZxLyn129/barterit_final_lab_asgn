import 'dart:convert';
import 'dart:async';
import 'package:barterit_app/interfaces/itemdetails_screen.dart';
import 'package:barterit_app/models/item.dart';
import 'package:barterit_app/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../config_server.dart';

class SpecificSellerItemPage extends StatefulWidget {
  final User user;
  final Item item;
  const SpecificSellerItemPage(
      {super.key, required this.user, required this.item});

  @override
  State<SpecificSellerItemPage> createState() => _SpecificSellerItemPageState();
}

class _SpecificSellerItemPageState extends State<SpecificSellerItemPage> {
  late double screenHeight, screenWidth, resWidth;
  late int axiscount = 2;
  List<Item> itemlist = <Item>[];
  GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();
  var sellername = " ";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadItems();
      loadSeller();
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Seller "$sellername" Items'),
      ),
      body: RefreshIndicator(
          key: refreshKey,
          onRefresh: _refreshItems,
          child: itemlist.isEmpty
              ? Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Seller '$sellername' haven't added any items yet.",
                      style: const TextStyle(
                          color: Color.fromARGB(255, 211, 47, 47),
                          fontSize: 18),
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
                                  color:
                                      const Color.fromARGB(255, 255, 253, 244),
                                  child: InkWell(
                                    onTap: () {
                                      _showItemDetails(index);
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
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                      ),
                                      Flexible(
                                          flex: 4,
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(3.0),
                                                child: Text(
                                                  truncateString(
                                                      itemlist[index]
                                                          .itmName
                                                          .toString(),
                                                      15),
                                                  style: GoogleFonts.lilitaOne(
                                                    textStyle: const TextStyle(
                                                        fontSize: 20),
                                                    color: Colors
                                                        .blueGrey.shade700,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(1.0),
                                                child: Text(
                                                  "RM ${double.parse(itemlist[index].itmPrice.toString()).toStringAsFixed(2)}",
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(1.0),
                                                child: Text(
                                                  "${itemlist[index].itmQty} in stock",
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                            ],
                                          ))
                                    ]),
                                  ));
                            },
                          )))
                ])),
    );
  }

  Future<void> _refreshItems() async {
    refreshKey.currentState?.show(atTop: true);
    await Future.delayed(const Duration(seconds: 1));

    _loadItems();
  }

  String truncateString(String str, int size) {
    if (str.length > size) {
      str = str.substring(0, size);
      return "$str...";
    } else {
      return str;
    }
  }

  void _loadItems() {
    http.post(Uri.parse("${MyConfig().server}/barterit/php/loadSellerItem.php"),
        body: {
          "itm_owner_id": widget.item.itmOwnerId.toString(),
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
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("No Item Available.")));
      }
      setState(() {});
    });
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

  Future<void> _showItemDetails(int index) async {
    Item itemdetails = Item.fromJson(itemlist[index].toJson());
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    Timer(const Duration(seconds: 1), () async {
      Navigator.pop(context);
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (content) => BuyerItemDetailsScreen(
                    user: widget.user,
                    itemdetails: itemdetails,
                  )));
    });
  }
}
