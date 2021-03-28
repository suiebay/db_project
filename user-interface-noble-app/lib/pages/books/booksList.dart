import 'dart:convert';
import 'dart:async';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:mds_reads/colors/floating_button_color.dart';
import 'package:mds_reads/pages/books/book_animation.dart';
import 'package:mds_reads/pages/books/book_main.dart';
import 'package:mds_reads/pages/books/books_add_dialog.dart';
import 'package:mds_reads/pages/books/books_information.dart';
import 'dart:io' show Platform;

import 'package:mds_reads/globals.dart' as globals;
import 'package:mds_reads/pages/error_page.dart';

class BooksList extends StatefulWidget {
  String fromCategory;

  BooksList ({ this.fromCategory });

  @override
  _BooksListState createState() => _BooksListState();
}

class _BooksListState extends State<BooksList> {
  List<BooksInformation> _searchResult = [];
  List<BooksInformation> _bookDetails = [];
  String filter = 'Title';
  TextEditingController controller = new TextEditingController();

  void refreshState(String token) {
    setState(() {
      getBookDetails(token);
    });
  }

  String url;

  dynamic getBookDetails(String token) async {
    Box box = Hive.box('config');
    if(widget.fromCategory == "Additional Books") {
      widget.fromCategory = "AdditionalBooks";
    }
    try {
      var response;
      var url;
      if (Platform.isAndroid) {
        url =
            '${box.get('url')}/api/project/mdsreads/books/list/${widget.fromCategory}/sortbytitle';
      } else if (Platform.isIOS) {
        url =
            '${box.get('url')}/api/project/mdsreads/books/list/${widget.fromCategory}/sortbytitle';
      }

      response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(Duration(seconds: globals.duration));

      String body = utf8.decode(response.bodyBytes);
      final responseJson = json.decode(body);
      setState(() {
        _bookDetails.clear();
        for (Map user in responseJson) {
          _bookDetails.add(BooksInformation.fromJson(user));
        }
        if (filter == 'Title') {
          _bookDetails.sort(
              (a, b) => a.title.toUpperCase().compareTo(b.title.toUpperCase()));
          _searchResult.sort(
              (a, b) => a.title.toUpperCase().compareTo(b.title.toUpperCase()));
        }
        if (filter == 'Author') {
          _bookDetails.sort((a, b) =>
              a.author.toUpperCase().compareTo(b.author.toUpperCase()));
          _searchResult.sort((a, b) =>
              a.author.toUpperCase().compareTo(b.author.toUpperCase()));
        }
        if (filter == 'Rating') {
          _bookDetails.sort((a, b) => b.rating.compareTo(a.rating));
          _searchResult.sort((a, b) => b.rating.compareTo(a.rating));
        }
        // if(filter == 'Category') {
        //   _bookDetails.sort((a, b) {
        //     var r = a.category.compareTo(b.category);
        //     if(r != 0) return r;
        //     return a.title.toUpperCase().compareTo(b.title.toUpperCase());
        //   });
        //   _searchResult.sort((a, b) {
        //     var r = a.category.compareTo(b.category);
        //     if(r != 0) return r;
        //     return a.title.toUpperCase().compareTo(b.title.toUpperCase());
        //   });
        // }
      });
    } on TimeoutException catch (_) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => ErrorPage(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getBookDetails(globals.accessTokenG);
  }

  int has = 0;

  @override
  Widget build(BuildContext context) {
    print(widget.fromCategory);
    return StatefulBuilder(builder: (context, setState) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color(0xFF213A8F),
          title: Text(
            'Books',
          ),
          actions: <Widget>[
            IconButton(
              icon: new Icon(Icons.filter_list),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(25.0)),
                    ),
                    builder: (BuildContext bc) {
                      return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 40),
                          height: MediaQuery.of(context).size.height * .2,
                          child: SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                InkWell(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      'SORT BY NAME',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontFamily: filter == 'Title'
                                              ? 'RobotoMedium'
                                              : 'RobotoLight'),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      filter = 'Title';
                                      has = 0;
                                      _bookDetails.sort((a, b) => a.title
                                          .toUpperCase()
                                          .compareTo(b.title.toUpperCase()));
                                      _searchResult.sort((a, b) => a.title
                                          .toUpperCase()
                                          .compareTo(b.title.toUpperCase()));
                                    });
                                  },
                                ),
                                SizedBox(height: 20),
                                InkWell(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      'SORT BY AUTHOR',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontFamily: filter == 'Author'
                                              ? 'RobotoMedium'
                                              : 'RobotoLight'),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      filter = 'Author';
                                      has = 0;
                                      _bookDetails.sort((a, b) => a.author
                                          .toUpperCase()
                                          .compareTo(b.author.toUpperCase()));
                                      _searchResult.sort((a, b) => a.author
                                          .toUpperCase()
                                          .compareTo(b.author.toUpperCase()));
                                    });
                                  },
                                ),
                                SizedBox(height: 20),
                                InkWell(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      'SORT BY RATING',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontFamily: filter == 'Rating'
                                              ? 'RobotoMedium'
                                              : 'RobotoLight'),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      filter = 'Rating';
                                      has = 0;
                                      _bookDetails.sort((a, b) =>
                                          b.rating.compareTo(a.rating));
                                      _searchResult.sort((a, b) =>
                                          b.rating.compareTo(a.rating));
                                    });
                                  },
                                ),
                                // SizedBox(height: 20),
                                // InkWell(
                                //   child: SizedBox(
                                //     width: double.infinity,
                                //     child: Text(
                                //       'SORT BY CATEGORY',
                                //       textAlign: TextAlign
                                //           .left,
                                //       style: TextStyle(
                                //           fontFamily: 'RobotoLight'
                                //       ),
                                //     ),
                                //   ),
                                //   onTap: () {
                                //     Navigator.pop(context);
                                //     setState(() {
                                //       filter = 'Category';
                                //       has = 0;
                                //       _bookDetails.sort((a, b) {
                                //           var r = a.category.compareTo(b.category);
                                //           if(r != 0) return r;
                                //           return a.title.toUpperCase().compareTo(b.title.toUpperCase());
                                //       });
                                //       _searchResult.sort((a, b) {
                                //         var r = a.category.compareTo(b.category);
                                //         if(r != 0) return r;
                                //         return a.title.toUpperCase().compareTo(b.title.toUpperCase());
                                //       });
                                //     });
                                //   },
                                // ),
                              ],
                            ),
                          ));
                    });
              },
            )
          ],
        ),
        body: Stack(
          children: <Widget>[
            Positioned(
              child: Container(
                height: 60,
                color: Colors.white,
                child: Card(
                  elevation: 2,
                  child: ListTile(
                      leading: new Icon(Icons.search),
                      title: new TextField(
                        controller: controller,
                        decoration: new InputDecoration(
                            hintText: 'Search', border: InputBorder.none),
                        onChanged: onSearchTextChanged,
                      ),
                      trailing: controller.text != ''
                          ? new IconButton(
                              icon: new Icon(Icons.cancel),
                              onPressed: () {
                                controller.clear();
                                onSearchTextChanged('');
                              },
                            )
                          : null),
                ),
                //color: Colors.red,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 60, bottom: 10),
              child: StatefulBuilder(builder: (context, setState) {
                return _searchResult.length != 0 || controller.text.isNotEmpty
                    ? ListView.builder(
                        itemCount: _searchResult.length,
                        itemBuilder: (context, index) {
                          return SafeArea(
                              child: InkWell(
                            onTap: () {
                              //Navigator.pushNamed(context, '/bookmain');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookMain(
                                      booksInformation: _searchResult[index]),
                                ),
                              ).then((value) {
                                //getBookDetails();
                                refreshState(globals.accessTokenG);
                              });
                            },
                            child: Column(
                              children: <Widget>[
                                Container(
                                    //margin: EdgeInsets.fromLTRB(8, 8, 8, 0),
                                    height: 90,
                                    //color: Colors.red,
                                    child: Stack(
                                      children: <Widget>[
                                        Positioned(
                                            left: 0,
                                            top: 0,
                                            child: Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    8, 4, 0, 4),
                                                color: Colors.transparent,
                                                child: _searchResult[index]
                                                            .getImgStorage() ==
                                                        null
                                                    ? Image(
                                                        height: 90,
                                                        width: 68,
                                                        fit: BoxFit.fitWidth,
                                                        image: AssetImage(
                                                            'assets/item_book.png'))
                                                    : FadeInImage(
                                                        height: 90,
                                                        width: 68,
                                                        placeholder: AssetImage(
                                                            'assets/item_book.png'),
                                                        image: NetworkImage(
                                                            _searchResult[index]
                                                                .getImgStorage())))),
                                        Positioned(
                                            left: 100,
                                            top: 10,
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Text(
                                                _searchResult[index].title,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontFamily: 'RobotoBold'),
                                              ),
                                            )),
                                        Positioned(
                                            left: 100,
                                            top: 35,
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Text(
                                                _searchResult[index].author,
                                                style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 15,
                                                    fontFamily: 'RobotoBold'),
                                              ),
                                            )),
                                        Positioned(
                                          left: 100,
                                          top: 60,
                                          child: RatingBarIndicator(
                                            rating: _searchResult[index].rating,
                                            itemBuilder: (context, index) =>
                                                Icon(
                                              Icons.star,
                                              color: Colors.amber[800],
                                            ),
                                            itemCount: 5,
                                            itemSize: 17.0,
                                            direction: Axis.horizontal,
                                          ),
                                        ),
                                        Positioned(
                                          left: 95,
                                          top: 82,
                                          right: 10,
                                          child: Divider(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                          ));
                        },
                      )
                    : ListView.builder(
                        itemCount: _bookDetails.length,
                        itemBuilder: (context, index) {
                          if (index >= 1 &&
                              _bookDetails[index].category !=
                                  _bookDetails[index - 1].category) {
                            has = 0;
                          }
                          if (index >= 1 &&
                              _bookDetails[index].category ==
                                  _bookDetails[index - 1].category) {
                            has = 1;
                          }
                          if (index == 0) {
                            has = 0;
                          }
                          return SafeArea(
                              child: Column(
                            children: <Widget>[
                              // filter == 'Category' && has == 0 ?
                              // Column(
                              //   children: <Widget>[
                              //     SizedBox(height: 15,),
                              //     SizedBox(
                              //       width: double.infinity,
                              //       child: Row(
                              //         children: <Widget>[
                              //           SizedBox(width: 10,),
                              //           Text(
                              //             _bookDetails[index].category,
                              //             style: TextStyle(
                              //               fontSize: 25,
                              //               fontFamily: "RobotoBold",
                              //               color: Colors.grey[600],
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //     ),
                              //
                              //     SizedBox(height: 10,),
                              //   ],
                              // ) : Container(),
                              InkWell(
                                onTap: () {
                                  //Navigator.pushNamed(context, '/bookmain');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookMain(
                                          booksInformation:
                                              _bookDetails[index]),
                                    ),
                                  ).then((value) {
                                    //getBookDetails();
                                    refreshState(globals.accessTokenG);
                                  });
                                },
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                        //margin: EdgeInsets.fromLTRB(8, 8, 8, 0),
                                        height: 90,
                                        //color: Colors.red,
                                        child: FadeIn(
                                          index.toDouble() * .25,
                                          Stack(
                                            children: <Widget>[
                                              Positioned(
                                                  left: 0,
                                                  top: 0,
                                                  child: Container(
                                                      margin: EdgeInsets.fromLTRB(
                                                          8, 4, 0, 4),
                                                      color: Colors.transparent,
                                                      child: _bookDetails[index]
                                                                  .getImgStorage() ==
                                                              null
                                                          ? Image(
                                                              height: 90,
                                                              width: 68,
                                                              fit: BoxFit
                                                                  .fitWidth,
                                                              image: AssetImage(
                                                                  'assets/item_book.png'))
                                                          : FadeInImage(
                                                              height: 90,
                                                              width: 68,
                                                              placeholder: AssetImage(
                                                                  'assets/item_book.png'),
                                                              image: NetworkImage(
                                                                  _bookDetails[
                                                                          index]
                                                                      .getImgStorage())))),
                                              Positioned(
                                                  left: 100,
                                                  top: 10,
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Text(
                                                      _bookDetails[index].title,
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontFamily:
                                                              'RobotoBold'),
                                                    ),
                                                  )),
                                              Positioned(
                                                  left: 100,
                                                  top: 35,
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Text(
                                                      _bookDetails[index]
                                                          .author,
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 15,
                                                          fontFamily:
                                                              'RobotoBold'),
                                                    ),
                                                  )),
                                              Positioned(
                                                left: 100,
                                                top: 60,
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      100,
                                                  child: Row(
                                                    children: <Widget>[
                                                      RatingBarIndicator(
                                                        rating:
                                                            _bookDetails[index]
                                                                .rating,
                                                        itemBuilder:
                                                            (context, index) =>
                                                                Icon(
                                                          Icons.star,
                                                          color:
                                                              Colors.amber[800],
                                                        ),
                                                        itemCount: 5,
                                                        itemSize: 17.0,
                                                        direction:
                                                            Axis.horizontal,
                                                      ),
                                                      Spacer(),
                                                      // Text(
                                                      //   _bookDetails[index].category,
                                                      //   style: TextStyle(
                                                      //     fontSize: 13,
                                                      //     fontFamily: 'RobotoRegular',
                                                      //   ),
                                                      // ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 95,
                                                top: 82,
                                                right: 10,
                                                child: Divider(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ));
                        },
                      );
              }),
            ),
          ],
        ),
        floatingActionButton: globals.isAdmin == 1
            ? FloatingActionButton(
                child: Icon(Icons.add),
                backgroundColor: floatingButtonColor,
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => BooksAddDialog(null)))
                      .then((value) {
                    getBookDetails(globals.accessTokenG);
                  });
                })
            : Container(),
      );
    });
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    _searchResult = _bookDetails
        .where((element) =>
            element.title.toUpperCase().contains(text.toUpperCase()) ||
            element.author.toUpperCase().contains(text.toUpperCase()))
        .toList();

    setState(() {});
  }
}
