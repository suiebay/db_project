import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:mds_reads/pages/books/book_main.dart';
import 'package:mds_reads/pages/books/books_information.dart';
import 'package:http/http.dart' as http;
import 'package:mds_reads/pages/error_page.dart';
import 'package:mds_reads/pages/quiz/data/repositories/quiz_repository.dart';
import 'package:mds_reads/pages/user/profile_details.dart';
import 'package:mds_reads/pages/user/user_book_finish.dart';
import 'package:mds_reads/pages/user/user_book_grading.dart';
import 'dart:io' show Platform;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:mds_reads/globals.dart' as globals;

import '../../drawer.dart';

Future<http.Response> createRequest(String bookName, String bookAuthor, String token) async {
  Box box = Hive.box('config');
  var url;
  if(Platform.isAndroid) url = '${box.get('url')}/api/project/mdsreads/userbook/recommendation/new';
  else if(Platform.isIOS) url = '${box.get('url')}/api/project/mdsreads/userbook/recommendation/new';

  Map data = {
    'bookName': bookName,
    'bookAuthor': bookAuthor,
  };
  //encode Map to JSON
  var body = json.encode(data);

  var response = await http.post(url,
      headers: {"Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },

      body: body
  );
  return response;
}

Future<http.Response> deleteReadingBook(String id, String token) async {
  Box box = Hive.box('config');
  var url;
  if(Platform.isAndroid) url = '${box.get('url')}/api/project/mdsreads/userbook/delete/$id';
  else if(Platform.isIOS) url = '${box.get('url')}/api/project/mdsreads/userbook/delete/$id';

  final http.Response response = await http.delete(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
  );

  return response;
}

// ignore: must_be_immutable
class UserPage extends StatefulWidget {
  dynamic profileDetails;

  UserPage ({ this.profileDetails });

  @override
  _BookMainState createState() => _BookMainState();
}

getStringValuesSF(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String stringValue = prefs.getString(key);
  return stringValue;
}

ProfileDetails parseProfileDetails(String responseBody) {
  Map something = jsonDecode(responseBody);
  var someSome = ProfileDetails.fromJson(something);

  return someSome;
}

class _BookMainState extends State<UserPage> with SingleTickerProviderStateMixin{

  BooksInformation booksInformation;
  List<BooksInformation> booksReading = [];
  var ansReader;

  Map isClosed = Map<String, bool>();

  void refreshState() {
    setState(() {});
  }

  String validateBookName(String value) {
    if (value.length == 0) {
      return "Book name is required";
    }
    return null;
  }

  String validateAuthor(String value) {
    if (value.length == 0) {
      return "Author is Required";
    }
    return null;
  }

  bool _sendToServer() {
    if (_key.currentState.validate()) {
      // No any error in validation
      _key.currentState.save();
      return true;
    } else {
      // validation error
      setState(() {
        _validate = true;
      });
      return false;
    }
  }

  final bookName = TextEditingController();
  final bookAuthor = TextEditingController();
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  String title, description;
  var status;
  var ans;
  var bookAns;
  var profileInformation;
  String acsToken;
  TabController _controller;
//  BooksInformation _searchResult;
  BooksInformation _bookDetail;
  List<dynamic> recommendList;
  List<dynamic> recommendList2;

  Future<BooksInformation> getBookDetails(String id, String token) async {
    Box box = Hive.box('config');
    var response;
    var url;
    if(Platform.isAndroid) { url = '${box.get('url')}/api/project/mdsreads/books/get/$id'; }
    else if(Platform.isIOS) { url = '${box.get('url')}/api/project/mdsreads/books/get/$id'; }

    response = await http.get(url,
      headers: {"Content-Type": "application/json", 'Authorization': 'Bearer $token'},
    );

    String body = utf8.decode(response.bodyBytes);
    final responseJson = json.decode(body);

    _bookDetail = BooksInformation.fromJson(responseJson);

    return _bookDetail;
  }

  Future<dynamic> getUserPlace(String id, String token) async {
    Box box = Hive.box('config');
    var response;
    var url;
    if(Platform.isAndroid) { url = '${box.get('url')}/api/reads/user-place/$id'; }
    else if(Platform.isIOS) { url = '${box.get('url')}/api/reads/user-place/$id'; }

    response = await http.get(url,
      headers: {"Content-Type": "application/json", 'Authorization': 'Bearer $token'},
    );

    String body = utf8.decode(response.bodyBytes);
    if(body == "ADMIN") {
      return 1;
    }
    if(body == "NOT FOUND") {
      return "unrated";
    }

    return int.parse(body);
  }

  Future<BooksInformation> getBookDetailsWithDeleted(String id, String token) async {
    Box box = Hive.box('config');
    var response;
    var url;
    if(Platform.isAndroid) { url = '${box.get('url')}/api/project/mdsreads/books/get-with-deleted/$id'; }
    else if(Platform.isIOS) { url = '${box.get('url')}/api/project/mdsreads/books/get-with-deleted/$id'; }

    response = await http.get(url,
      headers: {"Content-Type": "application/json", 'Authorization': 'Bearer $token'},
    );

    String body = utf8.decode(response.bodyBytes);
    final responseJson = json.decode(body);

    _bookDetail = BooksInformation.fromJson(responseJson);

    return _bookDetail;
  }

  dynamic getMyProfile(http.Client client, String token) async {
    Box box = Hive.box('config');
    try {
      var url;
      if (Platform.isAndroid) {
        url = '${box.get('url')}/api/myprofile';
      }
      else if (Platform.isIOS) {
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
    } on TimeoutException catch(_) {
      return 1;
    }
  }

  Future<http.Response> getByIdUserBook(http.Client client, String id, String token) async {
    Box box = Hive.box('config');
    var url;
    if(Platform.isAndroid) { url = '${box.get('url')}/api/project/mdsreads/userbook/getbyuser/$id'; }
    else if(Platform.isIOS) { url = '${box.get('url')}/api/project/mdsreads/userbook/getbyuser/$id'; }

    final http.Response response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    return response;
  }

  Future<http.Response> getByIdUserBookWithDeleted(http.Client client, String id, String token) async {
    Box box = Hive.box('config');
    var url;
    if(Platform.isAndroid) { url = '${box.get('url')}/api/project/mdsreads/userbook/getbyuser-with-deleted/$id'; }
    else if(Platform.isIOS) { url = '${box.get('url')}/api/project/mdsreads/userbook/getbyuser-with-deleted/$id'; }

    final http.Response response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    return response;
  }

  Future<http.Response> getUserFinishedBooksWithDeleted(http.Client client, String id, String token) async {
    Box box = Hive.box('config');
    var url;
    if(Platform.isAndroid) { url = '${box.get('url')}/api/project/mdsreads/userbook/userfinishedlist-with-deleted/$id'; }
    else if(Platform.isIOS) { url = '${box.get('url')}/api/project/mdsreads/userbook/userfinishedlist-with-deleted/$id'; }

    final http.Response response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    return response;
  }

  Future<http.Response> getUsersDetails(http.Client client, String id, String token) async {
    Box box = Hive.box('config');
    var url;
    if(Platform.isAndroid) { url = '${box.get('url')}/api/profiles/$id'; }
    else if(Platform.isIOS) { url = '${box.get('url')}/api/profiles/$id'; }

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
  void initState() {
    super.initState();
    //getBookDetails(widget.booksInformation.bookId);
    _controller = new TabController(length: 4, vsync: this);
  }

  var checker = true;

  @override
  Widget build(BuildContext context) {
    if(globals.accessTokenG == null) {
      Navigator.pushReplacementNamed(context, '/config');
    }
    return FutureBuilder<dynamic>(
        future: getMyProfile(http.Client(), globals.accessTokenG),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != 1) {
            String body = utf8.decode(snapshot.data.bodyBytes);
            ans = parseProfileDetails(body);
            if(globals.gender == null) { globals.gender = ans.gender; }
            globals.userId = ans.userId;
            if (ans.recommendationBook != null) {
              recommendList = jsonDecode(ans.recommendationBook);
            }
            if (widget.profileDetails != null &&
                widget.profileDetails['readsRecoomendation'] != null) {
              recommendList2 = jsonDecode(
                  widget.profileDetails['readsRecoomendation']);
            }
            return widget.profileDetails == null ||
                ans.userId == widget.profileDetails['id'] ?
            FutureBuilder(
                future: getUserPlace(ans.userId, globals.accessTokenG),
                builder: (context, userPlace) {
                  if (userPlace.hasData) {
                    return Scaffold(
                        appBar: AppBar(
                          elevation: 0,
                          title: Text('My Cabinet'),
                          backgroundColor: Color(0xFF213A8F),
                          actions: <Widget>[
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () async {
                                await Navigator.pushNamed(context, '/useredit')
                                    .then((value) {
                                  setState(() {});
                                });
                              },
                            ),
                          ],
                        ),
                        body: Scaffold(
                            backgroundColor: Color(0xFF6F6F7),
                            body: DefaultTabController(
                              length: 4,
                              child: NestedScrollView(
                                headerSliverBuilder: (BuildContext context,
                                    bool innerBoxIsScrolled) {
                                  if (ans.readsPoint == null) {
                                    ans.readsPoint = 0;
                                  }
                                  return <Widget>[
                                    SliverAppBar(
                                      backgroundColor: Color(0xFF213A8F),
                                      automaticallyImplyLeading: false,
                                      expandedHeight: ans.lastName == '' && ans
                                          .middleName == '' ? 245.0 : 249.0,
                                      flexibleSpace: FlexibleSpaceBar(
                                          background: Column(
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  SizedBox(width: 62,),
                                                  Container(
                                                      child: Stack(
                                                          children: <Widget>[
                                                            Container(
                                                                child: CircleAvatar(
                                                                  backgroundColor: Colors.transparent,
                                                                  backgroundImage: ans.avatar != null && ans.avatar != '' ?
                                                                  NetworkImage(ans.avatar) :
                                                                  ans.gender == 1
                                                                      ? AssetImage(
                                                                      'assets/profile_boy.png')
                                                                      : AssetImage(
                                                                      'assets/profile_girl.png'),
                                                                  radius: 50,
                                                                ),
                                                                padding: EdgeInsets
                                                                    .all(
                                                                    3.0),
                                                                decoration: BoxDecoration(
                                                                  color: ans
                                                                      .readsPoint >=
                                                                      750 && ans
                                                                      .finishedBooksNum >=
                                                                      50 && ans
                                                                      .readsReviewNumber >=
                                                                      50
                                                                      ? Color(
                                                                      0xFFFFD700)
                                                                      : ans
                                                                      .readsPoint >=
                                                                      300 && ans
                                                                      .finishedBooksNum >=
                                                                      20 && ans
                                                                      .readsReviewNumber >=
                                                                      20
                                                                      && (ans
                                                                          .readsPoint <
                                                                          750 || ans
                                                                          .finishedBooksNum <
                                                                          50 && ans
                                                                          .readsReviewNumber <
                                                                          50)
                                                                      ? Color(
                                                                      0xFFC0C0C0)
                                                                      : ans
                                                                      .readsPoint >=
                                                                      75 && ans
                                                                      .finishedBooksNum >=
                                                                      5 && ans
                                                                      .readsReviewNumber >=
                                                                      5
                                                                      && (ans
                                                                          .readsPoint <
                                                                          300 || ans
                                                                          .finishedBooksNum <
                                                                          20 && ans
                                                                          .readsReviewNumber <
                                                                          20)
                                                                      ? Color(
                                                                      0xFFCD7F32)
                                                                      : Colors
                                                                      .white,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                )
                                                            ),
                                                            Positioned(
                                                              bottom: 0,
                                                              right: 0,
                                                              child: Image(
                                                                image: ans
                                                                    .readsPoint >=
                                                                    750 &&
                                                                    ans
                                                                        .finishedBooksNum >=
                                                                        50 &&
                                                                    ans
                                                                        .readsReviewNumber >=
                                                                        50
                                                                    ? AssetImage(
                                                                    'assets/ic_gold.png')
                                                                    : ans
                                                                    .readsPoint >=
                                                                    300 &&
                                                                    ans
                                                                        .finishedBooksNum >=
                                                                        20 &&
                                                                    ans
                                                                        .readsReviewNumber >=
                                                                        20
                                                                    &&
                                                                    (ans
                                                                        .readsPoint <
                                                                        750 ||
                                                                        ans
                                                                            .finishedBooksNum <
                                                                            50 &&
                                                                            ans
                                                                                .readsReviewNumber <
                                                                                50)
                                                                    ? AssetImage(
                                                                    'assets/ic_silver.png')
                                                                    : ans
                                                                    .readsPoint >=
                                                                    75 && ans
                                                                    .finishedBooksNum >=
                                                                    5 &&
                                                                    ans
                                                                        .readsReviewNumber >=
                                                                        5
                                                                    && (ans
                                                                        .readsPoint <
                                                                        300 || ans
                                                                        .finishedBooksNum <
                                                                        20 && ans
                                                                        .readsReviewNumber <
                                                                        20)
                                                                    ? AssetImage(
                                                                    'assets/ic_bronze.png')
                                                                    : AssetImage(
                                                                    'assets/transparent.png'),
                                                                width: 30,
                                                              ),
                                                            )
                                                          ]
                                                      )
                                                  ),
                                                  SizedBox(width: 15,),
                                                  Column(
                                                    children: <Widget>[
                                                      Icon(
                                                        Icons.star,
                                                        color: Colors.white,
                                                        size: 45,
                                                      ),
                                                      Text(
                                                        ans.readsPoint.toString(),
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontFamily: 'RobotoBold',
                                                            fontSize: 15
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10,),
                                              Text(
                                                "${ans.firstName}${ans
                                                    .lastName}${ans
                                                    .middleName}",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'RobotoBold',
                                                    fontSize: 17
                                                ),
                                              ),
                                              SizedBox(height: 5,),
                                              Text(
                                                globals.gender == ans.gender
                                                    ? ans.email
                                                    : '',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'RobotoBold',
                                                    fontSize: 15
                                                ),
                                              ),
                                              SizedBox(height: 5,),
                                              Text(
                                                globals.gender == ans.gender
                                                    ? ans.phone
                                                    : '',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'RobotoBold',
                                                    fontSize: 15
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              Expanded(
                                                child: Container(
                                                  padding: EdgeInsets.only(top: 10),
                                                  width: double.infinity,
                                                  color: Colors.grey[200],
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment
                                                        .center,
                                                    children: <Widget>[
                                                      //SizedBox(width: 10,),
                                                      Container(
                                                        width: MediaQuery
                                                            .of(context)
                                                            .size
                                                            .width * 0.33,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment
                                                              .center,
                                                          children: <Widget>[
                                                            Text(
                                                              'Rating in Group',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey[700],
                                                                  fontFamily: 'RobotoMedium',
                                                                  fontSize: 15
                                                              ),
                                                            ),
                                                            Text(
                                                              userPlace.data
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey[700],
                                                                  fontFamily: 'RobotoBold',
                                                                  fontSize: 15
                                                              ),
                                                            ),
                                                            SizedBox(height: 8,),
                                                          ],
                                                        ),
                                                      ),
                                                      //Spacer(),
                                                      Container(
                                                        width: MediaQuery
                                                            .of(context)
                                                            .size
                                                            .width * 0.33,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment
                                                              .center,
                                                          children: <Widget>[
                                                            Text(
                                                              'Group',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey[700],
                                                                  fontFamily: 'RobotoMedium',
                                                                  fontSize: 15
                                                              ),
                                                            ),
                                                            Text(
                                                              'MDS Group',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey[700],
                                                                  fontFamily: 'RobotoBold',
                                                                  fontSize: 15
                                                              ),
                                                            ),
                                                            SizedBox(height: 8,),
                                                          ],
                                                        ),
                                                      ),
                                                      //Spacer(),
                                                      Container(
                                                        width: MediaQuery
                                                            .of(context)
                                                            .size
                                                            .width * 0.34,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment
                                                              .center,
                                                          children: <Widget>[
                                                            Text(
                                                              'Read Books',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey[700],
                                                                  fontFamily: 'RobotoMedium',
                                                                  fontSize: 15
                                                              ),
                                                            ),
                                                            Text(
                                                              ans
                                                                  .finishedBooksNum ==
                                                                  null
                                                                  ? '0'
                                                                  : ans
                                                                  .finishedBooksNum
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey[700],
                                                                  fontFamily: 'RobotoBold',
                                                                  fontSize: 15
                                                              ),
                                                            ),
                                                            SizedBox(height: 8,),
                                                          ],
                                                        ),
                                                      ),
                                                      //SizedBox(width: 10,),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          )
                                      ),
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
                                              icon: Icon(
                                                  Icons.book,
                                                  color: Color(0xFF213A8F)),
                                              child: Text(
                                                'Reading',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'RobotoBold'
                                                ),
                                              ),
                                            ),
                                            Tab(
                                              icon: Icon(
                                                  Icons.cloud_done,
                                                  color: Color(0xFF213A8F)),
                                              child: Text(
                                                'Read',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'RobotoBold'
                                                ),
                                              ),
                                            ),
                                            Tab(
                                              icon: Icon(
                                                  Icons.receipt,
                                                  color: Color(0xFF213A8F)),
                                              child: Text(
                                                'Reviews',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'RobotoBold'
                                                ),
                                              ),
                                            ),
                                            Tab(
                                              icon: Icon(Icons.stars,
                                                  color: Color(0xFF213A8F)),
                                              child: Text(
                                                'Recommendation',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'RobotoBold'
                                                ),
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
                                  children: <Widget>[
                                    FutureBuilder<http.Response>(
                                        future: getByIdUserBook(
                                            http.Client(), ans.userId,
                                            globals.accessTokenG),
                                        builder: (context, userBook) {
                                          if (userBook.hasData) {
                                            String bookBody = utf8.decode(
                                                userBook.data.bodyBytes);
                                            dynamic bookInform = jsonDecode(
                                                bookBody);
                                            return bookInform != null
                                                ? FutureBuilder<BooksInformation>(
                                                future: getBookDetailsWithDeleted(
                                                    bookInform['bookId'],
                                                    globals.accessTokenG),
                                                builder: (context, aboutBook) {
                                                  if (aboutBook.hasData) {
                                                    booksReading.clear();
                                                    booksReading.add(
                                                        aboutBook.data);
                                                    return ListView.builder(
                                                      itemCount: booksReading
                                                          .length,
                                                      itemBuilder: (context,
                                                          index) {
                                                        return SafeArea(
                                                            child: Container(
                                                              width: MediaQuery
                                                                  .of(context)
                                                                  .size
                                                                  .width,
                                                              child: Card(
                                                                elevation: 1,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    showDialog(
                                                                      context: context,
                                                                    builder: (BuildContext context) { return AlertDialog(
                                                                        content: Container(
                                                                          height: 63,
                                                                          child: Column(
                                                                            children: <
                                                                                Widget>[
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  Navigator
                                                                                      .pop(
                                                                                      context);
                                                                                  showDialog(
                                                                                    context: context,
    builder: (BuildContext context) { return AlertDialog(
                                                                                      //contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                                                                      title: Text(
                                                                                          'Finish: ${booksReading[index]
                                                                                              .title}'),
                                                                                      content: Container(
                                                                                        height: 86,
                                                                                        child: Column(
                                                                                          children: <
                                                                                              Widget>[
                                                                                            Text(
                                                                                              'Are you really finished this book?',
                                                                                            ),
                                                                                            Row(
                                                                                              children: <
                                                                                                  Widget>[
                                                                                                Spacer(),
                                                                                                FlatButton(
                                                                                                  onPressed: () {
                                                                                                    Navigator
                                                                                                        .pop(
                                                                                                        context);
                                                                                                  },
                                                                                                  child: Text(
                                                                                                    'NO',
                                                                                                    style: TextStyle(
                                                                                                        color: Colors
                                                                                                            .cyan[800]
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                FlatButton(
                                                                                                  onPressed: () {
                                                                                                    Navigator
                                                                                                        .pop(
                                                                                                        context);
                                                                                                    Navigator
                                                                                                        .push(
                                                                                                      context,
                                                                                                      MaterialPageRoute(
                                                                                                        builder: (
                                                                                                            context) =>
                                                                                                            UserBookFinish(
                                                                                                                booksInformation: booksReading[index],
                                                                                                                userBookId: bookInform['id'],
                                                                                                                userBookProfileId: bookInform['profileId']),
                                                                                                      ),
                                                                                                    )
                                                                                                        .then((
                                                                                                        value) {
                                                                                                      //getBookDetails();
                                                                                                      refreshState();
                                                                                                    });
                                                                                                  },
                                                                                                  child: Text(
                                                                                                    'YES',
                                                                                                    style: TextStyle(
                                                                                                        color: Colors
                                                                                                            .cyan[800]
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            )
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    );}
                                                                                  );
                                                                                },
                                                                                child: Row(
                                                                                    children: <
                                                                                        Widget>[
                                                                                      Text(
                                                                                        'FINISHED',
                                                                                        style: TextStyle(
                                                                                            fontFamily: 'RobotoRegular',
                                                                                            fontSize: 18
                                                                                        ),
                                                                                      ),
                                                                                      Spacer(),
                                                                                      Icon(
                                                                                          Icons
                                                                                              .done_all,
                                                                                          color: Colors
                                                                                              .green
                                                                                      )
                                                                                    ]
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 15,),
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  Navigator
                                                                                      .pop(
                                                                                      context);
                                                                                  showDialog(
                                                                                    context: context,
    builder: (BuildContext context) { return AlertDialog(
                                                                                      //contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                                                                      title: Text(
                                                                                          'Delete: ${booksReading[index]
                                                                                              .title}'),
                                                                                      content: Container(
                                                                                        height: 86,
                                                                                        child: Column(
                                                                                          children: <
                                                                                              Widget>[
                                                                                            Text(
                                                                                              'Are you sure to delete this book?',
                                                                                            ),
                                                                                            Row(
                                                                                              children: <
                                                                                                  Widget>[
                                                                                                Spacer(),
                                                                                                FlatButton(
                                                                                                  onPressed: () {
                                                                                                    Navigator
                                                                                                        .pop(
                                                                                                        context);
                                                                                                  },
                                                                                                  child: Text(
                                                                                                    'NO',
                                                                                                    style: TextStyle(
                                                                                                        color: Colors
                                                                                                            .cyan[800]
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                FlatButton(
                                                                                                  onPressed: () async {
                                                                                                    await deleteReadingBook(
                                                                                                        bookInform['id'],
                                                                                                        globals
                                                                                                            .accessTokenG);
                                                                                                    refreshState();
                                                                                                    Navigator
                                                                                                        .pop(
                                                                                                        context);
                                                                                                  },
                                                                                                  child: Text(
                                                                                                    'YES',
                                                                                                    style: TextStyle(
                                                                                                        color: Colors
                                                                                                            .cyan[800]
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            )
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    );}
                                                                                  );
                                                                                },
                                                                                child: Row(
                                                                                    children: <
                                                                                        Widget>[
                                                                                      Text(
                                                                                        'DELETE',
                                                                                        style: TextStyle(
                                                                                            fontFamily: 'RobotoRegular',
                                                                                            fontSize: 18
                                                                                        ),
                                                                                      ),
                                                                                      Spacer(),
                                                                                      Icon(
                                                                                        Icons
                                                                                            .delete,
                                                                                        color: Colors
                                                                                            .red,
                                                                                      )
                                                                                    ]
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      );}
                                                                    );
                                                                  },
                                                                  child: Row(
                                                                    children: <
                                                                        Widget>[
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal: 12,
                                                                            vertical: 10),
                                                                        child: Image(
                                                                            height: 35,
                                                                            image: AssetImage(
                                                                                'assets/notebook.png')
                                                                        ),
                                                                      ),
                                                                      Column(
                                                                        children: <
                                                                            Widget>[
                                                                          SizedBox(
                                                                            width: MediaQuery
                                                                                .of(
                                                                                context)
                                                                                .size
                                                                                .width -
                                                                                70,
                                                                            child: Text(
                                                                              '${booksReading[index]
                                                                                  .title}',
                                                                              style: TextStyle(
                                                                                fontFamily: 'RobotoBold',
                                                                                color: Colors
                                                                                    .grey[700],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            height: 4,),
                                                                          SizedBox(
                                                                            width: MediaQuery
                                                                                .of(
                                                                                context)
                                                                                .size
                                                                                .width -
                                                                                70,
                                                                            child: Text(
                                                                              '${booksReading[index]
                                                                                  .author}',
                                                                              style: TextStyle(
                                                                                  fontFamily: 'RobotoLight',
                                                                                  color: Colors
                                                                                      .grey[700],
                                                                                  fontSize: 13
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                        );
                                                      },
                                                    );
                                                  } else {
                                                    return Padding(
                                                      padding: const EdgeInsets.all(
                                                          4),
                                                      child: Container(
                                                        child: Card(
                                                          margin: EdgeInsets.only(
                                                              bottom: 203),
                                                          elevation: 1,
                                                          child: InkWell(
                                                            onTap: () {},
                                                            child: Row(
                                                              children: <Widget>[
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal: 12,
                                                                      vertical: 10),
                                                                  child: Image(
                                                                      height: 35,
                                                                      image: AssetImage(
                                                                          'assets/notebook.png')
                                                                  ),
                                                                ),
                                                                Center(
                                                                    child: SpinKitThreeBounce(
                                                                      color: Colors
                                                                          .brown[300],
                                                                      size: 10,
                                                                    )
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                }
                                            )
                                                : Center(
                                              child: Text(
                                                'You do not have a reading book',
                                                style: TextStyle(
                                                    fontFamily: 'RobotoMedium',
                                                    fontSize: 17,
                                                    color: Colors.grey[600]
                                                ),
                                              ),
                                            );
                                          } else {
                                            return Center(
                                                child: SpinKitCircle(
                                                  color: Color(0xFF213a8f),
                                                  size: 40,
                                                )
                                            );
                                          }
                                        }
                                    ),
                                    FutureBuilder(
                                        future: getUserFinishedBooksWithDeleted(
                                            http.Client(), ans.userId,
                                            globals.accessTokenG),
                                        builder: (context, userFinished) {
                                          if (userFinished.hasData) {
                                            String finishedBody = utf8.decode(
                                                userFinished.data.bodyBytes);
                                            dynamic finishedList = jsonDecode(
                                                finishedBody);
                                            return finishedList.length != 0
                                                ? ListView.builder(
                                              itemCount: finishedList.length,
                                              itemBuilder: (context, index) {
                                                return FutureBuilder<
                                                    BooksInformation>(
                                                    future: getBookDetailsWithDeleted(
                                                        finishedList[index]['bookId'],
                                                        globals.accessTokenG),
                                                    builder: (context, bookInform) {
                                                      if (bookInform.hasData) {
                                                        return SafeArea(
                                                            child: Container(
                                                              width: MediaQuery
                                                                  .of(context)
                                                                  .size
                                                                  .width,
                                                              child: Card(
                                                                elevation: 1,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    bookInform.data
                                                                        .deletedAt ==
                                                                        null ?
                                                                    Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder: (
                                                                            context) =>
                                                                            BookMain(
                                                                                booksInformation: bookInform
                                                                                    .data),
                                                                      ),
                                                                    ) : Container();
                                                                  },
                                                                  child: Row(
                                                                    children: <
                                                                        Widget>[
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal: 12,
                                                                            vertical: 10),
                                                                        child: Image(
                                                                            height: 35,
                                                                            image: AssetImage(
                                                                                'assets/done.png')
                                                                        ),
                                                                      ),
                                                                      Column(
                                                                        children: <
                                                                            Widget>[
                                                                          SizedBox(
                                                                            width: MediaQuery
                                                                                .of(
                                                                                context)
                                                                                .size
                                                                                .width -
                                                                                70,
                                                                            child: Text(
                                                                              '${bookInform
                                                                                  .data
                                                                                  .title}',
                                                                              style: TextStyle(
                                                                                fontFamily: 'RobotoBold',
                                                                                color: Colors
                                                                                    .grey[700],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            height: 4,),
                                                                          SizedBox(
                                                                            width: MediaQuery
                                                                                .of(
                                                                                context)
                                                                                .size
                                                                                .width -
                                                                                70,
                                                                            child: Text(
                                                                              '${bookInform
                                                                                  .data
                                                                                  .author}',
                                                                              style: TextStyle(
                                                                                  fontFamily: 'RobotoLight',
                                                                                  color: Colors
                                                                                      .grey[700],
                                                                                  fontSize: 13
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                        );
                                                      } else {
                                                        return SafeArea(
                                                            child: Container(
                                                              width: MediaQuery
                                                                  .of(context)
                                                                  .size
                                                                  .width,
                                                              child: Card(
                                                                elevation: 1,
                                                                child: InkWell(
                                                                  onTap: () {},
                                                                  child: Row(
                                                                    children: <
                                                                        Widget>[
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal: 12,
                                                                            vertical: 10),
                                                                        child: Image(
                                                                            height: 35,
                                                                            image: AssetImage(
                                                                                'assets/done.png')
                                                                        ),
                                                                      ),
                                                                      Column(
                                                                        children: <
                                                                            Widget>[
                                                                          Center(
                                                                              child: SpinKitThreeBounce(
                                                                                color: Colors
                                                                                    .brown[300],
                                                                                size: 10,
                                                                              )
                                                                          )
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                        );
                                                      }
                                                    }
                                                );
                                              },
                                            )
                                                : Center(
                                              child: Text(
                                                'You do not finish any book',
                                                style: TextStyle(
                                                    fontFamily: 'RobotoMedium',
                                                    fontSize: 17,
                                                    color: Colors.grey[600]
                                                ),
                                              ),
                                            );
                                          } else {
                                            return Center(
                                                child: SpinKitCircle(
                                                  color: Color(0xFF213a8f),
                                                  size: 40,
                                                ));
                                          }
                                        }
                                    ),
                                    FutureBuilder(
                                        future: getUserFinishedBooksWithDeleted(
                                            http.Client(), ans.userId,
                                            globals.accessTokenG),
                                        builder: (context, userFinished) {
                                          if (userFinished.hasData) {
                                            String finishedBody = utf8.decode(
                                                userFinished.data.bodyBytes);
                                            dynamic finishedList = jsonDecode(
                                                finishedBody);

                                            void showFullText(String reviewId){
                                              setState(() {
                                                if (isClosed[reviewId] == null){
                                                  isClosed[reviewId] = false;
                                                }
                                                isClosed[reviewId] = !isClosed[reviewId];
                                              });
                                            }

                                            return finishedList.length != 0
                                                ? ListView.builder(
                                              itemCount: finishedList.length,
                                              itemBuilder: (context, index) {
                                                return FutureBuilder<
                                                    BooksInformation>(
                                                    future: getBookDetailsWithDeleted(
                                                        finishedList[index]['bookId'],
                                                        globals.accessTokenG),
                                                    builder: (context, bookInform) {
                                                      if (bookInform.hasData) {
                                                        return SafeArea(
                                                          child: Container(
                                                            width: MediaQuery
                                                                .of(context)
                                                                .size
                                                                .width,
                                                            child: Card(
                                                              elevation: 1,
                                                              child: InkWell(
                                                                onTap: () {
                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (
                                                                          context) =>
                                                                          UserBookGrading(
                                                                            finishedUserBook: finishedList[index],
                                                                            booksInformation: bookInform
                                                                                .data,
                                                                            guestId: ans
                                                                                .userId,),
                                                                    ),
                                                                  ).then((value) {
                                                                    //getBookDetails();
                                                                    refreshState();
                                                                  });
                                                                },
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment
                                                                      .start,
                                                                  crossAxisAlignment: CrossAxisAlignment
                                                                      .start,
                                                                  children: <
                                                                      Widget>[
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal: 12,
                                                                          vertical: 10),
                                                                      child: Image(
                                                                          height: 35,
                                                                          image: AssetImage(
                                                                              'assets/done.png')
                                                                      ),
                                                                    ),
                                                                    Column(
                                                                      children: <
                                                                          Widget>[
                                                                        SizedBox(
                                                                          height: 15,),
                                                                        SizedBox(
                                                                          width: MediaQuery
                                                                              .of(
                                                                              context)
                                                                              .size
                                                                              .width -
                                                                              70,
                                                                          child: SingleChildScrollView(
                                                                            scrollDirection: Axis
                                                                                .horizontal,
                                                                            child: Text(
                                                                              '${bookInform
                                                                                  .data
                                                                                  .title}',
                                                                              style: TextStyle(
                                                                                  fontFamily: 'RobotoBold',
                                                                                  fontSize: 14,
                                                                                  color: Colors
                                                                                      .grey[600]
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width: MediaQuery
                                                                              .of(
                                                                              context)
                                                                              .size
                                                                              .width -
                                                                              70,
                                                                          height: 20,
                                                                          child: RatingBarIndicator(
                                                                            rating: finishedList[index]['bookRating'],
                                                                            itemBuilder: (
                                                                                context,
                                                                                index) =>
                                                                                Icon(
                                                                                  Icons.star,
                                                                                  color: Colors.amber[800],
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
                                                                              70,
                                                                          child: Column(
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              isClosed[finishedList[index]['id']] != null
                                                                                  && isClosed[finishedList[index]['id']] == true ? Text(
                                                                                finishedList[index]['bookReview'],
                                                                                style: TextStyle(
                                                                                    fontFamily: 'RobotoMedium',
                                                                                    color: Colors
                                                                                        .grey[700],
                                                                                    fontSize: 15
                                                                                ),
                                                                              )
                                                                              : Text(
                                                                                finishedList[index]['bookReview'].toString().substring(0, 30),
                                                                                style: TextStyle(
                                                                                    fontFamily: 'RobotoMedium',
                                                                                    color: Colors
                                                                                        .grey[700],
                                                                                    fontSize: 15
                                                                                ),
                                                                              ),
                                                                              GestureDetector(
                                                                                child: Text(
                                                                                    isClosed[finishedList[index]['id']] != null
                                                                                        && isClosed[finishedList[index]['id']] == true ? '...less'
                                                                                        : '...more',
                                                                                    style: TextStyle(color: Colors.yellow[800])
                                                                                ),
                                                                                onTap: () => showFullText(finishedList[index]['id']),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          height: 10,),
                                                                        SizedBox(
                                                                          width: MediaQuery
                                                                              .of(
                                                                              context)
                                                                              .size
                                                                              .width -
                                                                              70,
                                                                          child: Row(
                                                                            children: [
                                                                              Text(
                                                                                'Admin rate: ',
                                                                                style: TextStyle(
                                                                                    fontFamily: 'RobotoRegular',
                                                                                    color: Colors
                                                                                        .grey[700],
                                                                                    fontSize: 15
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                finishedList[index]['checkRated'] ==
                                                                                    true
                                                                                    ? finishedList[index]['gotPoint']
                                                                                    .toString()
                                                                                    : 'not graded yet',
                                                                                style: TextStyle(
                                                                                    fontFamily: 'RobotoBold',
                                                                                    color: finishedList[index]['checkRated'] ==
                                                                                        true
                                                                                        ? finishedList[index]['gotPoint'] >=
                                                                                        0.0
                                                                                        ? Colors
                                                                                        .cyan[800]
                                                                                        : Colors
                                                                                        .red
                                                                                        : Colors
                                                                                        .yellow[900],
                                                                                    fontSize: 15
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          height: 15,),
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        return SafeArea(
                                                            child: Container(
                                                              width: MediaQuery
                                                                  .of(context)
                                                                  .size
                                                                  .width,
                                                              child: Card(
                                                                elevation: 1,
                                                                child: InkWell(
                                                                  onTap: () {},
                                                                  child: Row(
                                                                    children: <
                                                                        Widget>[
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal: 12,
                                                                            vertical: 10),
                                                                        child: Image(
                                                                            height: 35,
                                                                            image: AssetImage(
                                                                                'assets/done.png')
                                                                        ),
                                                                      ),
                                                                      Column(
                                                                        children: <
                                                                            Widget>[
                                                                          Center(
                                                                              child: SpinKitThreeBounce(
                                                                                color: Colors
                                                                                    .brown[300],
                                                                                size: 10,
                                                                              )
                                                                          )
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                        );
                                                      }
                                                    }
                                                );
                                              },
                                            )
                                                : Center(
                                              child: Text(
                                                'You do not reviewed any book',
                                                style: TextStyle(
                                                    fontFamily: 'RobotoMedium',
                                                    fontSize: 17,
                                                    color: Colors.grey[600]
                                                ),
                                              ),
                                            );
                                          } else {
                                            return Center(
                                                child: SpinKitCircle(
                                                  color: Color(0xFF213a8f),
                                                  size: 40,
                                                ));
                                          }
                                        }
                                    ),
                                    Column(
                                      children: <Widget>[
                                        SizedBox(height: 10,),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 0, 10, 5),
                                          child: Container(
                                            height: 45,
                                            child: FlatButton(
                                              color: Colors.brown[300],
                                              onPressed: () {
                                                bookAuthor.text = '';
                                                bookName.text = '';
                                                // sss = Text('');
                                                showDialog(
                                                  context: context,
    builder: (BuildContext context) { return AnimatedContainer(
                                                    margin: MediaQuery
                                                        .of(context)
                                                        .viewInsets,
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    child: StatefulBuilder(
                                                      builder: (context, setState) {
                                                        return AlertDialog(
                                                          content: Container(
                                                              height: 215,
                                                              child: Form(
                                                                key: _key,
                                                                // ignore: deprecated_member_use
                                                                autovalidate: _validate,
                                                                child: SingleChildScrollView(
                                                                  scrollDirection: Axis
                                                                      .vertical,
                                                                  child: Column(
                                                                    children: <
                                                                        Widget>[
                                                                      SizedBox(
                                                                        width: double
                                                                            .infinity,
                                                                        child: Text(
                                                                          'Book Name',
                                                                          textAlign: TextAlign
                                                                              .left,
                                                                          style: TextStyle(
                                                                            fontFamily: 'RobotoRegular',
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      TextFormField(
                                                                        autofocus: true,
                                                                        controller: bookName,
                                                                        decoration: InputDecoration(
                                                                          fillColor: Colors
                                                                              .grey
                                                                              .shade50,
                                                                        ),
                                                                        validator: validateBookName,
                                                                        onSaved: (
                                                                            String val) {
                                                                          title =
                                                                              val;
                                                                        },
                                                                      ),
                                                                      SizedBox(
                                                                        height: 20,),
                                                                      SizedBox(
                                                                        width: double
                                                                            .infinity,
                                                                        child: Text(
                                                                          'Author',
                                                                          textAlign: TextAlign
                                                                              .left,
                                                                          style: TextStyle(
                                                                            fontFamily: 'RobotoRegular',
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      TextFormField(
                                                                        decoration: InputDecoration(
                                                                          fillColor: Colors
                                                                              .grey
                                                                              .shade50,
                                                                        ),
                                                                        controller: bookAuthor,
                                                                        validator: validateAuthor,
                                                                        onSaved: (
                                                                            String val) {
                                                                          description =
                                                                              val;
                                                                        },
                                                                      ),
                                                                      SizedBox(
                                                                        height: 10,),
                                                                      Container(
                                                                        width: double
                                                                            .infinity,
                                                                        child: FlatButton(
                                                                          color: Color(
                                                                              0xFF213A8F),
                                                                          onPressed: () async {
                                                                            if (_sendToServer()) {
                                                                              status =
                                                                              await createRequest(
                                                                                  bookName
                                                                                      .text,
                                                                                  bookAuthor
                                                                                      .text,
                                                                                  globals
                                                                                      .accessTokenG);
                                                                              if (status
                                                                                  .statusCode ==
                                                                                  200) {
                                                                                bookName
                                                                                    .text =
                                                                                '';
                                                                                bookAuthor
                                                                                    .text =
                                                                                '';
                                                                                // sss = Text('');
                                                                                Navigator
                                                                                    .pop(
                                                                                    context);
                                                                                Fluttertoast
                                                                                    .showToast(
                                                                                  msg: 'Book added',
                                                                                  toastLength: Toast
                                                                                      .LENGTH_SHORT,
                                                                                  gravity: ToastGravity
                                                                                      .BOTTOM,
                                                                                );
                                                                                refreshState();
                                                                                setState(() {
                                                                                  // sss = Text('');
                                                                                });
                                                                              }
                                                                            }
                                                                            if (status !=
                                                                                null &&
                                                                                status
                                                                                    .statusCode ==
                                                                                    400) {
                                                                              setState(() {
                                                                                // sss = Text(
                                                                                //   'Title already exist!',
                                                                                //   style: TextStyle(
                                                                                //       color: Colors.red
                                                                                //   ),
                                                                                // );
                                                                              });
                                                                            }
                                                                          },
                                                                          child: Text(
                                                                            'Отправить',
                                                                            style: TextStyle(
                                                                                color: Colors
                                                                                    .white
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      //_statusWidget(counter),
                                                                      // sss
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  );}
                                                );
                                              },
                                              child: Center(
                                                child: Text(
                                                  'ADD YOUR BEST BOOK!',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontFamily: 'RobotoMedium',
                                                      color: Colors.white
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        ans.recommendationBook != null ? Expanded(
                                          child: ListView.builder(
                                            itemCount: recommendList.length,
                                            itemBuilder: (context, index) {
                                              return SafeArea(
                                                  child: Container(
                                                    width: MediaQuery
                                                        .of(context)
                                                        .size
                                                        .width,
                                                    child: Card(
                                                      elevation: 1,
                                                      child: Row(
                                                        children: <Widget>[
                                                          Padding(
                                                            padding: const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 12,
                                                                vertical: 10),
                                                            child: Image(
                                                                height: 35,
                                                                image: AssetImage(
                                                                    'assets/love.png')
                                                            ),
                                                          ),
                                                          Column(
                                                            children: <Widget>[
                                                              SizedBox(
                                                                width: MediaQuery
                                                                    .of(context)
                                                                    .size
                                                                    .width - 70,
                                                                child: Text(
                                                                  '${recommendList[index]['bookName']}',
                                                                  style: TextStyle(
                                                                    fontFamily: 'RobotoBold',
                                                                    color: Colors
                                                                        .grey[700],
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(height: 4,),
                                                              SizedBox(
                                                                width: MediaQuery
                                                                    .of(context)
                                                                    .size
                                                                    .width - 70,
                                                                child: Text(
                                                                  '${recommendList[index]['bookAuthor']}',
                                                                  style: TextStyle(
                                                                      fontFamily: 'RobotoLight',
                                                                      color: Colors
                                                                          .grey[700],
                                                                      fontSize: 13
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                              );
                                            },
                                          ),
                                        ) : Text('')
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            )
                        ),
                        drawer: MyDrawer()
                    );
                  } else {
                    return Scaffold(
                      appBar: AppBar(
                        elevation: 0,
                        title: Text(''),
                        backgroundColor: Color(0xFF213A8F),
                        automaticallyImplyLeading: false,
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
                                      expandedHeight: 249.0,
                                      flexibleSpace: FlexibleSpaceBar(
                                          background: Column(
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment
                                                    .center,
                                                children: <Widget>[
                                                  SizedBox(width: 62,),
                                                  Container(
                                                      child: Stack(
                                                          children: <Widget>[
                                                            Positioned.fill(
                                                              child: Align(
                                                                  alignment: Alignment
                                                                      .center,
                                                                  child: SpinKitCircle(
                                                                    color: Colors
                                                                        .white,
                                                                    size: 40,
                                                                  )
                                                              ),
                                                            ),
                                                            Container(
                                                                child: CircleAvatar(
                                                                  backgroundColor: Colors
                                                                      .transparent,
                                                                  backgroundImage: AssetImage(
                                                                      'assets/transparent.png'),
                                                                  radius: 50,
                                                                ),
                                                                padding: EdgeInsets
                                                                    .all(
                                                                    3.0),
                                                                decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .transparent,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                )
                                                            ),
                                                            Positioned(
                                                              bottom: 0,
                                                              right: 0,
                                                              child: Image(
                                                                image: AssetImage(
                                                                    'assets/transparent.png'),
                                                                width: 30,
                                                              ),
                                                            )
                                                          ]
                                                      )
                                                  ),
                                                  SizedBox(width: 15,),
                                                  Column(
                                                    children: <Widget>[
                                                      Icon(
                                                        Icons.star,
                                                        color: Colors.transparent,
                                                        size: 45,
                                                      ),
                                                      Text(
                                                        "",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontFamily: 'RobotoBold',
                                                            fontSize: 15
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10,),
                                              Text(
                                                "",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'RobotoBold',
                                                    fontSize: 17
                                                ),
                                              ),
                                              SizedBox(height: 5,),
                                              Text(
                                                "",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'RobotoBold',
                                                    fontSize: 15
                                                ),
                                              ),
                                              SizedBox(height: 5,),
                                              Text(
                                                "",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'RobotoBold',
                                                    fontSize: 15
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              Expanded(
                                                child: Container(
                                                  padding: EdgeInsets.only(top: 10),
                                                  width: double.infinity,
                                                  color: Colors.grey[200],
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment
                                                        .center,
                                                    children: <Widget>[
                                                      //SizedBox(width: 10,)
                                                      //SizedBox(width: 10,),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          )
                                      ),
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
                                              icon: Icon(
                                                  Icons.book,
                                                  color: Color(0xFF213A8F)),
                                              child: Text(
                                                'Reading',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'RobotoBold'
                                                ),
                                              ),
                                            ),
                                            Tab(
                                              icon: Icon(
                                                  Icons.cloud_done,
                                                  color: Color(0xFF213A8F)),
                                              child: Text(
                                                'Read',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'RobotoBold'
                                                ),
                                              ),
                                            ),
                                            Tab(
                                              icon: Icon(
                                                  Icons.receipt,
                                                  color: Color(0xFF213A8F)),
                                              child: Text(
                                                'Reviews',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'RobotoBold'
                                                ),
                                              ),
                                            ),
                                            Tab(
                                              icon: Icon(Icons.stars,
                                                  color: Color(0xFF213A8F)),
                                              child: Text(
                                                'Recommendation',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'RobotoBold'
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      pinned: true,
                                    ),
                                  ];
                                },
                                body: Container()
                            ),
                          )
                      ),
                    );
                  }
                }
            ) : FutureBuilder(
                future: getUserPlace(widget.profileDetails['id'], globals.accessTokenG),
                builder: (context, userPlaceGuest) {
                  if (userPlaceGuest.hasData) {
                    return FutureBuilder<http.Response>(
                        future: getUsersDetails(
                            http.Client(), widget.profileDetails['id'],
                            globals.accessTokenG),
                        builder: (context, userInform) {
                          if (userInform.hasData) {
                            String bodyReader = utf8.decode(userInform.data.bodyBytes);
                            ansReader = parseProfileDetails(bodyReader);
                            Map ansans = json.decode(bodyReader);
                            ansans['firstName'] =
                            ansans['firstName'] == '' ? '' : '${ansans['firstName']}';
                            ansans['lastName'] =
                            ansans['lastName'] == '' ? '' : ' ${ansans['lastName']}';
                            ansans['middleName'] = ansans['middleName'] == null
                                ? ''
                                : ' ${ansans['middleName']}';
                            return Scaffold(
                              appBar: AppBar(
                                elevation: 0,
                                title: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(
                                      '${ansans['firstName']}\'s Cabinet'),
                                ),
                                backgroundColor: Color(0xFF213A8F),
                              ),
                              body: Scaffold(
                                  backgroundColor: Color(0xFF6F6F7),
                                  body: DefaultTabController(
                                    length: 4,
                                    child: NestedScrollView(
                                      headerSliverBuilder: (BuildContext context,
                                          bool innerBoxIsScrolled) {
                                        if (ansans['readsPoint'] == null) {
                                          ansans['readsPoint'] = 0;
                                        }
                                        return <Widget>[
                                          SliverAppBar(
                                            backgroundColor: Color(0xFF213A8F),
                                            automaticallyImplyLeading: false,
                                            expandedHeight: ansans['lastName'] == '' &&
                                                ansans['middleName'] == ''
                                                ? 252.0
                                                : 256.0,
                                            flexibleSpace: FlexibleSpaceBar(
                                                background: Column(
                                                  children: <Widget>[
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .center,
                                                      children: <Widget>[
                                                        SizedBox(width: 62,),
                                                        Container(
                                                            child: Stack(
                                                                children: <Widget>[
                                                                  Container(
                                                                      child: CircleAvatar(
                                                                        backgroundColor: Colors
                                                                            .transparent,
                                                                        backgroundImage: ansans['avatar'] !=
                                                                            null && ansans['avatar'] != '' &&
                                                                            (ansans['gender'] ==
                                                                                globals.gender ||
                                                                                globals.isAdmin == 1)
                                                                            ? NetworkImage(
                                                                            ansans['avatar'])
                                                                            : ansans['gender'] ==
                                                                            1 ? AssetImage(
                                                                            'assets/profile_boy.png')
                                                                            : AssetImage(
                                                                            'assets/profile_girl.png'),
                                                                        radius: 50,
                                                                      ),
                                                                      padding: EdgeInsets
                                                                          .all(3.0),
                                                                      decoration: BoxDecoration(
                                                                        color: ansans['readsPoint'] >=
                                                                            750 &&
                                                                            ansans['readsFinishedBooks'] >=
                                                                                50 &&
                                                                            ansans['readsReviewNumber'] >=
                                                                                50
                                                                            ? Color(
                                                                            0xFFFFD700)
                                                                            : ansans['readsPoint'] >=
                                                                            300 &&
                                                                            ansans['readsFinishedBooks'] >=
                                                                                20 &&
                                                                            ansans['readsReviewNumber'] >=
                                                                                20
                                                                            &&
                                                                            (ansans['readsPoint'] <
                                                                                750 ||
                                                                                ansans['readsFinishedBooks'] <
                                                                                    50 &&
                                                                                    ansans['readsReviewNumber'] <
                                                                                        50)
                                                                            ? Color(
                                                                            0xFFC0C0C0)
                                                                            : ansans['readsPoint'] >=
                                                                            75 &&
                                                                            ansans['readsFinishedBooks'] >=
                                                                                5 &&
                                                                            ansans['readsReviewNumber'] >=
                                                                                5
                                                                            &&
                                                                            (ansans['readsPoint'] <
                                                                                300 ||
                                                                                ansans['readsFinishedBooks'] <
                                                                                    20 &&
                                                                                    ansans['readsReviewNumber'] <
                                                                                        20)
                                                                            ? Color(
                                                                            0xFFCD7F32)
                                                                            : Colors.white,
                                                                        shape: BoxShape
                                                                            .circle,
                                                                      )
                                                                  ),
                                                                  Positioned(
                                                                    bottom: 0,
                                                                    right: 0,
                                                                    child: Image(
                                                                      image: ansans['readsPoint'] >=
                                                                          750 &&
                                                                          ansans['readsFinishedBooks'] >=
                                                                              50 &&
                                                                          ansans['readsReviewNumber'] >=
                                                                              50
                                                                          ? AssetImage(
                                                                          'assets/ic_gold.png')
                                                                          : ansans['readsPoint'] >=
                                                                          300 &&
                                                                          ansans['readsFinishedBooks'] >=
                                                                              20 &&
                                                                          ansans['readsReviewNumber'] >=
                                                                              20
                                                                          &&
                                                                          (ansans['readsPoint'] <
                                                                              750 ||
                                                                              ansans['readsFinishedBooks'] <
                                                                                  50 &&
                                                                                  ansans['readsReviewNumber'] <
                                                                                      50)
                                                                          ? AssetImage(
                                                                          'assets/ic_silver.png')
                                                                          : ansans['readsPoint'] >=
                                                                          75 &&
                                                                          ansans['readsFinishedBooks'] >=
                                                                              5 &&
                                                                          ansans['readsReviewNumber'] >=
                                                                              5
                                                                          &&
                                                                          (ansans['readsPoint'] <
                                                                              300 ||
                                                                              ansans['readsFinishedBooks'] <
                                                                                  20 &&
                                                                                  ansans['readsReviewNumber'] <
                                                                                      20)
                                                                          ? AssetImage(
                                                                          'assets/ic_bronze.png')
                                                                          : AssetImage(
                                                                          'assets/transparent.png'),
                                                                      width: 30,
                                                                    ),
                                                                  )
                                                                ]
                                                            )
                                                        ),
                                                        Column(
                                                          children: <Widget>[
                                                            Container(
                                                              height: 50,
                                                              //margin: EdgeInsets.all(0),
                                                              child: IconButton(
                                                                icon: Icon(Icons.star),
                                                                color: Colors.white,
                                                                iconSize: 45,
                                                                onPressed: () {},
                                                              ),
                                                            ),
                                                            Text(
                                                              ansans['readsPoint']
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontFamily: 'RobotoBold',
                                                                  fontSize: 15
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 10,),
                                                    Text(
                                                      '${ansans['firstName']}${ansans['lastName']}${ansans['middleName']}',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontFamily: 'RobotoBold',
                                                          fontSize: 17
                                                      ),
                                                    ),
                                                    SizedBox(height: 5,),
                                                    Text(
                                                      ansans['email'] != null &&
                                                          (ansans['gender'] ==
                                                              globals.gender ||
                                                              globals.isAdmin == 1)
                                                          ? ansans['email']
                                                          : '',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontFamily: 'RobotoBold',
                                                          fontSize: 15
                                                      ),
                                                    ),
                                                    SizedBox(height: 5,),
                                                    Text(
                                                      ansans['phone'] != null &&
                                                          (ansans['gender'] ==
                                                              globals.gender ||
                                                              globals.isAdmin == 1)
                                                          ? ansans['phone']
                                                          : '',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontFamily: 'RobotoBold',
                                                          fontSize: 15
                                                      ),
                                                    ),
                                                    SizedBox(height: 10,),
                                                    Expanded(
                                                      child: Container(
                                                        // padding: EdgeInsets.only(top: 10),
                                                        width: double.infinity,
                                                        color: Colors.grey[200],
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment
                                                              .center,
                                                          children: <Widget>[
                                                            Spacer(),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment
                                                                  .center,
                                                              children: <Widget>[
                                                                //SizedBox(width: 10,),
                                                                Container(
                                                                  width: MediaQuery
                                                                      .of(context)
                                                                      .size
                                                                      .width * 0.33,
                                                                  child: Column(
                                                                    mainAxisAlignment: MainAxisAlignment
                                                                        .center,
                                                                    children: <Widget>[
                                                                      Text(
                                                                        'Rating in Group',
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .grey[700],
                                                                            fontFamily: 'RobotoMedium',
                                                                            fontSize: 15
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        userPlaceGuest.data
                                                                            .toString(),
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .grey[700],
                                                                            fontFamily: 'RobotoBold',
                                                                            fontSize: 15
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                //Spacer(),
                                                                Container(
                                                                  width: MediaQuery
                                                                      .of(context)
                                                                      .size
                                                                      .width * 0.33,
                                                                  child: Column(
                                                                    mainAxisAlignment: MainAxisAlignment
                                                                        .center,
                                                                    children: <Widget>[
                                                                      Text(
                                                                        'Group',
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .grey[700],
                                                                            fontFamily: 'RobotoMedium',
                                                                            fontSize: 15
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        'MDS Group',
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .grey[700],
                                                                            fontFamily: 'RobotoBold',
                                                                            fontSize: 15
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                //Spacer(),
                                                                Container(
                                                                  width: MediaQuery
                                                                      .of(context)
                                                                      .size
                                                                      .width * 0.34,
                                                                  child: Column(
                                                                    mainAxisAlignment: MainAxisAlignment
                                                                        .center,
                                                                    children: <Widget>[
                                                                      Text(
                                                                        'Read Books',
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .grey[700],
                                                                            fontFamily: 'RobotoMedium',
                                                                            fontSize: 15
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        ansans['readsFinishedBooks'] ==
                                                                            null
                                                                            ? '0'
                                                                            : ansans['readsFinishedBooks']
                                                                            .toString(),
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .grey[700],
                                                                            fontFamily: 'RobotoBold',
                                                                            fontSize: 15
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                //SizedBox(width: 10,),
                                                              ],
                                                            ),
                                                            Spacer(),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                )
                                            ),
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
                                                    icon: Icon(
                                                        Icons.book,
                                                        color: Color(0xFF213A8F)),
                                                    child: Text(
                                                      'Reading',
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontFamily: 'RobotoBold'
                                                      ),
                                                    ),
                                                  ),
                                                  Tab(
                                                    icon: Icon(
                                                        Icons.cloud_done,
                                                        color: Color(0xFF213A8F)),
                                                    child: Text(
                                                      'Read',
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontFamily: 'RobotoBold'
                                                      ),
                                                    ),
                                                  ),
                                                  Tab(
                                                    icon: Icon(
                                                        Icons.receipt,
                                                        color: Color(0xFF213A8F)),
                                                    child: Text(
                                                      'Reviews',
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontFamily: 'RobotoBold'
                                                      ),
                                                    ),
                                                  ),
                                                  Tab(
                                                    icon: Icon(Icons.stars,
                                                        color: Color(0xFF213A8F)),
                                                    child: Text(
                                                      'Recommendation',
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontFamily: 'RobotoBold'
                                                      ),
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
                                        children: <Widget>[
                                          FutureBuilder<http.Response>(
                                              future: getByIdUserBook(http.Client(),
                                                  ansans['id'], globals.accessTokenG),
                                              builder: (context, userBook) {
                                                if (userBook.hasData) {
                                                  String bookBody = utf8.decode(
                                                      userBook.data.bodyBytes);
                                                  dynamic bookInform = jsonDecode(
                                                      bookBody);
                                                  return bookInform != null
                                                      ? FutureBuilder<BooksInformation>(
                                                      future: getBookDetailsWithDeleted(
                                                          bookInform['bookId'],
                                                          globals.accessTokenG),
                                                      builder: (context, aboutBook) {
                                                        if (aboutBook.hasData) {
                                                          booksReading.clear();
                                                          booksReading.add(
                                                              aboutBook.data);
                                                          return ListView.builder(
                                                            itemCount: booksReading
                                                                .length,
                                                            itemBuilder: (context,
                                                                index) {
                                                              return SafeArea(
                                                                  child: Container(
                                                                    width: MediaQuery
                                                                        .of(context)
                                                                        .size
                                                                        .width,
                                                                    child: Card(
                                                                      elevation: 1,
                                                                      child: InkWell(
                                                                        onTap: () {
                                                                          booksReading[index]
                                                                              .deletedAt ==
                                                                              null ?
                                                                          Navigator
                                                                              .pushReplacement(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (
                                                                                  context) =>
                                                                                  BookMain(
                                                                                      booksInformation: booksReading[index]),
                                                                            ),
                                                                          ) : Container();
                                                                        },
                                                                        child: Row(
                                                                          children: <
                                                                              Widget>[
                                                                            Padding(
                                                                              padding: const EdgeInsets
                                                                                  .symmetric(
                                                                                  horizontal: 12,
                                                                                  vertical: 10),
                                                                              child: Image(
                                                                                  height: 35,
                                                                                  image: AssetImage(
                                                                                      'assets/notebook.png')
                                                                              ),
                                                                            ),
                                                                            Column(
                                                                              children: <
                                                                                  Widget>[
                                                                                SizedBox(
                                                                                  width: MediaQuery
                                                                                      .of(
                                                                                      context)
                                                                                      .size
                                                                                      .width -
                                                                                      70,
                                                                                  child: Text(
                                                                                    '${booksReading[index]
                                                                                        .title}',
                                                                                    style: TextStyle(
                                                                                      fontFamily: 'RobotoBold',
                                                                                      color: Colors
                                                                                          .grey[700],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 4,),
                                                                                SizedBox(
                                                                                  width: MediaQuery
                                                                                      .of(
                                                                                      context)
                                                                                      .size
                                                                                      .width -
                                                                                      70,
                                                                                  child: Text(
                                                                                    '${booksReading[index]
                                                                                        .author}',
                                                                                    style: TextStyle(
                                                                                        fontFamily: 'RobotoLight',
                                                                                        color: Colors
                                                                                            .grey[700],
                                                                                        fontSize: 13
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                              );
                                                            },
                                                          );
                                                        } else {
                                                          return Padding(
                                                            padding: const EdgeInsets.all(
                                                                4),
                                                            child: Container(
                                                              child: Card(
                                                                margin: EdgeInsets.only(
                                                                    bottom: 203),
                                                                elevation: 1,
                                                                child: InkWell(
                                                                  onTap: () {},
                                                                  child: Row(
                                                                    children: <Widget>[
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal: 12,
                                                                            vertical: 10),
                                                                        child: Image(
                                                                            height: 35,
                                                                            image: AssetImage(
                                                                                'assets/notebook.png')
                                                                        ),
                                                                      ),
                                                                      Center(
                                                                          child: SpinKitThreeBounce(
                                                                            color: Colors
                                                                                .brown[300],
                                                                            size: 10,
                                                                          )
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      }
                                                  )
                                                      : Center(
                                                    child: Text(
                                                      '${ansans['firstName']} does not have a reading book',
                                                      style: TextStyle(
                                                          fontFamily: 'RobotoMedium',
                                                          fontSize: 17,
                                                          color: Colors.grey[600]
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  return Center(
                                                      child: SpinKitCircle(
                                                        color: Color(0xFF213a8f),
                                                        size: 40,
                                                      ));
                                                }
                                              }
                                          ),
                                          FutureBuilder(
                                              future: getUserFinishedBooksWithDeleted(
                                                  http.Client(),
                                                  ansans['id'], globals.accessTokenG),
                                              builder: (context, userFinished) {
                                                if (userFinished.hasData) {
                                                  String finishedBody = utf8.decode(
                                                      userFinished.data.bodyBytes);
                                                  dynamic finishedList = jsonDecode(
                                                      finishedBody);
                                                  return finishedList.length != 0
                                                      ? ListView.builder(
                                                    itemCount: finishedList.length,
                                                    itemBuilder: (context, index) {
                                                      return FutureBuilder<
                                                          BooksInformation>(
                                                          future: getBookDetailsWithDeleted(
                                                              finishedList[index]['bookId'],
                                                              globals.accessTokenG),
                                                          builder: (context,
                                                              bookInform) {
                                                            if (bookInform.hasData) {
                                                              return SafeArea(
                                                                  child: Container(
                                                                    width: MediaQuery
                                                                        .of(context)
                                                                        .size
                                                                        .width,
                                                                    child: Card(
                                                                      elevation: 1,
                                                                      child: InkWell(
                                                                        onTap: () {
                                                                          bookInform.data
                                                                              .deletedAt ==
                                                                              null ?
                                                                          Navigator
                                                                              .pushReplacement(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (
                                                                                  context) =>
                                                                                  BookMain(
                                                                                      booksInformation: bookInform
                                                                                          .data),
                                                                            ),
                                                                          ) : Container();
                                                                        },
                                                                        child: Row(
                                                                          children: <
                                                                              Widget>[
                                                                            Padding(
                                                                              padding: const EdgeInsets
                                                                                  .symmetric(
                                                                                  horizontal: 12,
                                                                                  vertical: 10),
                                                                              child: Image(
                                                                                  height: 35,
                                                                                  image: AssetImage(
                                                                                      'assets/done.png')
                                                                              ),
                                                                            ),
                                                                            Column(
                                                                              children: <
                                                                                  Widget>[
                                                                                SizedBox(
                                                                                  width: MediaQuery
                                                                                      .of(
                                                                                      context)
                                                                                      .size
                                                                                      .width -
                                                                                      70,
                                                                                  child: Text(
                                                                                    '${bookInform
                                                                                        .data
                                                                                        .title}',
                                                                                    style: TextStyle(
                                                                                      fontFamily: 'RobotoBold',
                                                                                      color: Colors
                                                                                          .grey[700],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 4,),
                                                                                SizedBox(
                                                                                  width: MediaQuery
                                                                                      .of(
                                                                                      context)
                                                                                      .size
                                                                                      .width -
                                                                                      70,
                                                                                  child: Text(
                                                                                    '${bookInform
                                                                                        .data
                                                                                        .author}',
                                                                                    style: TextStyle(
                                                                                        fontFamily: 'RobotoLight',
                                                                                        color: Colors
                                                                                            .grey[700],
                                                                                        fontSize: 13
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                              );
                                                            } else {
                                                              return SafeArea(
                                                                  child: Container(
                                                                    width: MediaQuery
                                                                        .of(context)
                                                                        .size
                                                                        .width,
                                                                    child: Card(
                                                                      elevation: 1,
                                                                      child: InkWell(
                                                                        onTap: () {},
                                                                        child: Row(
                                                                          children: <
                                                                              Widget>[
                                                                            Padding(
                                                                              padding: const EdgeInsets
                                                                                  .symmetric(
                                                                                  horizontal: 12,
                                                                                  vertical: 10),
                                                                              child: Image(
                                                                                  height: 35,
                                                                                  image: AssetImage(
                                                                                      'assets/done.png')
                                                                              ),
                                                                            ),
                                                                            Column(
                                                                              children: <
                                                                                  Widget>[
                                                                                Center(
                                                                                    child: SpinKitThreeBounce(
                                                                                      color: Colors
                                                                                          .brown[300],
                                                                                      size: 10,
                                                                                    )
                                                                                )
                                                                              ],
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                              );
                                                            }
                                                          }
                                                      );
                                                    },
                                                  )
                                                      : Center(
                                                    child: Text(
                                                      '${ansans['firstName']} does not finish any book',
                                                      style: TextStyle(
                                                          fontFamily: 'RobotoMedium',
                                                          fontSize: 17,
                                                          color: Colors.grey[600]
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  return Center(
                                                      child: SpinKitCircle(
                                                        color: Color(0xFF213a8f),
                                                        size: 40,
                                                      ));
                                                }
                                              }
                                          ),
                                          FutureBuilder(
                                              future: getUserFinishedBooksWithDeleted(
                                                  http.Client(),
                                                  ansans['id'], globals.accessTokenG),
                                              builder: (context, userFinished) {
                                                if (userFinished.hasData) {
                                                  String finishedBody = utf8.decode(
                                                      userFinished.data.bodyBytes);
                                                  dynamic finishedList = jsonDecode(
                                                      finishedBody);

                                                  void showFullText(String reviewId){
                                                    setState(() {
                                                      if (isClosed[reviewId] == null){
                                                        isClosed[reviewId] = false;
                                                      }
                                                      isClosed[reviewId] = !isClosed[reviewId];
                                                    });
                                                  }


                                                  return finishedList.length != 0
                                                      ? ListView.builder(
                                                    itemCount: finishedList.length,
                                                    itemBuilder: (context, index) {
                                                      return FutureBuilder<
                                                          BooksInformation>(
                                                          future: getBookDetailsWithDeleted(
                                                              finishedList[index]['bookId'],
                                                              globals.accessTokenG),
                                                          builder: (context,
                                                              bookInform) {
                                                            if (bookInform.hasData) {
                                                              return SafeArea(
                                                                child: Container(
                                                                  width: MediaQuery.of(context).size.width,
                                                                  child: Card(
                                                                    elevation: 1,
                                                                    child: InkWell(
                                                                      onTap: () {
                                                                        Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (
                                                                                context) =>
                                                                                UserBookGrading(
                                                                                  finishedUserBook: finishedList[index],
                                                                                  booksInformation: bookInform
                                                                                      .data,
                                                                                  guestId: ans
                                                                                      .userId,),
                                                                          ),
                                                                        ).then((value) {
                                                                          //getBookDetails();
                                                                          refreshState();
                                                                        });
                                                                      },
                                                                      child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment
                                                                            .start,
                                                                        crossAxisAlignment: CrossAxisAlignment
                                                                            .start,
                                                                        children: <
                                                                            Widget>[
                                                                          Padding(
                                                                            padding: const EdgeInsets
                                                                                .symmetric(
                                                                                horizontal: 12,
                                                                                vertical: 10),
                                                                            child: Image(
                                                                                height: 35,
                                                                                image: AssetImage(
                                                                                    'assets/done.png')
                                                                            ),
                                                                          ),
                                                                          Column(
                                                                            children: <
                                                                                Widget>[
                                                                              SizedBox(
                                                                                height: 15,),
                                                                              SizedBox(
                                                                                width: MediaQuery
                                                                                    .of(
                                                                                    context)
                                                                                    .size
                                                                                    .width -
                                                                                    70,
                                                                                child: Text(
                                                                                  '${bookInform
                                                                                      .data
                                                                                      .title}',
                                                                                  style: TextStyle(
                                                                                      fontFamily: 'RobotoBold',
                                                                                      fontSize: 14,
                                                                                      color: Colors
                                                                                          .grey[600]
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: MediaQuery
                                                                                    .of(
                                                                                    context)
                                                                                    .size
                                                                                    .width -
                                                                                    70,
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
                                                                                    70,
                                                                                child:
                                                                                Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    isClosed[finishedList[index]['id']] != null
                                                                                        && isClosed[finishedList[index]['id']] == true ? Text(
                                                                                      finishedList[index]['bookReview'],
                                                                                      style: TextStyle(
                                                                                          fontFamily: 'RobotoMedium',
                                                                                          color: Colors
                                                                                              .grey[700],
                                                                                          fontSize: 15
                                                                                      ),
                                                                                    )
                                                                                        : Text(
                                                                                      finishedList[index]['bookReview'].toString().substring(0, 90)+'...',
                                                                                      style: TextStyle(
                                                                                          fontFamily: 'RobotoMedium',
                                                                                          color: Colors
                                                                                              .grey[700],
                                                                                          fontSize: 15
                                                                                      ),
                                                                                    ),
                                                                                    GestureDetector(
                                                                                      child: Text(
                                                                                          isClosed[finishedList[index]['id']] != null
                                                                                              && isClosed[finishedList[index]['id']] == true ? '...less'
                                                                                          : '...more',
                                                                                          style: TextStyle(color: Colors.yellow[800])
                                                                                      ),
                                                                                      onTap: () => showFullText(finishedList[index]['id']),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 10,),
                                                                              SizedBox(
                                                                                width: MediaQuery
                                                                                    .of(
                                                                                    context)
                                                                                    .size
                                                                                    .width -
                                                                                    70,
                                                                                child: Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      'Admin rate: ',
                                                                                      style: TextStyle(
                                                                                          fontFamily: 'RobotoRegular',
                                                                                          color: Colors
                                                                                              .grey[700],
                                                                                          fontSize: 15
                                                                                      ),
                                                                                    ),
                                                                                    Text(
                                                                                      finishedList[index]['checkRated'] ==
                                                                                          true
                                                                                          ? finishedList[index]['gotPoint']
                                                                                          .toString()
                                                                                          : 'not graded yet',
                                                                                      style: TextStyle(
                                                                                          fontFamily: 'RobotoBold',
                                                                                          color: finishedList[index]['checkRated'] ==
                                                                                              true
                                                                                              ? finishedList[index]['gotPoint'] >=
                                                                                              0.0
                                                                                              ? Colors
                                                                                              .cyan[800]
                                                                                              : Colors
                                                                                              .red
                                                                                              : Colors
                                                                                              .yellow[900],
                                                                                          fontSize: 15
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 15,),
                                                                            ],
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            } else {
                                                              return SafeArea(
                                                                  child: Container(
                                                                    width: MediaQuery
                                                                        .of(context)
                                                                        .size
                                                                        .width,
                                                                    child: Card(
                                                                      elevation: 1,
                                                                      child: InkWell(
                                                                        onTap: () {},
                                                                        child: Row(
                                                                          children: <
                                                                              Widget>[
                                                                            Padding(
                                                                              padding: const EdgeInsets
                                                                                  .symmetric(
                                                                                  horizontal: 12,
                                                                                  vertical: 10),
                                                                              child: Image(
                                                                                  height: 35,
                                                                                  image: AssetImage(
                                                                                      'assets/done.png')
                                                                              ),
                                                                            ),
                                                                            Column(
                                                                              children: <
                                                                                  Widget>[
                                                                                Center(
                                                                                    child: SpinKitThreeBounce(
                                                                                      color: Colors
                                                                                          .brown[300],
                                                                                      size: 10,
                                                                                    )
                                                                                )
                                                                              ],
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                              );
                                                            }
                                                          }
                                                      );
                                                    },
                                                  ) : Center(
                                                    child: Text(
                                                      '${ansans['firstName']} does not reviewed any book',
                                                      style: TextStyle(
                                                          fontFamily: 'RobotoMedium',
                                                          fontSize: 17,
                                                          color: Colors.grey[600]
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  return Center(
                                                      child: SpinKitCircle(
                                                        color: Color(0xFF213a8f),
                                                        size: 40,
                                                      ));
                                                }
                                              }
                                          ),
                                          Column(
                                            children: <Widget>[
                                              SizedBox(height: 10,),
                                              ansans['recommendationBook'] !=
                                                  null ? Expanded(
                                                child: ListView.builder(
                                                  itemCount: recommendList2.length,
                                                  itemBuilder: (context, index) {
                                                    return SafeArea(
                                                        child: Container(
                                                          width: MediaQuery
                                                              .of(context)
                                                              .size
                                                              .width,
                                                          child: Card(
                                                            elevation: 1,
                                                            child: Row(
                                                              children: <Widget>[
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal: 12,
                                                                      vertical: 10),
                                                                  child: Image(
                                                                      height: 35,
                                                                      image: AssetImage(
                                                                          'assets/love.png')
                                                                  ),
                                                                ),
                                                                Column(
                                                                  children: <Widget>[
                                                                    SizedBox(
                                                                      width: MediaQuery
                                                                          .of(context)
                                                                          .size
                                                                          .width - 70,
                                                                      child: Text(
                                                                        '${recommendList2[index]['bookName']}',
                                                                        style: TextStyle(
                                                                          fontFamily: 'RobotoBold',
                                                                          color: Colors
                                                                              .grey[700],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 4,),
                                                                    SizedBox(
                                                                      width: MediaQuery
                                                                          .of(context)
                                                                          .size
                                                                          .width - 70,
                                                                      child: Text(
                                                                        '${recommendList2[index]['bookAuthor']}',
                                                                        style: TextStyle(
                                                                            fontFamily: 'RobotoLight',
                                                                            color: Colors
                                                                                .grey[700],
                                                                            fontSize: 13
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                    );
                                                  },
                                                ),
                                              ) : Text('')
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                              ),
                            );
                          } else {
                            return Scaffold(
                              appBar: AppBar(
                                elevation: 0,
                                title: Text(''),
                                backgroundColor: Color(0xFF213A8F),
                                automaticallyImplyLeading: false,
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
                                              expandedHeight: 249.0,
                                              flexibleSpace: FlexibleSpaceBar(
                                                  background: Column(
                                                    children: <Widget>[
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment
                                                            .center,
                                                        children: <Widget>[
                                                          SizedBox(width: 62,),
                                                          Container(

                                                              child: Stack(
                                                                  children: <Widget>[
                                                                    Positioned.fill(
                                                                      child: Align(
                                                                          alignment: Alignment
                                                                              .center,
                                                                          child: SpinKitCircle(
                                                                            color: Colors
                                                                                .white,
                                                                            size: 40,
                                                                          )
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                        child: CircleAvatar(
                                                                          backgroundColor: Colors
                                                                              .transparent,
                                                                          backgroundImage: AssetImage(
                                                                              'assets/transparent.png'),
                                                                          radius: 50,
                                                                        ),
                                                                        padding: EdgeInsets
                                                                            .all(
                                                                            3.0),
                                                                        decoration: BoxDecoration(
                                                                          color: Colors
                                                                              .transparent,
                                                                          shape: BoxShape
                                                                              .circle,
                                                                        )
                                                                    ),
                                                                    Positioned(
                                                                      bottom: 0,
                                                                      right: 0,
                                                                      child: Image(
                                                                        image: AssetImage(
                                                                            'assets/transparent.png'),
                                                                        width: 30,
                                                                      ),
                                                                    )
                                                                  ]
                                                              )
                                                          ),
                                                          SizedBox(width: 15,),
                                                          Column(
                                                            children: <Widget>[
                                                              Icon(
                                                                Icons.star,
                                                                color: Colors.transparent,
                                                                size: 45,
                                                              ),
                                                              Text(
                                                                "",
                                                                style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontFamily: 'RobotoBold',
                                                                    fontSize: 15
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Text(
                                                        "",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontFamily: 'RobotoBold',
                                                            fontSize: 17
                                                        ),
                                                      ),
                                                      SizedBox(height: 5,),
                                                      Text(
                                                        "",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontFamily: 'RobotoBold',
                                                            fontSize: 15
                                                        ),
                                                      ),
                                                      SizedBox(height: 5,),
                                                      Text(
                                                        "",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontFamily: 'RobotoBold',
                                                            fontSize: 15
                                                        ),
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Expanded(
                                                        child: Container(
                                                          padding: EdgeInsets.only(top: 10),
                                                          width: double.infinity,
                                                          color: Colors.grey[200],
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment
                                                                .center,
                                                            children: <Widget>[
                                                              //SizedBox(width: 10,)
                                                              //SizedBox(width: 10,),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  )
                                              ),
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
                                                      icon: Icon(
                                                          Icons.book,
                                                          color: Color(0xFF213A8F)),
                                                      child: Text(
                                                        'Reading',
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            fontFamily: 'RobotoBold'
                                                        ),
                                                      ),
                                                    ),
                                                    Tab(
                                                      icon: Icon(
                                                          Icons.cloud_done,
                                                          color: Color(0xFF213A8F)),
                                                      child: Text(
                                                        'Read',
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            fontFamily: 'RobotoBold'
                                                        ),
                                                      ),
                                                    ),
                                                    Tab(
                                                      icon: Icon(
                                                          Icons.receipt,
                                                          color: Color(0xFF213A8F)),
                                                      child: Text(
                                                        'Reviews',
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            fontFamily: 'RobotoBold'
                                                        ),
                                                      ),
                                                    ),
                                                    Tab(
                                                      icon: Icon(Icons.stars,
                                                          color: Color(0xFF213A8F)),
                                                      child: Text(
                                                        'Recommendation',
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            fontFamily: 'RobotoBold'
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              pinned: true,
                                            ),
                                          ];
                                        },
                                        body: Container()
                                    ),
                                  )
                              ),
                            );
                          }
                        }
                    );
                  } else {
                    return Scaffold(
                      appBar: AppBar(
                        elevation: 0,
                        title: Text(''),
                        backgroundColor: Color(0xFF213A8F),
                        automaticallyImplyLeading: false,
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
                                      expandedHeight: 249.0,
                                      flexibleSpace: FlexibleSpaceBar(
                                          background: Column(
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  SizedBox(width: 62,),
                                                  Container(
                                                      child: Stack(
                                                          children: <Widget>[
                                                            Positioned.fill(
                                                              child: Align(
                                                                  alignment: Alignment
                                                                      .center,
                                                                  child: SpinKitCircle(
                                                                    color: Colors.white,
                                                                    size: 40,
                                                                  )
                                                              ),
                                                            ),
                                                            Container(
                                                                child: CircleAvatar(
                                                                  backgroundColor: Colors
                                                                      .transparent,
                                                                  backgroundImage: AssetImage(
                                                                      'assets/transparent.png'),
                                                                  radius: 50,
                                                                ),
                                                                padding: EdgeInsets.all(
                                                                    3.0),
                                                                decoration: BoxDecoration(
                                                                  color: Colors.transparent,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                )
                                                            ),
                                                            Positioned(
                                                              bottom: 0,
                                                              right: 0,
                                                              child: Image(
                                                                image: AssetImage(
                                                                    'assets/transparent.png'),
                                                                width: 30,
                                                              ),
                                                            )
                                                          ]
                                                      )
                                                  ),
                                                  SizedBox(width: 15,),
                                                  Column(
                                                    children: <Widget>[
                                                      Icon(
                                                        Icons.star,
                                                        color: Colors.transparent,
                                                        size: 45,
                                                      ),
                                                      Text(
                                                        "",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontFamily: 'RobotoBold',
                                                            fontSize: 15
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10,),
                                              Text(
                                                "",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'RobotoBold',
                                                    fontSize: 17
                                                ),
                                              ),
                                              SizedBox(height: 5,),
                                              Text(
                                                "",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'RobotoBold',
                                                    fontSize: 15
                                                ),
                                              ),
                                              SizedBox(height: 5,),
                                              Text(
                                                "",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'RobotoBold',
                                                    fontSize: 15
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              Expanded(
                                                child: Container(
                                                  padding: EdgeInsets.only(top: 10),
                                                  width: double.infinity,
                                                  color: Colors.grey[200],
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment
                                                        .center,
                                                    children: <Widget>[
                                                      //SizedBox(width: 10,)
                                                      //SizedBox(width: 10,),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          )
                                      ),
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
                                              icon: Icon(
                                                  Icons.book,
                                                  color: Color(0xFF213A8F)),
                                              child: Text(
                                                'Reading',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'RobotoBold'
                                                ),
                                              ),
                                            ),
                                            Tab(
                                              icon: Icon(
                                                  Icons.cloud_done,
                                                  color: Color(0xFF213A8F)),
                                              child: Text(
                                                'Read',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'RobotoBold'
                                                ),
                                              ),
                                            ),
                                            Tab(
                                              icon: Icon(
                                                  Icons.receipt,
                                                  color: Color(0xFF213A8F)),
                                              child: Text(
                                                'Reviews',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'RobotoBold'
                                                ),
                                              ),
                                            ),
                                            Tab(
                                              icon: Icon(Icons.stars,
                                                  color: Color(0xFF213A8F)),
                                              child: Text(
                                                'Recommendation',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'RobotoBold'
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      pinned: true,
                                    ),
                                  ];
                                },
                                body: Container()
                            ),
                          )
                      ),
                    );
                  }
                }
            );
          } else if(snapshot.data == 1) {
            return ErrorPage();
          } else {
            return Scaffold(
              appBar: AppBar(
                elevation: 0,
                title: Text(''),
                backgroundColor: Color(0xFF213A8F),
                automaticallyImplyLeading: false,
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
                              expandedHeight: 249.0,
                              flexibleSpace: FlexibleSpaceBar(
                                  background: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: <Widget>[
                                          SizedBox(width: 62,),
                                          Container(
                                              child: Stack(
                                                  children: <Widget>[
                                                    Positioned.fill(
                                                      child: Align(
                                                          alignment: Alignment
                                                              .center,
                                                          child: SpinKitCircle(
                                                            color: Colors
                                                                .white,
                                                            size: 40,
                                                          )
                                                      ),
                                                    ),
                                                    Container(
                                                        child: CircleAvatar(
                                                          backgroundColor: Colors
                                                              .transparent,
                                                          backgroundImage: AssetImage(
                                                              'assets/transparent.png'),
                                                          radius: 50,
                                                        ),
                                                        padding: EdgeInsets
                                                            .all(
                                                            3.0),
                                                        decoration: BoxDecoration(
                                                          color: Colors
                                                              .transparent,
                                                          shape: BoxShape
                                                              .circle,
                                                        )
                                                    ),
                                                    Positioned(
                                                      bottom: 0,
                                                      right: 0,
                                                      child: Image(
                                                        image: AssetImage(
                                                            'assets/transparent.png'),
                                                        width: 30,
                                                      ),
                                                    )
                                                  ]
                                              )
                                          ),
                                          SizedBox(width: 15,),
                                          Column(
                                            children: <Widget>[
                                              Icon(
                                                Icons.star,
                                                color: Colors.transparent,
                                                size: 45,
                                              ),
                                              Text(
                                                "",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'RobotoBold',
                                                    fontSize: 15
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      Text(
                                        "",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'RobotoBold',
                                            fontSize: 17
                                        ),
                                      ),
                                      SizedBox(height: 5,),
                                      Text(
                                        "",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'RobotoBold',
                                            fontSize: 15
                                        ),
                                      ),
                                      SizedBox(height: 5,),
                                      Text(
                                        "",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'RobotoBold',
                                            fontSize: 15
                                        ),
                                      ),
                                      SizedBox(height: 10,),
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.only(top: 10),
                                          width: double.infinity,
                                          color: Colors.grey[200],
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .center,
                                            children: <Widget>[
                                              //SizedBox(width: 10,)
                                              //SizedBox(width: 10,),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                              ),
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
                                      icon: Icon(
                                          Icons.book,
                                          color: Color(0xFF213A8F)),
                                      child: Text(
                                        'Reading',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontFamily: 'RobotoBold'
                                        ),
                                      ),
                                    ),
                                    Tab(
                                      icon: Icon(
                                          Icons.cloud_done,
                                          color: Color(0xFF213A8F)),
                                      child: Text(
                                        'Read',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontFamily: 'RobotoBold'
                                        ),
                                      ),
                                    ),
                                    Tab(
                                      icon: Icon(
                                          Icons.receipt,
                                          color: Color(0xFF213A8F)),
                                      child: Text(
                                        'Reviews',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontFamily: 'RobotoBold'
                                        ),
                                      ),
                                    ),
                                    Tab(
                                      icon: Icon(Icons.stars,
                                          color: Color(0xFF213A8F)),
                                      child: Text(
                                        'Recommendation',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontFamily: 'RobotoBold'
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              pinned: true,
                            ),
                          ];
                        },
                        body: Container()
                    ),
                  )
              ),
            );
          }
        }
    );
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

