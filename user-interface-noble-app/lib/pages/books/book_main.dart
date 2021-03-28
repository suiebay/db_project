import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:mds_reads/pages/books/books_add_dialog.dart';
import 'package:mds_reads/pages/books/books_information.dart';
import 'package:http/http.dart' as http;
import 'package:mds_reads/pages/error_page.dart';
import 'package:mds_reads/pages/quiz/presentation/quiz_view.dart';
import 'package:mds_reads/pages/user/profile_details.dart';
import 'dart:io' show Platform;

import 'package:mds_reads/pages/user/user_page.dart';
import 'package:mds_reads/widgets/popupmenu_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mds_reads/globals.dart' as globals;

Future<http.Response> startReading(
    String bookId, String profileId, String token) async {
  Box box = Hive.box('config');
  var url = '${box.get('url')}/api/project/mdsreads/userbook/new';

  Map data = {
    'id': null,
    'bookId': bookId,
    'profileId': profileId,
    'endDate': null,
    'bookReview': null,
    'bookRating': 0,
    'gotPoint': 0
  };
  //encode Map to JSON
  var body = json.encode(data);

  var response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    },
    body: body,
  );

  return response;
}

Future<http.Response> repeatUserBook(
    String profileId, String bookId, String token) async {
  Box box = Hive.box('config');
  var url;
  if (Platform.isAndroid)
    url = '${box.get('url')}/api/project/mdsreads/userbook/getrepeat';
  else if (Platform.isIOS)
    url = '${box.get('url')}/api/project/mdsreads/userbook/getrepeat';

  Map data = {'profileId': profileId, 'bookId': bookId};
  //encode Map to JSON
  var body = json.encode(data);

  var response = await http.post(url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token'
      },
      body: body);

  return response;
}

ProfileDetails parseProfileDetails(String responseBody) {
  Map something = jsonDecode(responseBody);
  var somesome = ProfileDetails.fromJson(something);

  return somesome;
}

Future<http.Response> deleteRequest(String id, String token) async {
  Box box = Hive.box('config');
  var url;
  if (Platform.isAndroid)
    url = '${box.get('url')}/api/project/mdsreads/books/delete/$id';
  else if (Platform.isIOS)
    url = '${box.get('url')}/api/project/mdsreads/books/delete/$id';

  final http.Response response = await http.delete(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token'
    },
  );

  return response;
}

// ignore: must_be_immutable
class BookMain extends StatefulWidget {
  BooksInformation booksInformation;

  BookMain({this.booksInformation});

  @override
  _BookMainState createState() => _BookMainState();
}

getStringValuesSF(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String stringValue = prefs.getString(key);
  return stringValue;
}

