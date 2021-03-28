import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import 'package:mds_reads/globals.dart' as globals;

class ContactUsRoute extends StatefulWidget {
  ContactUsRoute({Key key}) : super(key: key);

  @override
  _ContactUsRouteState createState() => _ContactUsRouteState();
}

Future<http.Response> postContactUs(String description, String userId) async {
  Box box = Hive.box('config');
  var url = '${box.get('url')}/api/project/mdsreads/contactus/new';

  Map data = {
    'description': description,
    'userId': userId
  };
  //encode Map to JSON
  var body = json.encode(data);

  var response = await http.post(url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer ${globals.accessTokenG}'
      },
      body: body);

  return response;
}

class _ContactUsRouteState extends State<ContactUsRoute> {
  final _text = TextEditingController();
  bool _valid = false;
  var status;
  var k = 0;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }
  void onChangedText(String text) {
    k = 1;
    if(text.isEmpty) {
      setState(() {
        _valid = true;
      });
    } else {
      setState(() {
        _valid = false;
      });
    }
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
        appBar: AppBar(
          backgroundColor: Color(0xFF213A8F),
          elevation: 2.0,
          title: Text(
            "Contact Us",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10.0,
              ),
              SizedBox(
                height: 20.0,
              ),
              buildFeedbackForm(),
              SizedBox(height: 30.0),

            ],
          ),
        ),
      ),
    );
  }

  buildFeedbackForm() {
    return Container(
      height: 250,
      child: ListView(
          children: [
            TextField(controller: _text,
              maxLines: 5,
              decoration: InputDecoration(
                errorText: _valid ? "Value can\'t be empty" : null,
                hintText: "Please briefly describe the issue",
                hintStyle: TextStyle(
                  fontSize: 15.0,
                  color: Color(0xFFC5C5C5),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFE5E5E5),
                  ),
                ),
              ),
              onChanged: onChangedText,
            ),
            Container(
              child: FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onPressed: () async {
                  print(globals.userId);
                  if(k != 0 && !_valid) {
                    status = await postContactUs(
                        _text.text,
                        globals.userId
                    );
                    if (status.statusCode == 200) {
                      Navigator.pop(context);
                      Fluttertoast.showToast(
                        msg: 'Your issue has been send!',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    }
                  }
                },
                child: Text(
                  "SUBMIT",
                  style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                color: Color(0xFF213A8F),
                padding: EdgeInsets.all(13.0),
              ),
            ),
          ]
      ),
    );
  }
}