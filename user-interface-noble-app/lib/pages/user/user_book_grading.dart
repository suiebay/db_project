import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:mds_reads/pages/books/books_information.dart';
import 'dart:convert';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:mds_reads/globals.dart' as globals;

dynamic canCheck;

Future<http.Response> postReview(String id, String bookReview,
    double bookRating, String bookId, String profileId, String token) async {
  Box box = Hive.box('config');
  var url;
  if (Platform.isAndroid)
    url = '${box.get('url')}/api/project/mdsreads/userbook/finish';
  else if (Platform.isIOS)
    url = '${box.get('url')}/api/project/mdsreads/userbook/finish';

  Map data = {
    'id': id,
    'bookReview': bookReview,
    'bookRating': bookRating,
    'bookId': bookId,
    'profileId': profileId,
  };
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

Future<http.Response> rateUserBook(
    String id,
    String bookReview,
    int adminPoint,
    int gotPoint,
    String bookId,
    double bookRating,
    String profileId,
    String token) async {
  Box box = Hive.box('config');
  var url;
  if (Platform.isAndroid)
    url = '${box.get('url')}/api/project/mdsreads/userbook/rate';
  else if (Platform.isIOS)
    url = '${box.get('url')}/api/project/mdsreads/userbook/rate';

  Map data = {
    'id': id,
    'bookReview': bookReview,
    'adminPoint': adminPoint,
    'gotPoint': gotPoint,
    'bookId': bookId,
    'bookRating': bookRating,
    'profileId': profileId
  };
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

getStringValuesSF(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String stringValue = prefs.getString(key);
  return stringValue;
}

// ignore: must_be_immutable
class UserBookGrading extends StatefulWidget {
  dynamic finishedUserBook;
  BooksInformation booksInformation;
  String guestId;

  UserBookGrading({this.finishedUserBook, this.booksInformation, this.guestId});

  @override
  _UserBookGradingState createState() => _UserBookGradingState();
}

class _UserBookGradingState extends State<UserBookGrading> {
  final adminRate = TextEditingController();
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  var status;
  var setRating;
  final bookReview = TextEditingController();
  var counter = 0;

  Map isClosed = Map<String, bool>();

  Future<http.Response> getCanCheck(
      http.Client client, String id, String token) async {
    Box box = Hive.box('config');
    var url =
        '${box.get('url')}/api/project/mdsreads/groups/mentor/check/$id';

    final http.Response response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    refreshState(response.body);

    return response;
  }

  String validateAdminRate(String value) {
    var n = int.parse(adminRate.text,onError: (source) => -1);
    if (value.length == 0) {
      return "Admin rate is required";
    }
    if (n  < -100 || n > 100){
      return "Can't pass that value";
    }
    return null;
  }

  // checkAdminRateValue(dynamic val) {
  //   if (val < -15 && val > 15) {
  //     setState(() {
  //       return debugPrint("You can't rate lower -15 and higher 15");
  //     });
  //   } else {
  //     setState(() {
  //       return debugPrint("You rated $val");
  //     });
  //   }
  // }

  void refreshState(String x) {
    setState(() {
      canCheck = x;
    });
  }

  String validateReview(String value) {
    List<String> a = value.split(' ');
    int counter = 0;
    for (int i = 0; i < a.length; i++) {
      if (a[i].length > 1) {
        counter++;
      }
    }

    if (counter == 0) {
      return "Review is Required";
    } else if (counter < 50) {
      return "Review must contain minimum 50 words";
    }
    return null;
  }

  bool _sendToServer() {
    if (_key.currentState.validate()) {
      _key.currentState.save();

      return true;
    } else {
      setState(() {
        _validate = true;
      });
      return false;
    }
  }

  int _charCount = 0;

  _onChanged(String value) {
    List<String> a = value.split(' ');
    int counter = 0;
    for (int i = 0; i < a.length; i++) {
      if (a[i].length > 1) {
        counter++;
      }
    }
    setState(() {
      _charCount = counter;
    });
  }

  @override
  void initState() {
    super.initState();
    getCanCheck(http.Client(), widget.finishedUserBook['profileId'],
        globals.accessTokenG);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: canCheck != null && canCheck == '1' || globals.isAdmin == 1
            ? Scaffold(
                backgroundColor: Color(0xFFF6F6F7),
                appBar: AppBar(
                  leading: Builder(
                    builder: (BuildContext context) {
                      return IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        tooltip: MaterialLocalizations.of(context)
                            .previousPageTooltip,
                      );
                    },
                  ),
                  backgroundColor: Color(0xFF1D1D1D),
                  title: Text(
                    'Check a Review',
                  ),
                ),
                body: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 20.0),
                      Row(children: <Widget>[
                        Center(
                          child: Container(
                              width: 125,
                              height: 140,
                              color: Colors.transparent,
                              child: widget.booksInformation.imgStorage != null
                                  ? Image.network(
                                      widget.booksInformation.imgStorage)
                                  : Image.asset('assets/item_book.png')),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Column(children: <Widget>[
                          SizedBox(
                            width: 200,
                            child: Text(
                              widget.booksInformation.title,
                              style: TextStyle(
                                  fontSize: 20, fontFamily: 'RobotoBold'),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: 200,
                            child: Text(
                              widget.booksInformation.author,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'RobotoBold',
                                  color: Colors.grey[600]),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: 200,
                            child: RatingBarIndicator(
                              rating: widget.booksInformation.rating,
                              itemBuilder: (context, index) => Icon(
                                Icons.star,
                                color: Colors.amber[800],
                              ),
                              itemCount: 5,
                              itemSize: 19.0,
                              direction: Axis.horizontal,
                            ),
                          )
                        ]),
                      ]),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        height: 4,
                        width: 340,
                        child: Divider(color: Colors.grey[500]),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        'User rated',
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'RobotoBold',
                            color: Colors.grey[600]),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      RatingBarIndicator(
                        rating: widget.finishedUserBook['bookRating'],
                        itemBuilder: (context, index) => Icon(
                          Icons.star,
                          color: Colors.amber[800],
                        ),
                        itemCount: 5,
                        itemSize: 35.0,
                        direction: Axis.horizontal,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        color: Colors.grey[200],
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'User Review:',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontFamily: 'RobotoBold',
                                  ),
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                widget.finishedUserBook['bookReview'],
                                style: TextStyle(
                                    fontFamily: 'RobotoBold', fontSize: 16),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'Admin rate review',
                        style: TextStyle(
                            fontFamily: 'RobotoBold',
                            fontSize: 14,
                            color: Colors.grey[600]),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Container(
                            width: 110,
                            height: 50,
                            child: Form(
                              key: _key,
                              // ignore: deprecated_member_use
                              autovalidate: _validate,
                              child: TextFormField(
                                controller: adminRate,
                                validator: validateAdminRate,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(contentPadding: EdgeInsets.all(2),
                                  hintText: 'admin rate',
                                  hintStyle: TextStyle(
                                      fontFamily: 'RobotoBold', fontSize: 16),
                                  border: new OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(0.0),
                                    ),
                                    borderSide: new BorderSide(
                                      color: Colors.black,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            )),
                      ),
                      SizedBox(height: 15),
                      SizedBox(
                        height: 50,
                        width: 350,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          color: Color(0xFF213a8f),
                          onPressed: () async {

                            if (_sendToServer() && counter == 0) {
                              counter = 1;
                              status = await rateUserBook(
                                  widget.finishedUserBook['id'],
                                  widget.finishedUserBook['bookReview'],
                                  int.parse(adminRate.text),
                                  widget.finishedUserBook['gotPoint'],
                                  widget.finishedUserBook['bookId'],
                                  widget.finishedUserBook['bookRating'],
                                  widget.finishedUserBook['profileId'],
                                  globals.accessTokenG);
                              if(status.statusCode != null) {
                                counter = 0;
                              }
                              if (status.statusCode == 200) {
                                Navigator.pop(context);
                                Fluttertoast.showToast(
                                  msg: 'Book Rated',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                );
                              }

                              return null;
                            }
                          },
                          child: Text(
                            'Save',
                            style: TextStyle(
                                fontSize: 17,
                                fontFamily: 'RobotoBold',
                                color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                    ],
                  ),
                ),
              )
            : widget.finishedUserBook['verified'] == false &&
                    globals.isAdmin == 0 &&
                    widget.finishedUserBook['profileId'] == widget.guestId
                ? Scaffold(
                    backgroundColor: Colors.white,
                    appBar: AppBar(
                      leading: Builder(
                        builder: (BuildContext context) {
                          return IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            tooltip: MaterialLocalizations.of(context)
                                .previousPageTooltip,
                          );
                        },
                      ),
                      backgroundColor: Color(0xFF1D1D1D),
                      title: Text(
                        'Write a Review',
                      ),
                    ),
                    body: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 20.0),
                          Row(children: <Widget>[
                            Center(
                              child: Container(
                                  width: 125,
                                  height: 140,
                                  color: Colors.transparent,
                                  child: widget.booksInformation.imgStorage !=
                                          null
                                      ? Image.network(
                                          widget.booksInformation.imgStorage)
                                      : Image.asset('assets/item_book.png')),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Column(children: <Widget>[
                              SizedBox(
                                width: 200,
                                child: Text(
                                  widget.booksInformation.title,
                                  style: TextStyle(
                                      fontSize: 20, fontFamily: 'RobotoBold'),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                width: 200,
                                child: Text(
                                  widget.booksInformation.author,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'RobotoBold',
                                      color: Colors.grey[600]),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                width: 200,
                                child: RatingBarIndicator(
                                  rating: widget.booksInformation.rating,
                                  itemBuilder: (context, index) => Icon(
                                    Icons.star,
                                    color: Colors.amber[800],
                                  ),
                                  itemCount: 5,
                                  itemSize: 19.0,
                                  direction: Axis.horizontal,
                                ),
                              )
                            ]),
                          ]),
                          SizedBox(
                            height: 8,
                          ),
                          Container(
                            height: 4,
                            width: 340,
                            child: Divider(color: Colors.grey[500]),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Rate it!',
                            style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'RobotoBold',
                                color: Colors.grey[600]),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          RatingBar.builder(
                            initialRating: 0,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber[800],
                            ),
                            onRatingUpdate: (rating) {
                              setRating = rating;
                            },
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Write a Review:',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: 'RobotoBold',
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              _charCount >= 50
                                  ? Text(
                                      '+10 points',
                                      style: TextStyle(
                                          fontSize: 19,
                                          fontFamily: 'RobotoBold',
                                          color: Colors.green),
                                    )
                                  : Container(),
                              Spacer(),
                              Text(
                                'words: ${_charCount.toString()}',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: 'RobotoBold',
                                ),
                              ),
                              SizedBox(
                                width: 30,
                              ),
                            ],
                          ),
                          Form(
                            key: _key,
                            // ignore: deprecated_member_use
                            autovalidate: _validate,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: <Widget>[
                                  TextFormField(
                                    maxLines: 10,
                                    keyboardType: TextInputType.multiline,
                                    decoration: InputDecoration(
                                      hintText:
                                          'YOU ARE CHEATED AND GOT MINUS 15 POINTS, WRITE YOUR REVIEW AGAIN YOURSELF',
                                      fillColor: Colors.grey.shade50,
                                    ),
                                    controller: bookReview,
                                    validator: validateReview,
                                    onChanged: _onChanged,
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  SizedBox(
                                    height: 50,
                                    width: 350,
                                    child: FlatButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0)),
                                      color: Color(0xFF213a8f),
                                      onPressed: () async {
                                        if (setRating != null) {
                                          if (_sendToServer() && counter == 0) {
                                            counter = 1;
                                            status = await postReview(
                                                widget.finishedUserBook['id'],
                                                bookReview.text,
                                                setRating,
                                                widget.booksInformation.bookId,
                                                widget.finishedUserBook[
                                                    'profileId'],
                                                globals.accessTokenG);
                                            if(status.statusCode != null) {
                                              counter = 0;
                                            }
                                            if (status.statusCode == 200) {
                                              Navigator.pop(context);
                                              Fluttertoast.showToast(
                                                msg: 'Review added!',
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                              );
                                            }
                                          }
                                        } else {
                                          Fluttertoast.showToast(
                                            msg: 'Please, rate the book!',
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                          );
                                        }
                                      },
                                      child: Text(
                                        'Add Review',
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontFamily: 'RobotoBold',
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : Scaffold(
                    backgroundColor: Colors.white,
                    appBar: AppBar(
                      leading: Builder(
                        builder: (BuildContext context) {
                          return IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            tooltip: MaterialLocalizations.of(context)
                                .previousPageTooltip,
                          );
                        },
                      ),
                      backgroundColor: Color(0xFF1D1D1D),
                      title: Text(
                        'User review',
                      ),
                    ),
                    body: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 20.0),
                          Row(children: <Widget>[
                            Center(
                              child: Container(
                                  width: 125,
                                  height: 140,
                                  color: Colors.transparent,
                                  child: widget.booksInformation.imgStorage !=
                                          null
                                      ? Image.network(
                                          widget.booksInformation.imgStorage)
                                      : Image.asset('assets/item_book.png')),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Column(children: <Widget>[
                              SizedBox(
                                width: 200,
                                child: Text(
                                  widget.booksInformation.title,
                                  style: TextStyle(
                                      fontSize: 20, fontFamily: 'RobotoBold'),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                width: 200,
                                child: Text(
                                  widget.booksInformation.author,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'RobotoBold',
                                      color: Colors.grey[600]),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                width: 200,
                                child: RatingBarIndicator(
                                  rating: widget.booksInformation.rating,
                                  itemBuilder: (context, index) => Icon(
                                    Icons.star,
                                    color: Colors.amber[800],
                                  ),
                                  itemCount: 5,
                                  itemSize: 19.0,
                                  direction: Axis.horizontal,
                                ),
                              )
                            ]),
                          ]),
                          SizedBox(
                            height: 8,
                          ),
                          Container(
                            height: 4,
                            width: 340,
                            child: Divider(color: Colors.grey[500]),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            'User rated',
                            style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'RobotoBold',
                                color: Colors.grey[600]),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          RatingBarIndicator(
                            rating: widget.finishedUserBook['bookRating'],
                            itemBuilder: (context, index) => Icon(
                              Icons.star,
                              color: Colors.amber[800],
                            ),
                            itemCount: 5,
                            itemSize: 40.0,
                            direction: Axis.horizontal,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            color: Colors.grey[200],
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'User review:',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontFamily: 'RobotoBold',
                                      ),
                                    ),
                                    Spacer(),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    widget.finishedUserBook['bookReview'],
                                    style: TextStyle(
                                        fontFamily: 'RobotoBold', fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(children: <Widget>[
                            Spacer(),
                            Text(
                              'Admin rate: ',
                              style: TextStyle(
                                  fontFamily: 'RobotoMedium',
                                  color: Colors.grey[700],
                                  fontSize: 17),
                            ),
                            Text(
                              widget.finishedUserBook['checkRated'] == true
                                  ? widget.finishedUserBook['gotPoint']
                                      .toString()
                                  : 'not graded yet',
                              style: TextStyle(
                                  fontFamily: 'RobotoBold',
                                  color: widget
                                              .finishedUserBook['checkRated'] ==
                                          true
                                      ? widget.finishedUserBook['gotPoint'] >=
                                              0.0
                                          ? Colors.cyan[800]
                                          : Colors.red
                                      : Colors.yellow[900],
                                  fontSize: 17),
                            ),
                            Spacer(),
                          ]),
                          SizedBox(
                            height: 15,
                          ),
                        ],
                      ),
                    ),
                  ));
  }
}
