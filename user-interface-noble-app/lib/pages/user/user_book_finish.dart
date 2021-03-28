import 'dart:convert';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:mds_reads/pages/books/books_information.dart';
import 'dart:io' show Platform;

import 'package:mds_reads/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

getStringValuesSF(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String stringValue = prefs.getString(key);
  return stringValue;
}

Future<http.Response> postReview(String id, String bookReview, double bookRating, String bookId, String profileId, String token) async {
  var url;
  Box box = Hive.box('config');
  if(Platform.isAndroid) url = '${box.get('url')}/api/project/mdsreads/userbook/finish';
  else if(Platform.isIOS) url = '${box.get('url')}/api/project/mdsreads/userbook/finish';

  Map data = {
    'id': id,
    'bookReview': bookReview,
    'bookRating': bookRating,
    'bookId': bookId,
    'profileId': profileId
  };
  //encode Map to JSON
  var body = json.encode(data);

  var response = await http.post(url,
      headers: {"Content-Type": "application/json", 'Authorization': 'Bearer $token'},
      body: body
  );
  return response;
}

// ignore: must_be_immutable
class UserBookFinish extends StatefulWidget {
  BooksInformation booksInformation;
  String userBookId;
  String userBookProfileId;

  UserBookFinish ({ this.booksInformation, this.userBookId, this.userBookProfileId });

  @override
  _BooksListState createState() => _BooksListState();
}

class Item {
  const Item(this.name,this.icon);
  final String name;
  final Icon icon;
}

class _BooksListState extends State<UserBookFinish> {
  var setRating;
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  final bookReview = TextEditingController();

  //int wordsNum = 0;
  var status;
  bool canSubmit = true;

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
    } else if (counter < 300) {
      return "Review must contain minimum 300 words";
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
                tooltip: MaterialLocalizations
                    .of(context)
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
              Row(
                  children: <Widget>[
                    Center(
                      child: Container(
                          width: 125,
                          height: 140,
                          color: Colors.transparent,
                          child: widget.booksInformation.imgStorage != null
                              ? Image.network(
                              widget.booksInformation.imgStorage)
                              : Image.asset('assets/item_book.png')
                      ),
                    ),
                    SizedBox(width: 20,),
                    Column(
                        children: <Widget>[
                          SizedBox(
                            width: 200,
                            child: Text(
                              widget.booksInformation.title,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'RobotoBold'
                              ),
                            ),
                          ),
                          SizedBox(height: 10,),
                          SizedBox(
                            width: 200,
                            child: Text(
                              widget.booksInformation.author,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'RobotoBold',
                                  color: Colors.grey[600]
                              ),
                            ),
                          ),
                          SizedBox(height: 10,),
                          SizedBox(
                            width: 200,
                            child: RatingBarIndicator(
                              rating: widget.booksInformation.rating,
                              itemBuilder: (context, index) =>
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber[800],
                                  ),
                              itemCount: 5,
                              itemSize: 19.0,
                              direction: Axis.horizontal,
                            ),
                          )
                        ]
                    ),
                  ]
              ),
              SizedBox(height: 8,),
              Container(
                height: 4,
                width: 340,
                child: Divider(
                    color: Colors.grey[500]
                ),
              ),
              SizedBox(height: 8,),
              Text(
                'Rate it!',
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'RobotoBold',
                    color: Colors.grey[600]
                ),
              ),
              SizedBox(height: 10,),
              RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) =>
                    Icon(
                      Icons.star,
                      color: Colors.amber[800],
                    ),
                onRatingUpdate: (rating) {
                  setRating = rating;
                },
              ),
              SizedBox(height: 15,),
              Row(
                children: [
                  SizedBox(width: 10,),
                  Text(
                    'Write a Review:',
                    style: TextStyle(
                      fontSize: 17,
                      fontFamily: 'RobotoBold',
                    ),
                  ),
                  SizedBox(width: 10,),
                  _charCount >= 300 ? Text(
                    '+10 points',
                    style: TextStyle(
                        fontSize: 19,
                        fontFamily: 'RobotoBold',
                        color: Colors.green
                    ),
                  ) : Container(),
                  Spacer(),
                  Text(
                    'words: ${_charCount.toString()}',
                    style: TextStyle(
                      fontSize: 17,
                      fontFamily: 'RobotoBold',
                    ),
                  ),
                  SizedBox(width: 30,),
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
                          fillColor: Colors.grey.shade50,
                        ),
                        controller: bookReview,
                        validator: validateReview,
                        onChanged: _onChanged,
                      ),
                      SizedBox(height: 20,),
                      SizedBox(
                        height: 50,
                        width: 350,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          color: Color(0xFF213a8f),
                          onPressed: () async {
                            if (setRating != null) {
                              if (_sendToServer() && canSubmit == true) {
                                setState(() {
                                  canSubmit = false;
                                });
                                status = await postReview(
                                    widget.userBookId,
                                    bookReview.text,
                                    setRating,
                                    widget.booksInformation.bookId,
                                    widget.userBookProfileId,
                                    globals.accessTokenG
                                );
                                setState(() {
                                  canSubmit = true;
                                });
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
                          child: canSubmit == true ? Text(
                            'Add Review',
                            style: TextStyle(
                                fontSize: 17,
                                fontFamily: 'RobotoBold',
                                color: Colors.white
                            ),
                          ) : CircularProgressIndicator(backgroundColor: Colors.white, strokeWidth: 15,),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
