import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:mds_reads/colors/floating_button_color.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

import 'package:mds_reads/globals.dart' as globals;
import 'package:mds_reads/pages/error_page.dart';
import 'package:mds_reads/pages/groups/group_main.dart';

import '../../drawer.dart';


Future<http.Response> readsGroupCreate(String title, String token) async {
  Box box = Hive.box('config');
  var url;
  if(Platform.isAndroid) url = '${box.get('url')}/api/project/mdsreads/groups/new';
  else if(Platform.isIOS) url = '${box.get('url')}/api/project/mdsreads/groups/new';

  Map data = {
    'id': null,
    'title': title,
  };
  //encode Map to JSON
  var body = json.encode(data);

  var response = await http.post(url,
      headers: {"Content-Type": "application/json", 'Authorization': 'Bearer $token'},
      body: body
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

class GroupList extends StatefulWidget {
  @override
  _GroupistState createState() => _GroupistState();
}

class _GroupistState extends State<GroupList> {
  Map dataMap = Map<String, String>();

  dynamic getGroupList(http.Client client, String token) async {
    Box box = Hive.box('config');
    var response;
    try {
      var url;
      if (Platform.isAndroid) {
        url = '${box.get('url')}/api/project/mdsreads/groups/list';
      }
      else if (Platform.isIOS) {
        url = '${box.get('url')}/api/project/mdsreads/groups/list';
      }

      response = await http.get(url,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(Duration(seconds: globals.duration));

      setState(() {
        String body = utf8.decode(response.bodyBytes);
        final responseJson = json.decode(body);
        _groupResult.clear();
        var k = 0;
        for (Map user in responseJson) {
          _groupResult.add(GroupDetails.fromJson(user));
          colorsMap[_groupResult.last.title] = colors[(k * 2) % 10];
          colorsMap[_groupResult.last.title + "2"] = colors[(k * 2 + 1) % 10];
          k++;
        }
      });

      var counter = 0;
      for (GroupDetails some in _groupResult) {
        if (some.mentorId != null) {
          var x = await getUsersDetails(http.Client(), some.mentorId, globals.accessTokenG);
          String xBody = utf8.decode(x.bodyBytes);
          final xResponseJson = json.decode(xBody);
          dataMap[some.mentorId] = '${xResponseJson['firstName']} ${xResponseJson['lastName']}';

        }
        counter++;
      }
      setState(() {});
    } on TimeoutException catch(_) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (
              context, animation1, animation2) => ErrorPage(),
        ),
      );
    }
  }

  TextEditingController controller = new TextEditingController();
  final readsGroupTitle = TextEditingController();
  Widget sss = Text('');
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  String title;
  var status;

  List<GroupDetails> _searchResult = [];
  List<GroupDetails> _groupResult = [];

  List<Color> colors = [Colors.pink, Colors.purple, Colors.orangeAccent, Color(0xFFF49330),
    Colors.lightBlueAccent, Colors.blue, Colors.red[300], Color(0xFFea2937),
    Colors.green[400], Colors.green[800]];

  Map colorsMap = Map<String, dynamic>();

  void refreshState() {
    setState(() {
      getGroupList(http.Client(), globals.accessTokenG);
    });
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
  void initState() {
    super.initState();
    getGroupList(http.Client(), globals.accessTokenG);
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
      child: StatefulBuilder(
        builder: (context, setState) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Color(0xFF213A8F),
              title: Text(
                'Groups',
              ),
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
                                  hintText: 'Search',
                                  border: InputBorder.none),
                              onChanged: onSearchTextChanged2,
                            ),
                            trailing: controller.text != ''
                                ? new IconButton(
                              icon: new Icon(Icons.cancel),
                              onPressed: () {
                                controller.clear();
                                onSearchTextChanged2('');
                              },)
                                : null
                        ),
                      ),
                      //color: Colors.red,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 60, bottom: 10),
                    child: _searchResult != null && _searchResult.length != 0 ||
                      controller.text.isNotEmpty
                      ? ListView.builder(
                          itemCount: _searchResult.length,
                          itemBuilder: (context, index) {
                          return Container(
                            height: 90,
                            width: double.maxFinite,
                            margin: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 7),
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      colorsMap[_searchResult[index].title],
                                      colorsMap[_searchResult[index].title + "2"]
                                    ]
                                ),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(4))
                            ),
                            child: InkWell(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        GroupMain(
                                            groupDetails: _searchResult[index]),
                                  ),
                                ).then((value) {
                                  refreshState();
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                            _searchResult[index].title,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontFamily: "RobotoBold",
                                            )
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                            dataMap[_searchResult[index].mentorId] != null
                                                ? dataMap[_searchResult[index].mentorId]//"Mentor Name"
                                                : "",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontFamily: "RobotoMedium",
                                            )
                                        )
                                      ],
                                    ),
                                    Spacer(),
                                    Container(
                                      height: 70,
                                      color: Colors.transparent,
                                      child: Image.asset(index % 5 == 0
                                          ? 'assets/subject1.png'
                                          : index % 5 == 1
                                          ? 'assets/subject2.png'
                                          : index % 5 == 2
                                          ? 'assets/subject3.png'
                                          : index % 5 == 3
                                          ? 'assets/subject4.png'
                                          : 'assets/subject5.png'
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      ) : _groupResult != null ? ListView.builder(
                      itemCount: _groupResult.length,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 90,
                          width: double.maxFinite,
                          margin: EdgeInsets.symmetric(
                              horizontal: 8, vertical: 7),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    colorsMap[_groupResult[index].title],
                                    colorsMap[_groupResult[index].title + "2"]
                                  ]
                              ),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(4))
                          ),
                          child: InkWell(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      GroupMain(
                                          groupDetails: _groupResult[index]),
                                ),
                              ).then((value) {
                                refreshState();
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                children: <Widget>[
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                          _groupResult[index].title,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontFamily: "RobotoBold",
                                          )
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                          dataMap[_groupResult[index].mentorId] != null
                                              ? dataMap[_groupResult[index].mentorId]//"Mentor Name"
                                              : "",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontFamily: "RobotoMedium",
                                          )
                                      )
                                    ],
                                  ),
                                  Spacer(),
                                  Container(
                                    height: 70,
                                    color: Colors.transparent,
                                    child: Image.asset(index % 5 == 0
                                        ? 'assets/subject1.png'
                                        : index % 5 == 1
                                        ? 'assets/subject2.png'
                                        : index % 5 == 2
                                        ? 'assets/subject3.png'
                                        : index % 5 == 3
                                        ? 'assets/subject4.png'
                                        : 'assets/subject5.png'
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    ) : Container(),
                  )
                ],
              ),
              floatingActionButton: globals.isAdmin == 1
                  ? FloatingActionButton(
                  child: Icon(Icons.add),
                  backgroundColor: floatingButtonColor,
                  onPressed: () {
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
                                            controller: readsGroupTitle,
                                            decoration: InputDecoration(
                                              fillColor: Colors.grey.shade50,
                                            ),
                                            validator: validateTitle,
                                            onSaved: (String val) {
                                              title = val;
                                            },
                                          ),
                                          SizedBox(height: 15,),
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
                                                      color: Colors.white
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 33,),
                                              FlatButton(
                                                color: Colors.purple[800],
                                                onPressed: () async {
                                                  if (_sendToServer()) {
                                                    status = await readsGroupCreate(
                                                        readsGroupTitle.text,
                                                        globals.accessTokenG);
                                                    if (status.statusCode == 200) {
                                                      readsGroupTitle.text = '';
                                                      sss = Text('');
                                                      Navigator.pop(context);
                                                      Fluttertoast.showToast(
                                                        msg: 'Group added',
                                                        toastLength: Toast.LENGTH_SHORT,
                                                        gravity: ToastGravity.BOTTOM,
                                                      );
                                                      refreshState();
                                                      setState(() {
                                                        sss = Text('');
                                                      });
                                                    }
                                                  }
                                                  if (status != null && status.statusCode == 400) {
                                                    setState(() {
                                                      sss = Text(
                                                        'Title already exist!',
                                                        style: TextStyle(
                                                            color: Colors.red
                                                        ),
                                                      );
                                                    });
                                                  }
                                                },
                                                child: Text(
                                                  'Отправить',
                                                  style: TextStyle(
                                                      color: Colors.white
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          sss
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
                  }
              ) : Container(),
              drawer: MyDrawer(),
            );
          }
      ),
    );
  }

  onSearchTextChanged2(String text) async {
    if (_searchResult != null) {
      _searchResult.clear();
      if (text.isEmpty) {
        setState(() {});
        return;
      }

      _searchResult = _groupResult.where((element) =>
      element.title.toUpperCase().contains(text.toUpperCase())).toList();

      setState(() {});
    }
  }
}

class GroupDetails {
  final String id, mentorId, title, profileIds;

  GroupDetails({this.id, this.mentorId, this.title, this.profileIds});

  factory GroupDetails.fromJson(Map<String, dynamic> json) {
    return new GroupDetails(
      id: json['id'],
      mentorId: json['mentorId'],
      title: json['title'],
      profileIds: json['profileIds'],
    );
  }
}
