import 'dart:async';
import 'dart:convert';

import 'package:barterit_app/interfaces/login_screen.dart';
import 'package:barterit_app/interfaces/orderbuyer_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

import '../config_server.dart';
import '../models/item.dart';
import '../models/user.dart';
import 'itemdetails_screen.dart';
import 'menu.dart';

class MainPage extends StatefulWidget {
  final User user;
  MainPage({super.key, required this.user});

  final FocusNode focusNode = FocusNode();

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late double screenHeight, screenWidth, resWidth;
  late int axiscount = 2;
  bool isLoading = false;
  final scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  int cartqty = 0;

  int numofpage = 1, curpage = 1;
  int numberofresult = 0;

  GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();
  List<Item> itemlist = <Item>[];
  PageController pageController = PageController(viewportFraction: 0.3);

  @override
  void initState() {
    widget.focusNode.addListener(_onFocusChanged);
    super.initState();
    loadBuyerItem(1);
  }

  @override
  void dispose() {
    scrollController.dispose();
    widget.focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!widget.focusNode.hasFocus) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
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
      child: Scaffold(
        appBar: AppBar(
          title: const Text("BarterIt"),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: IconButton(
                icon: const Icon(
                  Icons.receipt,
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
                            builder: (content) => MyPurchsePage(
                                  user: widget.user,
                                )));
                  }
                },
              ),
            )
          ],
        ),
        drawer: MenuWidget(
          user: widget.user,
        ),
        body: RefreshIndicator(
          key: refreshKey,
          onRefresh: _refreshItems,
          child: Column(
            children: [
              Container(
                height: 100,
                color: const Color.fromARGB(255, 220, 245, 255),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black87),
                            color: Colors.white),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                                child: SizedBox(
                                  width: 500,
                                  child: TextField(
                                    controller: searchController,
                                    decoration: const InputDecoration(
                                      hintText: "Search",
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                clearText();
                              },
                              icon: const Icon(Icons.clear),
                              color: Colors.blueGrey,
                            ),
                            IconButton(
                              onPressed: () {
                                widget.focusNode.unfocus();
                                searchFeature(1);
                              },
                              icon: const Icon(Icons.search),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        searchController.text.isEmpty
                            ? "$numberofresult Items Showing..."
                            : itemlist.isNotEmpty
                                ? "$numberofresult Items Found"
                                : "0 item found",
                        style: GoogleFonts.eczar(
                          textStyle: const TextStyle(fontSize: 17),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : itemlist.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "No items available.",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 211, 47, 47),
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Please refresh the page or try again later.",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 15,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    clearText();
                                  },
                                  child: const Text("Refresh"),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: RawScrollbar(
                                  controller: scrollController,
                                  thumbColor: Colors.teal.shade200,
                                  thumbVisibility: true,
                                  child: GridView.count(
                                    controller: scrollController,
                                    crossAxisCount: axiscount,
                                    children: List.generate(
                                      itemlist.length,
                                      (index) {
                                        return Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Card(
                                            color: const Color.fromARGB(
                                                255, 255, 253, 244),
                                            child: InkWell(
                                              onTap: () async {
                                                _showItemDetails(index);
                                              },
                                              child: Column(
                                                children: [
                                                  Flexible(
                                                    flex: 6,
                                                    child: CachedNetworkImage(
                                                      width: 180,
                                                      fit: BoxFit.cover,
                                                      imageUrl:
                                                          "${MyConfig().server}/barterit/assets/itemImages/${itemlist[index].itmId}i.png",
                                                      placeholder: (context,
                                                              url) =>
                                                          const LinearProgressIndicator(),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const Icon(
                                                              Icons.error),
                                                    ),
                                                  ),
                                                  Flexible(
                                                    flex: 4,
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child: Text(
                                                            truncateString(
                                                                itemlist[index]
                                                                    .itmName
                                                                    .toString(),
                                                                15),
                                                            style: GoogleFonts
                                                                .lilitaOne(
                                                              textStyle:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          18),
                                                              color: Colors
                                                                  .blueGrey
                                                                  .shade700,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(1.0),
                                                          child: Text(
                                                            "RM ${double.parse(itemlist[index].itmPrice.toString()).toStringAsFixed(2)}",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        14),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(1.0),
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
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          14),
                                                                ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 50,
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          curpage = 1;
                                          widget.focusNode.unfocus();
                                          if (searchController
                                              .text.isNotEmpty) {
                                            searchFeature(1);
                                          } else {
                                            loadBuyerItem(1);
                                          }
                                        });
                                        pageController.jumpToPage(0);
                                      },
                                      icon: const Icon(Icons.first_page),
                                    ),
                                    Expanded(
                                      child: PageView.builder(
                                        itemCount: numofpage,
                                        controller: pageController,
                                        onPageChanged: (int index) {
                                          setState(() {
                                            curpage = index + 1;
                                            widget.focusNode.unfocus();
                                            if (searchController
                                                .text.isNotEmpty) {
                                              searchFeature(index + 1);
                                            } else {
                                              loadBuyerItem(index + 1);
                                            }
                                          });
                                        },
                                        itemBuilder: (context, index) {
                                          Color color = curpage - 1 == index
                                              ? Colors.teal
                                              : Colors.black54;

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  curpage = index + 1;
                                                  widget.focusNode.unfocus();
                                                  if (searchController
                                                      .text.isNotEmpty) {
                                                    searchFeature(index + 1);
                                                  } else {
                                                    loadBuyerItem(index + 1);
                                                  }
                                                });
                                              },
                                              child: Text(
                                                (index + 1).toString(),
                                                style: TextStyle(
                                                    color: color, fontSize: 18),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          curpage = numofpage;
                                          widget.focusNode.unfocus();
                                          if (searchController
                                              .text.isNotEmpty) {
                                            searchFeature(numofpage);
                                          } else {
                                            loadBuyerItem(numofpage);
                                          }
                                        });
                                        pageController
                                            .jumpToPage(numofpage - 1);
                                      },
                                      icon: const Icon(Icons.last_page),
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
    );
  }

  Future<void> _refreshItems() async {
    setState(() {
      isLoading = true;
    });
    refreshKey.currentState?.show(atTop: true);
    await Future.delayed(const Duration(seconds: 1));

    if (searchController.text.isNotEmpty) {
      searchFeature(curpage);
    } else {
      loadBuyerItem(curpage);
    }

    setState(() {
      isLoading = false;
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

  void searchFeature(int spage) {
    String search = searchController.text;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    Timer(const Duration(seconds: 1), () {
      if (search.isNotEmpty) {
        http.post(
            Uri.parse("${MyConfig().server}/barterit/php/loadBuyerItem.php"),
            body: {
              "search": search,
              "spage": spage.toString()
            }).then((response) {
          Navigator.pop(context);
          itemlist.clear();

          if (response.statusCode == 200) {
            var jsondata = jsonDecode(response.body);
            var itemdata = jsondata['data'];
            if (jsondata['status'] == 'success') {
              numofpage = jsondata['numofpage'];
              numberofresult = int.parse(jsondata['numberofresult']);

              if (itemdata['items'] != null) {
                itemdata['items'].forEach((v) {
                  itemlist.add(Item.fromJson(v));
                });
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("No items that relate to the keywords."),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Failed to connect to the server."),
              ),
            );
          }
          setState(() {});
        }).catchError((error) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("An error occurred while loading items."),
            ),
          );
        });
      } else {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                "Empty Search Field",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Text("Please enter a search keyword."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("CLOSE"),
                ),
              ],
            );
          },
        );
        loadBuyerItem(curpage);
      }
    });
  }

  void loadBuyerItem(int page) {
    http.post(Uri.parse("${MyConfig().server}/barterit/php/loadBuyerItem.php"),
        body: {
          "pageno": page.toString(),
        }).then((response) {
      itemlist.clear();
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);
        var itemdata = jsondata['data'];
        if (jsondata['status'] == 'success') {
          numofpage = jsondata['numofpage'];
          numberofresult = int.parse(jsondata['numberofresult']);
          if (itemdata['items'] != null) {
            itemdata['items'].forEach((v) {
              itemlist.add(Item.fromJson(v));
            });
          }
        }
      }
      if (itemlist.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("No items available for the given keyword.")));
      }
      setState(() {});
    });
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

  void clearText() {
    searchController.clear();
    loadBuyerItem(1);
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
