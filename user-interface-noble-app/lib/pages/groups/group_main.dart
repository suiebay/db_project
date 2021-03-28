import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:mds_reads/globals.dart' as globals;
import 'package:mds_reads/pages/groups/group_list.dart';
import 'package:mds_reads/pages/groups/group_user_add.dart';
import 'package:http/http.dart' as http;
import 'package:mds_reads/pages/user/user_page.dart';
import 'package:mds_reads/widgets/popupmenu_widget.dart';

Future<http.Response> deleteRequest(String id, String token) async {
  Box box = Hive.box('config');
  var url = '${box.get('url')}/api/project/mdsreads/groups/delete/$id';

  final http.Response response = await http.delete(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token'
    },
  );

  return response;
}

Future<http.Response> updateReadsGroupTitle(String id, String title,
    String mentorId, String profileIds, String token) async {
  Box box = Hive.box('config');
  var url = '${box.get('url')}/api/project/mdsreads/groups/updateTitle';

  Map data = {
    'id': id,
    'title': title,
    'mentorId': mentorId,
    'profileIds': profileIds,
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

// ignore: must_be_immutable
class GroupMain extends StatefulWidget {
  GroupDetails groupDetails;

  GroupMain({this.groupDetails});

  @override
  _GroupMainState createState() => new _GroupMainState();
}

class _GroupMainState extends State<GroupMain> {
  TextEditingController controller = new TextEditingController();
  int counter = 0;
  var status;
  final readsGroupTitle = TextEditingController();
  Widget sss = Text('');
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  String title;

  void refreshState() {
    setState(() {});
  }

  List<dynamic> _groupResult = [];

  void getGroupUsers(http.Client client, String id, String token) async {
    Box box = Hive.box('config');
    var url = '${box.get('url')}/api/reads/group-user-list/$id';

    final http.Response response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    String body = utf8.decode(response.bodyBytes);
    final responseJson = json.decode(body);

    setState(() {
      _groupResult = responseJson;
    });
  }

  @override
  void initState() {
    super.initState();
    getGroupUsers(http.Client(), widget.groupDetails.id, globals.accessTokenG);
  }

  String validateTitle(String value) {
    if (value.length == 0) {
      return "Title is Required";
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
          backgroundColor: Color(0xFF213A8F),
          title: Text(
            'Readers rating',
          ),
          actions: <Widget>[
            globals.isAdmin == 1
                ? PopupMenuButton<int>(
                    icon: IconTheme(
                      data: new IconThemeData(color: Colors.white, size: 20),
                      child: new Icon(Icons.more_vert),
                    ),
                    itemBuilder: (context) => [
                      editPopUpMenuItem(),
                      deletePopUpMenuItem(),
                    ],
                    // offset: Offset(0, 40),
                    onSelected: (value) {
                      if (value == 1) {
                        readsGroupTitle.text = '';
                        sss = Text('');
                        showDialog(
                          context: context,
    builder: (BuildContext context) { return AnimatedContainer(
                            margin: MediaQuery.of(context).viewInsets,
                            duration: const Duration(milliseconds: 300),
                            child: StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  content: Container(
                                      height: 140,
                                      child: Form(
                                        key: _key,
                                        // ignore: deprecated_member_use
                                        autovalidate: _validate,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: Column(
                                            children: <Widget>[
                                              SizedBox(
                                                width: double.infinity,
                                                child: Text(
                                                  'Enter Group title',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontFamily: 'RobotoRegular',
                                                  ),
                                                ),
                                              ),
                                              TextFormField(
                                                autofocus: true,
                                                controller: readsGroupTitle
                                                  ..text =
                                                      widget.groupDetails.title,
                                                decoration: InputDecoration(
                                                  fillColor:
                                                      Colors.grey.shade50,
                                                ),
                                                validator: validateTitle,
                                                onSaved: (String val) {
                                                  title = val;
                                                },
                                              ),
                                              SizedBox(
                                                height: 15,
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  FlatButton(
                                                    color: Colors.orange,
                                                    onPressed: () {
                                                      readsGroupTitle.text = '';
                                                      sss = Text('');
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                      '  Отмена  ',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 33,
                                                  ),
                                                  FlatButton(
                                                    color: Colors.purple[800],
                                                    onPressed: () async {
                                                      if (_sendToServer()) {
                                                        status =
                                                            await updateReadsGroupTitle(
                                                                widget
                                                                    .groupDetails
                                                                    .id,
                                                                readsGroupTitle
                                                                    .text,
                                                                null,
                                                                null,
                                                                globals
                                                                    .accessTokenG);
                                                        if (status.statusCode ==
                                                            200) {
                                                          readsGroupTitle.text =
                                                              '';
                                                          sss = Text('');
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.pop(
                                                              context);
                                                          Fluttertoast
                                                              .showToast(
                                                            msg:
                                                                'Group title updated',
                                                            toastLength: Toast
                                                                .LENGTH_SHORT,
                                                            gravity:
                                                                ToastGravity
                                                                    .BOTTOM,
                                                          );
                                                          refreshState();
                                                          setState(() {
                                                            sss = Text('');
                                                          });
                                                        }
                                                      }
                                                      if (status != null &&
                                                          status.statusCode ==
                                                              400) {
                                                        setState(() {
                                                          sss = Text(
                                                            'Title already exist!',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red),
                                                          );
                                                        });
                                                      }
                                                    },
                                                    child: Text(
                                                      'Отправить',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              sss
                                            ],
                                          ),
                                        ),
                                      )),
                                );
                              },
                            ),
                          );}
                        );
                      }
                      if (value == 2) {
                        showDialog(
                          context: context,
                        builder: (BuildContext context) { return AnimatedContainer(
                            margin: MediaQuery.of(context).viewInsets,
                            duration: const Duration(milliseconds: 300),
                            child: AlertDialog(
                              title: Text('Are you sure to delete this group?'),
                              content: Container(
                                  height: 70,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: Column(
                                      children: <Widget>[
                                        SizedBox(
                                          width: double.infinity,
                                          child: Text(
                                            widget.groupDetails.title,
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Spacer(),
                                            Padding(
                                              padding: const EdgeInsets.all(17.0),
                                              child: Container(
                                                width: 60,
                                                child: FlatButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    'NO',
                                                    style: TextStyle(
                                                        color: Colors.cyan[800]),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 60,
                                              child: FlatButton(
                                                onPressed: () async {
                                                  status = await deleteRequest(
                                                      widget.groupDetails.id,
                                                      globals.accessTokenG);
                                                  if (status.statusCode == 200) {
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                    Fluttertoast.showToast(
                                                      msg: 'Group deleted',
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                      gravity:
                                                          ToastGravity.BOTTOM,
                                                    );
                                                    setState(() {});
                                                  }
                                                },
                                                child: Text(
                                                  'YES',
                                                  style: TextStyle(
                                                      color: Colors.cyan[800]),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )),
                            ),
                          );}
                        );
                      }
                    },
                  )
                : Container(),
          ],
        ),
        body: Container(
            margin: EdgeInsets.only(top: 10),
            child: _groupResult != null
                ? ListView.builder(
                    itemCount: _groupResult.length,
                    itemBuilder: (context, index) {
                      _groupResult[index]['firstName'] =
                          _groupResult[index]['firstName'] == ''
                              ? ''
                              : _groupResult[index]['firstName'];
                      _groupResult[index]['lastName'] =
                          _groupResult[index]['lastName'] == ''
                              ? ''
                              : _groupResult[index]['lastName'];
                      _groupResult[index]['middleName'] =
                          _groupResult[index]['middleName'] == null
                              ? ''
                              : _groupResult[index]['middleName'];
                      _groupResult[index]['groupId'] =
                          _groupResult[index]['groupId'] == 'null'
                              ? ''
                              : _groupResult[index]['groupId'];
                      _groupResult[index]['firstName'] =
                          _groupResult[index]['firstName'].trim();
                      _groupResult[index]['lastName'] =
                          _groupResult[index]['lastName'].trim();
                      _groupResult[index]['middleName'] =
                          _groupResult[index]['middleName'].trim();
                      _groupResult[index]['lastName'] =
                          _groupResult[index]['lastName'] == ''
                              ? ''
                              : ' ${_groupResult[index]['lastName']}';
                      _groupResult[index]['middleName'] =
                          _groupResult[index]['middleName'] == null
                              ? ''
                              : ' ${_groupResult[index]['middleName']}';
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UserPage(profileDetails: _groupResult[index]),
                            ),
                          ).then((value) {
                            refreshState();
                          });
                        },
                        child: Column(
                          children: <Widget>[
                            Container(
                                margin: EdgeInsets.fromLTRB(4, 0, 4, 0),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                        child: Stack(children: <Widget>[
                                      Container(
                                          child: CircleAvatar(
                                            backgroundColor: Colors.transparent,
                                            backgroundImage: _groupResult[index]
                                                            ['avatar'] !=
                                                        null &&
                                                    _groupResult[index]
                                                            ['avatar'] !=
                                                        '' &&
                                                    (_groupResult[index]
                                                                ['gender'] ==
                                                            globals.gender ||
                                                        globals.isAdmin == 1)
                                                ? NetworkImage(
                                                    _groupResult[index]
                                                        ['avatar'])
                                                : _groupResult[index]
                                                            ['gender'] ==
                                                        1
                                                    ? AssetImage(
                                                        'assets/profile_boy.png')
                                                    : AssetImage(
                                                        'assets/profile_girl.png'),
                                            radius: 40,
                                          ),
                                          padding: EdgeInsets.all(3.0),
                                          decoration: BoxDecoration(
                                            color: _groupResult[index]
                                                            ['readsPoint'] >=
                                                        750 &&
                                                    _groupResult[index]['readsFinishedBooks'] >=
                                                        50 &&
                                                    _groupResult[index]['readsReviewNumber'] >=
                                                        50
                                                ? Color(0xFFFFD700)
                                                : _groupResult[index]['readsPoint'] >= 300 &&
                                                        _groupResult[index]['readsFinishedBooks'] >=
                                                            20 &&
                                                        _groupResult[index]['readsReviewNumber'] >=
                                                            20 &&
                                                        (_groupResult[index]['readsPoint'] < 750 ||
                                                            _groupResult[index]['readsFinishedBooks'] < 50 &&
                                                                _groupResult[index]['readsReviewNumber'] <
                                                                    50)
                                                    ? Color(0xFFC0C0C0)
                                                    : _groupResult[index]['readsPoint'] >= 75 &&
                                                            _groupResult[index]['readsFinishedBooks'] >=
                                                                5 &&
                                                            _groupResult[index]['readsReviewNumber'] >=
                                                                5 &&
                                                            (_groupResult[index]['readsPoint'] <
                                                                    300 ||
                                                                _groupResult[index]['readsFinishedBooks'] <
                                                                        20 &&
                                                                    _groupResult[index]['readsReviewNumber'] < 20)
                                                        ? Color(0xFFCD7F32)
                                                        : Colors.white,
                                            shape: BoxShape.circle,
                                          )),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Image(
                                          image: _groupResult[index]['readsPoint'] >= 750 &&
                                                  _groupResult[index]['readsFinishedBooks'] >=
                                                      50 &&
                                                  _groupResult[index]['readsReviewNumber'] >=
                                                      50
                                              ? AssetImage('assets/ic_gold.png')
                                              : _groupResult[index]['readsPoint'] >= 300 &&
                                                      _groupResult[index]['readsFinishedBooks'] >=
                                                          20 &&
                                                      _groupResult[index]['readsReviewNumber'] >=
                                                          20 &&
                                                      (_groupResult[index]['readsPoint'] < 750 ||
                                                          _groupResult[index]['readsFinishedBooks'] < 50 &&
                                                              _groupResult[index]['readsReviewNumber'] <
                                                                  50)
                                                  ? AssetImage(
                                                      'assets/ic_silver.png')
                                                  : _groupResult[index]['readsPoint'] >= 75 &&
                                                          _groupResult[index]['readsFinishedBooks'] >=
                                                              5 &&
                                                          _groupResult[index]['readsReviewNumber'] >=
                                                              5 &&
                                                          (_groupResult[index]['readsPoint'] <
                                                                  300 ||
                                                              _groupResult[index]
                                                                          ['readsFinishedBooks'] <
                                                                      20 &&
                                                                  _groupResult[index]['readsReviewNumber'] < 20)
                                                      ? AssetImage('assets/ic_bronze.png')
                                                      : AssetImage('assets/transparent.png'),
                                          width: 30,
                                        ),
                                      )
                                    ])),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(
                                          width: 200,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Text(
                                              '${_groupResult[index]['firstName']}${_groupResult[index]['lastName']}${_groupResult[index]['middleName']}',
                                              style: TextStyle(
                                                  fontFamily: 'RobotoBold',
                                                  fontSize: 15,
                                                  color: Colors.grey[600]),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 6,
                                        ),
                                        SizedBox(
                                          width: 200,
                                          child: Row(
                                            children: <Widget>[
                                              Column(
                                                children: <Widget>[
                                                  SizedBox(
                                                    height: 1,
                                                  ),
                                                  Icon(
                                                    Icons.stars,
                                                    size: 17,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                width: 3,
                                              ),
                                              Text(
                                                _groupResult[index]
                                                        ['readsPoint']
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 15,
                                                    fontFamily: 'RobotoBold'),
                                              ),
                                              SizedBox(
                                                width: 13,
                                              ),
                                              Icon(
                                                Icons.book,
                                                size: 17,
                                              ),
                                              SizedBox(
                                                width: 3,
                                              ),
                                              Text(
                                                _groupResult[index]
                                                        ['readsFinishedBooks']
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 15,
                                                    fontFamily: 'RobotoBold'),
                                              ),
                                              SizedBox(
                                                width: 13,
                                              ),
                                              Column(
                                                children: <Widget>[
                                                  SizedBox(
                                                    height: 1,
                                                  ),
                                                  Icon(
                                                    Icons.rate_review,
                                                    size: 17,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                width: 3,
                                              ),
                                              Text(
                                                _groupResult[index]
                                                        ['readsReviewNumber']
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 15,
                                                    fontFamily: 'RobotoBold'),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 6,
                                        ),
                                        SizedBox(
                                          width: 200,
                                          child: Text(
                                            //'${users[index]['groupId']} ',
                                            'MDS Group',
                                            style: TextStyle(
                                                fontFamily: 'RobotoBold',
                                                fontSize: 15,
                                                color: Colors.grey[600]),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    Text(
                                      (index + 1).toString(),
                                      style: TextStyle(
                                          fontSize: 25,
                                          fontFamily: 'QuickLight'),
                                    ),
                                    SizedBox(
                                      width: 9,
                                    )
                                  ],
                                )),
                            SizedBox(
                              height: 10.0,
                              child: Center(
                                child: Container(
                                  margin: EdgeInsetsDirectional.only(
                                      start: 5.0, end: 5.0),
                                  height: 0.2,
                                  color: Colors.black,
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    })
                : Container()),
        floatingActionButton: globals.isAdmin == 1
            ? FloatingActionButton(
                child: Icon(Icons.add),
                backgroundColor: Colors.blue,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          GroupUserAdd(groupDetails: widget.groupDetails),
                    ),
                  ).then((value) {
                    getGroupUsers(http.Client(), widget.groupDetails.id,
                        globals.accessTokenG);
                  });
                })
            : Container(),
      ),
    );
  }
}