class _BookMainState extends State<BookMain>
    with SingleTickerProviderStateMixin {
  var status;
  var ans;
  var ansReader;
  var ansReader2;
  TabController _controller;

//  BooksInformation _searchResult;
  BooksInformation _bookDetail;

  Map isClosedMap = Map<String, bool>();
  Map gotData = Map<String, bool>();

  Future<BooksInformation> getBookDetails(String id, String token) async {
    Box box = Hive.box('config');
    var response;
    var url = '${box.get('url')}/api/project/mdsreads/books/get/$id';

    response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token'
      },
    );

    String body = utf8.decode(response.bodyBytes);
    final responseJson = json.decode(body);

    _bookDetail = BooksInformation.fromJson(responseJson);

    return _bookDetail;
  }

  @override
  void initState() {
    super.initState();
    //getBookDetails(widget.booksInformation.bookId);
    _controller = new TabController(length: 4, vsync: this);
  }

  dynamic getMyProfile(http.Client client, String token) async {
    Box box = Hive.box('config');
    try {
      var url;
      if (Platform.isAndroid) {
        url = '${box.get('url')}/api/myprofile';
      } else if (Platform.isIOS) {
        url = '${box.get('url')}/api/myprofile';
      }

      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: globals.duration));

      return response;
    } on TimeoutException catch (_) {
      return 1;
    }
  }

  Future<http.Response> getUsersDetails(
      http.Client client, String id, String token) async {
    Box box = Hive.box('config');
    var url;
    if (Platform.isAndroid) {
      url = '${box.get('url')}/api/profiles/$id';
    } else if (Platform.isIOS) {
      url = '${box.get('url')}/api/profiles/$id';
    }

    final http.Response response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    return response;
  }

  Future<http.Response> getByIdUserBook(
      http.Client client, String id, String token) async {
    Box box = Hive.box('config');
    var url;
    if (Platform.isAndroid) {
      url =
          '${box.get('url')}/api/project/mdsreads/userbook/getbyuser/$id';
    } else if (Platform.isIOS) {
      url =
          '${box.get('url')}/api/project/mdsreads/userbook/getbyuser/$id';
    }

    final http.Response response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    return response;
  }

  Future<http.Response> getReadingUsers(
      http.Client client, String id, String token) async {
    Box box = Hive.box('config');
    var url;
    if (Platform.isAndroid) {
      url =
          '${box.get('url')}/api/project/mdsreads/userbook/readingslist/$id';
    } else if (Platform.isIOS) {
      url =
          '${box.get('url')}/api/project/mdsreads/userbook/readingslist/$id';
    }

    final http.Response response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    return response;
  }

  Future<http.Response> getFinishedUsers(
      http.Client client, String id, String token) async {
    Box box = Hive.box('config');
    var url;
    if (Platform.isAndroid) {
      url =
          '${box.get('url')}/api/project/mdsreads/userbook/finishedlist/$id';
    } else if (Platform.isIOS) {
      url =
          '${box.get('url')}/api/project/mdsreads/userbook/finishedlist/$id';
    }

    final http.Response response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: getMyProfile(http.Client(), globals.accessTokenG),
        builder: (context, userdata) {
          if (userdata.hasData && userdata.data != 1) {
            String body = utf8.decode(userdata.data.bodyBytes);
            ans = parseProfileDetails(body);
            return FutureBuilder<BooksInformation>(
                future: getBookDetails(
                    widget.booksInformation.bookId, globals.accessTokenG),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Scaffold(
                      appBar: AppBar(
                        elevation: 0,
                        title: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(snapshot.data.title)),
                        backgroundColor: Color(0xFF213A8F),
                        actions: <Widget>[
                          globals.isAdmin == 1
                              ? PopupMenuButton<int>(
                                  icon: IconTheme(
                                    data: new IconThemeData(
                                        color: Colors.white, size: 20),
                                    child: new Icon(Icons.more_vert),
                                  ),
                                  itemBuilder: (context) => [
                                    editPopUpMenuItem(),
                                    deletePopUpMenuItem(),
                                  ],
                                  offset: Offset(0, 40),
                                  onSelected: (value) {
                                    if (value == 1) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BooksAddDialog(snapshot.data),
                                        ),
                                      ).then((value) {
                                        setState(() {
                                          getBookDetails(snapshot.data.bookId,
                                              globals.accessTokenG);
                                        });
                                      });
                                    }
                                    if (value == 2) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) { return AlertDialog(
                                          title: SizedBox(
                                            width: double.infinity,
                                            child: Text(
                                              'Are you sure to delete this book?',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontFamily: 'RobotoBold',
                                                  color: Colors.grey[700]),
                                            ),
                                          ),
                                          content: Container(
                                              //color: Colors.red,
                                              height: 158,
                                              child: Column(
                                                children: <Widget>[
                                                  Card(
                                                    child:
                                                        Row(children: <Widget>[
                                                      Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 15,
                                                                vertical: 10),
                                                        height: 100,
                                                        color:
                                                            Colors.transparent,
                                                        child: snapshot.data
                                                                    .imgStorage !=
                                                                null
                                                            ? Image.network(
                                                                snapshot.data
                                                                    .imgStorage)
                                                            : Image.asset(
                                                                'assets/item_book.png'),
                                                      ),
                                                      Column(
                                                        children: <Widget>[
                                                          SizedBox(
                                                            width: 125,
                                                            child: Text(
                                                              snapshot
                                                                  .data.title,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontFamily:
                                                                      'RobotoBold'),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          SizedBox(
                                                            width: 125,
                                                            child: Text(
                                                              snapshot
                                                                  .data.author,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontFamily:
                                                                      'RobotoBold',
                                                                  color: Colors
                                                                          .grey[
                                                                      600]),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 30,
                                                          ),
                                                        ],
                                                      )
                                                    ]),
                                                    elevation: 3,
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      Container(
                                                        color:
                                                            Color(0xFFea2937),
                                                        width: 100,
                                                        height: 40,
                                                        child: FlatButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text(
                                                            'NO',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontFamily:
                                                                    'RobotoMedium'),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 45.0),
                                                      Container(
                                                        color:
                                                            Color(0xFF213a8f),
                                                        height: 40,
                                                        width: 100,
                                                        child: FlatButton(
                                                          onPressed: () async {
                                                            status =
                                                                await deleteRequest(
                                                                    snapshot
                                                                        .data
                                                                        .bookId,
                                                                    globals
                                                                        .accessTokenG);
                                                            if (status
                                                                    .statusCode ==
                                                                200) {
                                                              Navigator.pop(
                                                                  context);
                                                              Navigator.pop(
                                                                  context);
                                                              Fluttertoast
                                                                  .showToast(
                                                                msg:
                                                                    'Book deleted',
                                                                toastLength: Toast
                                                                    .LENGTH_SHORT,
                                                                gravity:
                                                                    ToastGravity
                                                                        .BOTTOM,
                                                              );
                                                              setState(() {});
                                                            }
                                                          },
                                                          child: Text(
                                                            'YES',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontFamily:
                                                                    'RobotoMedium'),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )),
                                        );}
                                      );
                                    }
                                  },
                                )
                              : Container(),
                        ],
                      ),
                      body: Scaffold(
                          backgroundColor: Color(0xFF6F6F7),
                          body: DefaultTabController(
                            length: 4,
                            child: NestedScrollView(
                              headerSliverBuilder: (BuildContext context,
                                  bool innerBoxIsScrolled) {
                                return <Widget>[
                                  SliverAppBar(
                                    backgroundColor: Color(0xFF213A8F),
                                    automaticallyImplyLeading: false,
                                    expandedHeight: 220.0,
                                    flexibleSpace: FlexibleSpaceBar(
                                        background: Column(
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    8, 4, 0, 4),
                                                color: Colors.transparent,
                                                child: Image(
                                                    height: 150,
                                                    width: 90,
                                                    fit: BoxFit.fitWidth,
                                                    image: snapshot.data
                                                                .getImgStorage() ==
                                                            null
                                                        ? AssetImage(
                                                            'assets/item_book.png')
                                                        : NetworkImage(_bookDetail
                                                            .getImgStorage()))),
                                            SizedBox(
                                              width: 15,
                                            ),
                                            Column(
                                              children: <Widget>[
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                SizedBox(
                                                  height: 30,
                                                  width: 250,
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Text(
                                                      snapshot.data.title,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 20,
                                                          fontFamily:
                                                              'RobotoBold'),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 25,
                                                  width: 250,
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Text(
                                                      snapshot.data.author,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontFamily:
                                                              'RobotoRegular'),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 25,
                                                  width: 250,
                                                  child: Text(
                                                    'Page: ${snapshot.data.pageNumber}',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontFamily:
                                                            'RobotoRegular'),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 250,
                                                  child: Row(children: <Widget>[
                                                    Text(
                                                      'Rating: ',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontFamily:
                                                              'RobotoRegular'),
                                                    ),
                                                    RatingBarIndicator(
                                                      rating:
                                                          snapshot.data.rating,
                                                      itemBuilder:
                                                          (context, index) =>
                                                              Icon(
                                                        Icons.star,
                                                        color:
                                                            Colors.amber[800],
                                                      ),
                                                      itemCount: 5,
                                                      itemSize: 18.0,
                                                      direction:
                                                          Axis.horizontal,
                                                    ),


                                                  ]),
                                                ),
                                                SizedBox(height: 6,),
                                                SizedBox(
                                                  height: 30,
                                                  width: 250,
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                    Axis.horizontal,
                                                    child: Text(
                                                      "Deadline : ${snapshot.data.pageDeadline.toString()} days",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontFamily:
                                                          'RobotoRegular'),
                                                    ),
                                                  ),
                                                ),
                                              ],

                                            ),
                                            // InkWell(
                                            //   onTap: () {
                                            //     Navigator.push(
                                            //       context,
                                            //       MaterialPageRoute(
                                            //         builder: (context) => QuizView(bookData: snapshot.data),
                                            //       ),
                                            //     );
                                            //   },
                                            //   child: Container(
                                            //     height: 50,
                                            //     width: 12,
                                            //     color: Colors.red,
                                            //   ),
                                            // )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 50,
                                          width: 350,
                                          child: FutureBuilder(
                                              future: getByIdUserBook(
                                                  http.Client(),
                                                  ans.userId,
                                                  globals.accessTokenG),
                                              builder: (context, userBook) {
                                                if (userBook.hasData) {
                                                  return FlatButton(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30.0)),
                                                    color: Color(0xFFf78d5d),
                                                    onPressed: () async {
                                                      var x = userBook.data;
                                                      if (x.body == "null") {
                                                        Map<String, dynamic>
                                                            getData;
                                                        var y = await repeatUserBook(
                                                            ans.userId,
                                                            widget
                                                                .booksInformation
                                                                .bookId,
                                                            globals
                                                                .accessTokenG);
                                                        getData =
                                                            json.decode(y.body);
                                                        if (getData['status'] ==
                                                            1) {
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) { return AlertDialog(
                                                              title: SizedBox(
                                                                width: double
                                                                    .infinity,
                                                                child: Text(
                                                                  'Are you sure to read this book?',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                      fontFamily:
                                                                          'RobotoBold',
                                                                      color: Colors
                                                                              .grey[
                                                                          700]),
                                                                ),
                                                              ),
                                                              content: Container(
                                                                  //color: Colors.red,
                                                                  height: 158,
                                                                  child: Column(
                                                                    children: <
                                                                        Widget>[
                                                                      Card(
                                                                        child: Row(
                                                                            children: <Widget>[
                                                                              Container(
                                                                                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                                                                height: 100,
                                                                                color: Colors.transparent,
                                                                                child: snapshot.data.imgStorage != null ? Image.network(snapshot.data.imgStorage) : Image.asset('assets/item_book.png'),
                                                                              ),
                                                                              Column(
                                                                                children: <Widget>[
                                                                                  SizedBox(
                                                                                    width: 125,
                                                                                    child: Text(
                                                                                      snapshot.data.title,
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                      textAlign: TextAlign.left,
                                                                                      style: TextStyle(fontSize: 15, fontFamily: 'RobotoBold'),
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 10,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 125,
                                                                                    child: Text(
                                                                                      snapshot.data.author,
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                      textAlign: TextAlign.left,
                                                                                      style: TextStyle(fontSize: 15, fontFamily: 'RobotoBold', color: Colors.grey[600]),
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 30,
                                                                                  ),
                                                                                ],
                                                                              )
                                                                            ]),
                                                                        elevation:
                                                                            3,
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Row(
                                                                        children: <
                                                                            Widget>[
                                                                          Container(
                                                                            color:
                                                                                Color(0xFFea2937),
                                                                            width:
                                                                                100,
                                                                            height:
                                                                                40,
                                                                            child:
                                                                                FlatButton(
                                                                              onPressed: () {
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: Text(
                                                                                'NO',
                                                                                style: TextStyle(color: Colors.white, fontFamily: 'RobotoMedium'),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              width: 45.0),
                                                                          Container(
                                                                            color:
                                                                                Color(0xFF213a8f),
                                                                            height:
                                                                                40,
                                                                            width:
                                                                                100,
                                                                            child:
                                                                                FlatButton(
                                                                              onPressed: () async {
                                                                                status = await startReading(snapshot.data.bookId, ans.userId, globals.accessTokenG);
                                                                                if (status.statusCode == 200) {
                                                                                  Navigator.pop(context);
                                                                                  Fluttertoast.showToast(
                                                                                    msg: 'Book added to your library',
                                                                                    toastLength: Toast.LENGTH_SHORT,
                                                                                    gravity: ToastGravity.BOTTOM,
                                                                                  );
                                                                                  setState(() {});
                                                                                }
                                                                              },
                                                                              child: Text(
                                                                                'YES',
                                                                                style: TextStyle(color: Colors.white, fontFamily: 'RobotoMedium'),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  )),
                                                            );}
                                                          );
                                                        } else {
                                                          Fluttertoast
                                                              .showToast(
                                                            msg:
                                                                'You already read this book!',
                                                            toastLength: Toast
                                                                .LENGTH_SHORT,
                                                            gravity:
                                                                ToastGravity
                                                                    .BOTTOM,
                                                          );
                                                        }
                                                      } else {
                                                        Fluttertoast.showToast(
                                                          msg:
                                                              'You already have reading book!',
                                                          toastLength: Toast
                                                              .LENGTH_SHORT,
                                                          gravity: ToastGravity
                                                              .BOTTOM,
                                                        );
                                                      }
                                                    },
                                                    child: Text(
                                                      'READ',
                                                      style: TextStyle(
                                                          fontSize: 17,
                                                          fontFamily:
                                                              'RobotoBold',
                                                          color: Colors.white),
                                                    ),
                                                  );
                                                } else {
                                                  return Center(
                                                      child: SpinKitCircle(
                                                    color: Colors.white,
                                                    size: 40,
                                                  ));
                                                }
                                              }),
                                        ),
                                      ],
                                    )),
                                  ),
                                  SliverPersistentHeader(
                                    delegate: _SliverAppBarDelegate(
                                      TabBar(
                                        controller: _controller,
                                        labelColor: Color(0xFF213A8F),
                                        indicatorWeight: 4,
                                        indicatorColor: Color(0xFF213A8F),
                                        unselectedLabelColor: Colors.grey,
                                        tabs: [
                                          Tab(
                                            icon: Icon(Icons.book,
                                                color: Color(0xFF213A8F)),
                                            child: Text(
                                              'Description',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontFamily: 'RobotoBold'),
                                            ),
                                          ),
                                          Tab(
                                            icon: Icon(Icons.receipt,
                                                color: Color(0xFF213A8F)),
                                            child: Text(
                                              'Reading',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontFamily: 'RobotoBold'),
                                            ),
                                          ),
                                          Tab(
                                            icon: Icon(Icons.cloud_done,
                                                color: Color(0xFF213A8F)),
                                            child: Text(
                                              'Already read',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontFamily: 'RobotoBold'),
                                            ),
                                          ),
                                          Tab(
                                            icon: Icon(Icons.rate_review,
                                                color: Color(0xFF213A8F)),
                                            child: Text(
                                              'Reviews',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontFamily: 'RobotoBold'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    pinned: true,
                                  ),
                                ];
                              },
                              body: TabBarView(
                                controller: _controller,
                                children: [
                                  Container(
                                    margin: EdgeInsets.fromLTRB(20, 30, 20, 30),
                                    child: Text(
                                      snapshot.data.description,
                                      style: TextStyle(
                                          fontFamily: 'RobotoBold',
                                          color: Colors.grey[700],
                                          fontSize: 14),
                                    ),
                                  ),
                                  FutureBuilder(
                                      future: getReadingUsers(
                                          http.Client(),
                                          widget.booksInformation.bookId,
                                          globals.accessTokenG),
                                      builder: (context, bookReaders) {
                                        if (bookReaders.hasData) {
                                          String readersBody = utf8.decode(
                                              bookReaders.data.bodyBytes);
                                          dynamic readingsList =
                                              jsonDecode(readersBody);
                                          return readingsList.length != 0
                                              ? ListView.builder(
                                                  itemCount:
                                                      readingsList.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return readingsList[index] != null ? FutureBuilder<
                                                            http.Response>(
                                                        future: getUsersDetails(
                                                            http.Client(),
                                                            readingsList[index]
                                                                ['profileId'],
                                                            globals
                                                                .accessTokenG),
                                                        builder: (context,
                                                            userInform) {
                                                          if (userInform
                                                              .hasData && userInform.data.body != "null") {
                                                            String bodyReader =
                                                                utf8.decode(
                                                                    userInform
                                                                        .data
                                                                        .bodyBytes);
                                                          if(bodyReader != null) {
                                                            dynamic ansans =
                                                                json.decode(
                                                                    bodyReader);
                                                              ansans['firstName'] =
                                                              ansans['firstName'] ==
                                                                  null
                                                                  ? ''
                                                                  : '${ansans['firstName']}';
                                                              ansans['lastName'] =
                                                              ansans['lastName'] ==
                                                                  null
                                                                  ? ''
                                                                  : ' ${ansans['lastName']}';
                                                              ansans['middleName'] =
                                                              ansans['middleName'] ==
                                                                  null
                                                                  ? ''
                                                                  : ' ${ansans['middleName']}';
                                                              ansans[
                                                              'email'] = ansans[
                                                              'email'] ==
                                                                  null
                                                                  ? ''
                                                                  : '${ansans['email']}';
                                                              ansans[
                                                              'phone'] = ansans[
                                                              'phone'] ==
                                                                  null
                                                                  ? ''
                                                                  : '${ansans['phone']}';
                                                              return SafeArea(
                                                                  child:
                                                                  Container(
                                                                    width:
                                                                    MediaQuery
                                                                        .of(
                                                                        context)
                                                                        .size
                                                                        .width,
                                                                    child: Card(
                                                                      elevation: 1,
                                                                      child: InkWell(
                                                                        onTap: () {
                                                                          Navigator
                                                                              .pushReplacement(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder:
                                                                                  (
                                                                                  context) =>
                                                                                  UserPage(
                                                                                      profileDetails: ansans),
                                                                            ),
                                                                          );
                                                                        },
                                                                        child: Row(
                                                                          children: <
                                                                              Widget>[
                                                                            Padding(
                                                                              padding: const EdgeInsets
                                                                                  .symmetric(
                                                                                  horizontal:
                                                                                  12,
                                                                                  vertical:
                                                                                  10),
                                                                              child:
                                                                              CircleAvatar(
                                                                                backgroundColor:
                                                                                Colors
                                                                                    .transparent,
                                                                                backgroundImage: ansans['avatar'] !=
                                                                                    null &&
                                                                                    ansans['avatar'] !=
                                                                                        '' &&
                                                                                    (ansans['gender'] ==
                                                                                        globals
                                                                                            .gender ||
                                                                                        globals
                                                                                            .isAdmin ==
                                                                                            1)
                                                                                    ? NetworkImage(
                                                                                    ansans['avatar'])
                                                                                    : ansans['gender'] ==
                                                                                    1
                                                                                    ? AssetImage(
                                                                                    'assets/profile_boy.png')
                                                                                    : AssetImage(
                                                                                    'assets/profile_girl.png'),
                                                                                radius:
                                                                                27,
                                                                              ),
                                                                            ),
                                                                            Column(
                                                                              children: <
                                                                                  Widget>[
                                                                                SizedBox(
                                                                                  width:
                                                                                  MediaQuery
                                                                                      .of(
                                                                                      context)
                                                                                      .size
                                                                                      .width -
                                                                                      95,
                                                                                  child:
                                                                                  Text(
                                                                                    '${ansans['firstName']} '
                                                                                        '${ansans['lastName']} '
                                                                                        '${ansans['middleName']}',
                                                                                    style: TextStyle(
                                                                                        fontFamily: 'RobotoBold',
                                                                                        color: Colors
                                                                                            .grey[700]),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  width:
                                                                                  MediaQuery
                                                                                      .of(
                                                                                      context)
                                                                                      .size
                                                                                      .width -
                                                                                      95,
                                                                                  child:
                                                                                  Text(
                                                                                    'Group: MDS Group',
                                                                                    style: TextStyle(
                                                                                        fontFamily: 'RobotoBold',
                                                                                        color: Colors
                                                                                            .grey[700]),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  height:
                                                                                  3,
                                                                                ),
                                                                                SizedBox(
                                                                                  width:
                                                                                  MediaQuery
                                                                                      .of(
                                                                                      context)
                                                                                      .size
                                                                                      .width -
                                                                                      95,
                                                                                  child:
                                                                                  Text(
                                                                                    (ansans['gender'] ==
                                                                                        globals
                                                                                            .gender ||
                                                                                        globals
                                                                                            .isAdmin ==
                                                                                            1)
                                                                                        ? ansans['phone']
                                                                                        : '',
                                                                                    style: TextStyle(
                                                                                        fontFamily: 'RobotoRegular',
                                                                                        color: Colors
                                                                                            .grey[500],
                                                                                        fontSize: 12),
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ));
                                                            } else {
                                                              return Container();
                                                            }
                                                          } else {
                                                            return SafeArea(
                                                                child:
                                                                    Container(
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              child: Card(
                                                                elevation: 1,
                                                                child: InkWell(
                                                                  onTap: () {},
                                                                  child: Row(
                                                                    children: <
                                                                        Widget>[
                                                                      SizedBox(
                                                                        height:
                                                                            74,
                                                                        width:
                                                                            30,
                                                                      ),
                                                                      Column(
                                                                        children: <
                                                                            Widget>[
                                                                          Center(
                                                                              child: SpinKitThreeBounce(
                                                                            color:
                                                                                Color(0xFF213a8f),
                                                                            size:
                                                                                15,
                                                                          )),
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ));
                                                          }
                                                        }) : Container();
                                                  },
                                                )
                                              : Center(
                                                  child: Text(
                                                    'Nobody reads this book yet',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'RobotoMedium',
                                                        fontSize: 17,
                                                        color:
                                                            Colors.grey[600]),
                                                  ),
                                                );
                                        } else {
                                          return Center(
                                              child: SpinKitCircle(
                                            color: Color(0xFF213a8f),
                                            size: 40,
                                          ));
                                        }
                                      }),
                                  FutureBuilder(
                                      future: getFinishedUsers(
                                          http.Client(),
                                          widget.booksInformation.bookId,
                                          globals.accessTokenG),
                                      builder: (context, finishedReaders) {
                                        if (finishedReaders.hasData) {
                                          String finishedBody = utf8.decode(
                                              finishedReaders.data.bodyBytes);
                                          dynamic finishedList =
                                              jsonDecode(finishedBody);
                                          return finishedList.length != 0
                                              ? ListView.builder(
                                                  itemCount:
                                                      finishedList.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return finishedList[index] != null ? FutureBuilder<
                                                            http.Response>(
                                                        future: getUsersDetails(
                                                            http.Client(),
                                                            finishedList[index]['profileId'],
                                                            globals.accessTokenG),
                                                        builder: (context,
                                                            userInform) {
                                                          if (userInform.hasData && userInform.data.body != "null") {
                                                            String bodyReader =
                                                                utf8.decode(
                                                                    userInform
                                                                        .data
                                                                        .bodyBytes);
                                                            if(bodyReader != null) {
                                                            ansReader =
                                                                parseProfileDetails(
                                                                    bodyReader);
                                                            Map ansans =
                                                                json.decode(
                                                                    bodyReader);
                                                              ansans['firstName'] =
                                                              ansans['firstName'] ==
                                                                  null
                                                                  ? ''
                                                                  : '${ansans['firstName']}';
                                                              ansans['lastName'] =
                                                              ansans['lastName'] ==
                                                                  null
                                                                  ? ''

                                                                  : ' ${ansans['lastName']}';
                                                              ansans['middleName'] =
                                                              ansans['middleName'] ==
                                                                  null
                                                                  ? ''
                                                                  : ' ${ansans['middleName']}';
                                                              ansans[
                                                              'email'] = ansans[
                                                              'email'] ==
                                                                  null
                                                                  ? ''
                                                                  : '${ansans['email']}';
                                                              ansans[
                                                              'phone'] = ansans[
                                                              'phone'] ==
                                                                  null
                                                                  ? ''
                                                                  : '${ansans['phone']}';
                                                              return SafeArea(
                                                                  child:
                                                                  Container(
                                                                    width:
                                                                    MediaQuery
                                                                        .of(
                                                                        context)
                                                                        .size
                                                                        .width,
                                                                    child: Card(
                                                                      elevation: 1,
                                                                      child: InkWell(
                                                                        onTap: () {
                                                                          Navigator
                                                                              .pushReplacement(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder:
                                                                                  (
                                                                                  context) =>
                                                                                  UserPage(
                                                                                      profileDetails: ansans),
                                                                            ),
                                                                          );
                                                                        },
                                                                        child: Row(
                                                                          children: <
                                                                              Widget>[
                                                                            Padding(
                                                                              padding: const EdgeInsets
                                                                                  .symmetric(
                                                                                  horizontal:
                                                                                  12,
                                                                                  vertical:
                                                                                  10),
                                                                              child:
                                                                              CircleAvatar(
                                                                                backgroundColor:
                                                                                Colors
                                                                                    .transparent,
                                                                                backgroundImage: ansans['avatar'] !=
                                                                                    null &&
                                                                                    ansans['avatar'] !=
                                                                                        '' &&
                                                                                    (ansans['gender'] ==
                                                                                        globals
                                                                                            .gender ||
                                                                                        globals
                                                                                            .isAdmin ==
                                                                                            1)
                                                                                    ? NetworkImage(
                                                                                    ansans['avatar'])
                                                                                    : ansans['gender'] ==
                                                                                    1
                                                                                    ? AssetImage(
                                                                                    'assets/profile_boy.png')
                                                                                    : AssetImage(
                                                                                    'assets/profile_girl.png'),
                                                                                radius:
                                                                                27,
                                                                              ),
                                                                            ),
                                                                            Column(
                                                                              children: <
                                                                                  Widget>[
                                                                                SizedBox(
                                                                                  width:
                                                                                  MediaQuery
                                                                                      .of(
                                                                                      context)
                                                                                      .size
                                                                                      .width -
                                                                                      95,
                                                                                  child:
                                                                                  Text(
                                                                                    '${ansans['firstName']} '
                                                                                        '${ansans['lastName']} '
                                                                                        '${ansans['middleName']}',
                                                                                    style: TextStyle(
                                                                                        fontFamily: 'RobotoBold',
                                                                                        color: Colors
                                                                                            .grey[700]),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  width:
                                                                                  MediaQuery
                                                                                      .of(
                                                                                      context)
                                                                                      .size
                                                                                      .width -
                                                                                      95,
                                                                                  child:
                                                                                  Text(
                                                                                    'Group: MDS  Group',
                                                                                    style: TextStyle(
                                                                                        fontFamily: 'RobotoBold',
                                                                                        color: Colors
                                                                                            .grey[700]),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  height:
                                                                                  3,
                                                                                ),
                                                                                SizedBox(
                                                                                  width:
                                                                                  MediaQuery
                                                                                      .of(
                                                                                      context)
                                                                                      .size
                                                                                      .width -
                                                                                      95,
                                                                                  child:
                                                                                  Text(
                                                                                    ansans['gender'] ==
                                                                                        globals
                                                                                            .gender ||
                                                                                        globals
                                                                                            .isAdmin ==
                                                                                            1
                                                                                        ? ansans['phone']
                                                                                        : '',
                                                                                    style: TextStyle(
                                                                                        fontFamily: 'RobotoRegular',
                                                                                        color: Colors
                                                                                            .grey[500],
                                                                                        fontSize: 12),
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ));
                                                            } else {
                                                              return Container();
                                                            }
                                                          } else {
                                                            return SafeArea(
                                                                child:
                                                                    Container(
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              child: Card(
                                                                elevation: 1,
                                                                child: InkWell(
                                                                  onTap: () {},
                                                                  child: Row(
                                                                    children: <
                                                                        Widget>[
                                                                      SizedBox(
                                                                        height:
                                                                            74,
                                                                        width:
                                                                            30,
                                                                      ),
                                                                      Column(
                                                                        children: <
                                                                            Widget>[
                                                                          Center(
                                                                              child: SpinKitThreeBounce(
                                                                            color:
                                                                                Color(0xFF213a8f),
                                                                            size:
                                                                                15,
                                                                          )),
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ));
                                                          }
                                                        }) : Container();
                                                  },
                                                )
                                              : Center(
                                                  child: Text(
                                                    'Nobody finished this book yet',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'RobotoMedium',
                                                        fontSize: 17,
                                                        color:
                                                            Colors.grey[600]),
                                                  ),
                                                );
                                        } else {
                                          return Center(
                                              child: SpinKitCircle(
                                            color: Color(0xFF213a8f),
                                            size: 40,
                                          ));
                                        }
                                      }),
                                  FutureBuilder(
                                      future: getFinishedUsers(
                                          http.Client(),
                                          widget.booksInformation.bookId,
                                          globals.accessTokenG),
                                      builder: (context, finishedReaders) {
                                        if (finishedReaders.hasData) {
                                          String finishedBody = utf8.decode(
                                              finishedReaders.data.bodyBytes);
                                          dynamic finishedList =
                                              jsonDecode(finishedBody);
                                          return finishedList.length != 0
                                              ? ListView.builder(
                                                  itemCount:
                                                      finishedList.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return finishedList[index] != null ? FutureBuilder<
                                                            http.Response>(
                                                        future: getUsersDetails(
                                                            http.Client(),
                                                            finishedList[index]
                                                                ['profileId'],
                                                            globals
                                                                .accessTokenG),
                                                        builder: (context,
                                                            userInform) {
                                                          if (userInform
                                                              .hasData && userInform.data.body != "null") {
                                                            String bodyReader =
                                                                utf8.decode(
                                                                    userInform
                                                                        .data
                                                                        .bodyBytes);
                                                          if(bodyReader != null) {
                                                            dynamic ansans =
                                                                jsonDecode(
                                                                    bodyReader);
                                                              ansans['firstName'] =
                                                              ansans['firstName'] ==
                                                                  ''
                                                                  ? ''
                                                                  : '${ansans['firstName']}';
                                                              ansans['lastName'] =
                                                              ansans['lastName'] ==
                                                                  ''
                                                                  ? ''
                                                                  : ' ${ansans['lastName']}';
                                                              ansans['middleName'] =
                                                              ansans['middleName'] ==
                                                                  null
                                                                  ? ''
                                                                  : ' ${ansans['middleName']}';

                                                              void showFullText(
                                                                  int reviewIndex) {
                                                                setState(() {
                                                                  if (isClosedMap[
                                                                  finishedList[reviewIndex]
                                                                  [
                                                                  'id']] ==
                                                                      null) {
                                                                    isClosedMap[finishedList[
                                                                    reviewIndex]
                                                                    [
                                                                    'id']] =
                                                                    true;
                                                                  }
                                                                  isClosedMap[
                                                                  finishedList[
                                                                  reviewIndex]
                                                                  [
                                                                  'id']] =
                                                                  !isClosedMap[
                                                                  finishedList[
                                                                  reviewIndex]
                                                                  ['id']];
                                                                });
                                                              }

                                                              return SafeArea(
                                                                child: Container(
                                                                  width: MediaQuery
                                                                      .of(
                                                                      context)
                                                                      .size
                                                                      .width,
                                                                  child: Card(
                                                                    elevation: 1,
                                                                    child:
                                                                    InkWell(
                                                                      onTap: () {
                                                                        Navigator
                                                                            .pushReplacement(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (
                                                                                context) =>
                                                                                UserPage(
                                                                                    profileDetails: ansans),
                                                                          ),
                                                                        );
                                                                      },
                                                                      child: Row(
                                                                        mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                        crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                        children: <
                                                                            Widget>[
                                                                          Padding(
                                                                            padding: const EdgeInsets
                                                                                .symmetric(
                                                                                horizontal: 12,
                                                                                vertical: 13),
                                                                            child:
                                                                            CircleAvatar(
                                                                              backgroundColor:
                                                                              Colors
                                                                                  .transparent,
                                                                              backgroundImage: ansans['avatar'] !=
                                                                                  null &&
                                                                                  ansans['avatar'] !=
                                                                                      '' &&
                                                                                  (ansans['gender'] ==
                                                                                      globals
                                                                                          .gender ||
                                                                                      globals
                                                                                          .isAdmin ==
                                                                                          1)
                                                                                  ? NetworkImage(
                                                                                  ansans['avatar'])
                                                                                  : ansans['gender'] ==
                                                                                  1
                                                                                  ? AssetImage(
                                                                                  'assets/profile_boy.png')
                                                                                  : AssetImage(
                                                                                  'assets/profile_girl.png'),
                                                                              radius:
                                                                              27,
                                                                            ),
                                                                          ),
                                                                          Column(
                                                                            children: <
                                                                                Widget>[
                                                                              SizedBox(
                                                                                height: 15,
                                                                              ),
                                                                              SizedBox(
                                                                                width: MediaQuery
                                                                                    .of(
                                                                                    context)
                                                                                    .size
                                                                                    .width -
                                                                                    95,
                                                                                child: Text(
                                                                                  '${ansans['firstName']} '
                                                                                      '${ansans['lastName']} '
                                                                                      '${ansans['middleName']} ',
                                                                                  style: TextStyle(
                                                                                      fontFamily: 'RobotoBold',
                                                                                      fontSize: 13,
                                                                                      color: Colors
                                                                                          .grey[600]),
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: MediaQuery
                                                                                    .of(
                                                                                    context)
                                                                                    .size
                                                                                    .width -
                                                                                    95,
                                                                                height: 20,
                                                                                child: RatingBarIndicator(
                                                                                  rating: finishedList[index]['bookRating'],
                                                                                  itemBuilder: (
                                                                                      context,
                                                                                      index) =>
                                                                                      Icon(
                                                                                        Icons
                                                                                            .star,
                                                                                        color: Colors
                                                                                            .amber[800],
                                                                                      ),
                                                                                  itemCount: 5,
                                                                                  itemSize: 15.0,
                                                                                  direction: Axis
                                                                                      .horizontal,
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: MediaQuery
                                                                                    .of(
                                                                                    context)
                                                                                    .size
                                                                                    .width -
                                                                                    95,
                                                                                child: Column(
                                                                                  mainAxisAlignment: MainAxisAlignment
                                                                                      .start,
                                                                                  crossAxisAlignment: CrossAxisAlignment
                                                                                      .start,
                                                                                  children: [
                                                                                    isClosedMap[finishedList[index]['id']] ==
                                                                                        false
                                                                                        ? Text(
                                                                                      finishedList[index]['bookReview'],
                                                                                      style: TextStyle(
                                                                                          fontFamily: 'RobotoMedium',
                                                                                          color: Colors
                                                                                              .grey[700],
                                                                                          fontSize: 15),
                                                                                    )
                                                                                        : Text(
                                                                                      finishedList[index]['bookReview']
                                                                                          .toString()
                                                                                          .substring(
                                                                                          0,
                                                                                          30),
                                                                                      style: TextStyle(
                                                                                          fontFamily: 'RobotoMedium',
                                                                                          color: Colors
                                                                                              .grey[700],
                                                                                          fontSize: 15),
                                                                                    ),
                                                                                    GestureDetector(
                                                                                      child: Text(
                                                                                        isClosedMap[finishedList[index]['id']] ==
                                                                                            true
                                                                                            ? '...less'
                                                                                            : '...more',
                                                                                        style: TextStyle(
                                                                                            fontFamily: 'RobotoMedium',
                                                                                            color: Colors
                                                                                                .yellow[900],
                                                                                            fontSize: 15),
                                                                                      ),
                                                                                      onTap: () =>
                                                                                          showFullText(
                                                                                              index),
                                                                                    ),
//                                                                          FlatButton(onPressed: () => showFullText(index), child: Text('...more'), padding: EdgeInsets.only(left: -0),)
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 15,
                                                                              ),
                                                                            ],
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            } else {
                                                              return Container();
                                                            }
                                                          } else {
                                                            return SafeArea(
                                                                child:
                                                                    Container(
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              child: Card(
                                                                elevation: 1,
                                                                child: InkWell(
                                                                  onTap: () {},
                                                                  child: Row(
                                                                    children: <
                                                                        Widget>[
                                                                      SizedBox(
                                                                        height:
                                                                            74,
                                                                        width:
                                                                            30,
                                                                      ),
                                                                      Column(
                                                                        children: <
                                                                            Widget>[
                                                                          Center(
                                                                              child: SpinKitThreeBounce(
                                                                            color:
                                                                                Color(0xFF213a8f),
                                                                            size:
                                                                                15,
                                                                          )),
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ));
                                                          }
                                                        }) : Container();
                                                  },
                                                )
                                              : Center(
                                                  child: Text(
                                                    'No one has reviewed this book yet',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'RobotoMedium',
                                                        fontSize: 17,
                                                        color:
                                                            Colors.grey[600]),
                                                  ),
                                                );
                                        } else {
                                          return Center(
                                              child: SpinKitCircle(
                                            color: Colors.white,
                                            size: 40,
                                          ));
                                        }
                                      })
                                ],
                              ),
                            ),
                          )),
                    );
                  } else {
                    return BookMainLoading();
                  }
                });
          } else if (userdata.data == 1) {
            return ErrorPage();
          } else {
            return BookMainLoading();
          }
        });
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: Card(
        elevation: 3,
        child: _tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _SliverAppBarDelegate2 extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate2(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: Card(
        elevation: 3,
        child: _tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate2 oldDelegate) {
    return false;
  }
}

class BookMainLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: SingleChildScrollView(
            scrollDirection: Axis.horizontal, child: Text('Books')),
        backgroundColor: Color(0xFF213A8F),
      ),
      body: Scaffold(
          backgroundColor: Color(0xFF6F6F7),
          body: DefaultTabController(
            length: 4,
            child: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      backgroundColor: Color(0xFF213A8F),
                      automaticallyImplyLeading: false,
                      expandedHeight: 220.0,
                      flexibleSpace: FlexibleSpaceBar(
                          background: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                              height: 50,
                              width: 350,
                              child: Center(
                                  child: SpinKitCircle(
                                color: Colors.white,
                                size: 40,
                              ))),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      )),
                    ),
                    SliverPersistentHeader(
                      delegate: _SliverAppBarDelegate2(
                        TabBar(
                          labelColor: Color(0xFF213A8F),
                          indicatorWeight: 4,
                          indicatorColor: Color(0xFF213A8F),
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(
                              icon: Icon(Icons.book, color: Color(0xFF213A8F)),
                              child: Text(
                                'Description',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontFamily: 'RobotoBold'),
                              ),
                            ),
                            Tab(
                              icon:
                                  Icon(Icons.receipt, color: Color(0xFF213A8F)),
                              child: Text(
                                'Reading',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontFamily: 'RobotoBold'),
                              ),
                            ),
                            Tab(
                              icon: Icon(Icons.cloud_done,
                                  color: Color(0xFF213A8F)),
                              child: Text(
                                'Already read',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontFamily: 'RobotoBold'),
                              ),
                            ),
                            Tab(
                              icon: Icon(Icons.rate_review,
                                  color: Color(0xFF213A8F)),
                              child: Text(
                                'Reviews',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontFamily: 'RobotoBold'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pinned: true,
                    ),
                  ];
                },
                body: Container()),
          )),
    );
  }
}
