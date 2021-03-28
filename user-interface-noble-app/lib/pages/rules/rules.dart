import 'dart:convert';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:icofont_flutter/icofont_flutter.dart';
import 'package:mds_reads/colors/floating_button_color.dart';
import 'package:mds_reads/pages/rules/rule_information.dart';
import 'dart:io' show Platform;

import 'package:mds_reads/globals.dart' as globals;
import 'package:mds_reads/widgets/popupmenu_widget.dart';

import '../../drawer.dart';

Future<http.Response> deleteRequest(String id, String token) async {
  Box box = Hive.box('config');
  var url;
  if (Platform.isAndroid)
    url = '${box.get('url')}/api/project/mdsreads/rules/delete/$id';
  else if (Platform.isIOS)
    url = '${box.get('url')}/api/project/mdsreads/rules/delete/$id';

  final http.Response response = await http.delete(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token'
    },
  );

  return response;
}

Future<http.Response> postRequest(String a, String b, String token) async {
  Box box = Hive.box('config');
  var url;
  if (Platform.isAndroid)
    url = '${box.get('url')}/api/project/mdsreads/rules/new';
  else if (Platform.isIOS)
    url = '${box.get('url')}/api/project/mdsreads/rules/new';

  Map data = {'id': null, 'title': a, 'description': b};
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

Future<http.Response> updateRequest(
    String id, String a, String b, String token) async {
  Box box = Hive.box('config');
  var url;
  if (Platform.isAndroid)
    url = '${box.get('url')}/api/project/mdsreads/rules/update';
  else if (Platform.isIOS)
    url = '${box.get('url')}/api/project/mdsreads/rules/update';

  Map data = {'id': id, 'title': a, 'description': b};
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

dynamic fetchProducts(http.Client client, String token) async {
  Box box = Hive.box('config');
  var response;
  try {
    var url;
    if (Platform.isAndroid) {
      url = '${box.get('url')}/api/project/mdsreads/rules/list';
    } else if (Platform.isIOS) {
      url = '${box.get('url')}/api/project/mdsreads/rules/list';
    }

    response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(Duration(seconds: globals.duration));

    String body = utf8.decode(response.bodyBytes);
    return compute(parseRuleInformation, body);
  } on TimeoutException catch (_) {
    return 1;
  }
}

List<RuleInformation> parseRuleInformation(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed
      .map<RuleInformation>((json) => RuleInformation.fromJson(json))
      .toList();
}

class Rules extends StatefulWidget {
  Rules({Key key}) : super(key: key);

  @override
  _RulesState createState() => _RulesState();
}

class _RulesState extends State<Rules> {
  var status;

  Widget sss = Text('');

  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  String title, description;

  final List<Color> ruleColors = <Color>[Colors.blue[700], Colors.cyan[700]];

  int count = 0;
  int counter = 0;

  final ruleTitle = TextEditingController();
  final ruleDescription = TextEditingController();

  void initState() {
    super.initState();
  }

  String validateTitle(String value) {
    if (value.length == 0) {
      return "Title is Required";
    }
    return null;
  }

  String validateDescription(String value) {
    if (value.length == 0) {
      return "Description is Required";
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

  void refreshState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //fillList(rules);
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F7),
      appBar: AppBar(
        backgroundColor: Color(0xFF213A8F),
        title: Text(
          'Rules',
        ),
      ),
      body: StatefulBuilder(builder: (context, setState) {
        return FutureBuilder<dynamic>(
          future: fetchProducts(http.Client(), globals.accessTokenG),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData && snapshot.data != 1) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return SafeArea(
                    child: Container(
                      width: double.maxFinite,
                      //color: Colors.green,
                      margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
                      child: Card(
                        elevation: 3,
                        child: Stack(
                          children: <Widget>[
                            Positioned(
                              left: 0,
                              right: 0,
                              height: 45,
                              child: Card(
                                margin: EdgeInsets.all(0),
                                color: ruleColors[
                                    index % 2], //Colors.blueGrey[500]
                              ),
                            ),
                            Positioned(
                              top: 40,
                              left: 0,
                              right: 0,
                              height: 5,
                              child: Container(
                                margin: EdgeInsets.all(0),
                                color: ruleColors[index % 2],
                              ),
                            ),
                            Positioned(
                              left: 10,
                              top: 12,
                              child: Text(
                                'Rule #${index + 1}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'RobotoMedium',
                                    fontSize: 18),
                              ),
                            ),
                            Positioned(
                              left: 90,
                              top: 13,
                              child: Text(
                                '${snapshot.data[index].title}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'RobotoRegular',
                                    fontSize: 18),
                              ),
                            ),
                            if (globals.isAdmin == 1)
                              Positioned(
                                  right: -5,
                                  top: -1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.black12,
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: PopupMenuButton<int>(
                                        color: Colors.grey[100],
                                        elevation: 10,
                                        icon: IconTheme(
                                          data: new IconThemeData(
                                              color: Colors.white, size: 20),
                                          child: new Icon(Icons.more_vert),
                                        ),
                                        itemBuilder: (context) => [
                                              editPopUpMenuItem(),
                                              deletePopUpMenuItem(),
                                            ],
                                        offset: Offset(0, 100),
                                        onSelected: (value) {
                                          if (value == 1) {
                                            sss = Text('');
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) { return AnimatedContainer(
                                                margin: MediaQuery.of(context)
                                                    .viewInsets,
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                child: StatefulBuilder(
                                                  builder: (context, setState) {
                                                    return AlertDialog(
                                                      content: Container(
                                                          height: 240,
                                                          child: Form(
                                                            key: _key,
                                                            // ignore: deprecated_member_use
                                                            autovalidate:
                                                                _validate,
                                                            child:
                                                                SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis.vertical,
                                                              child: Column(
                                                                children: <
                                                                    Widget>[
                                                                  SizedBox(
                                                                    width: double
                                                                        .infinity,
                                                                    child: Text(
                                                                      'Enter rule title',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'RobotoRegular',
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  TextFormField(
                                                                    autofocus:
                                                                        true,
                                                                    controller: TextEditingController()
                                                                      ..text = snapshot
                                                                          .data[
                                                                              index]
                                                                          .title,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      fillColor: Colors
                                                                          .grey
                                                                          .shade50,
                                                                    ),
                                                                    validator:
                                                                        validateTitle,
                                                                    onSaved:
                                                                        (String
                                                                            val) {
                                                                      title =
                                                                          val;
                                                                    },
                                                                  ),
                                                                  SizedBox(
                                                                    height: 30,
                                                                  ),
                                                                  SizedBox(
                                                                    width: double
                                                                        .infinity,
                                                                    child: Text(
                                                                      'Enter rule description',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'RobotoRegular',
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  TextFormField(
                                                                    maxLines: 2,
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .multiline,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      fillColor: Colors
                                                                          .grey
                                                                          .shade50,
                                                                    ),
                                                                    controller: TextEditingController()
                                                                      ..text = snapshot
                                                                          .data[
                                                                              index]
                                                                          .description,
                                                                    validator:
                                                                        validateDescription,
                                                                    onSaved:
                                                                        (String
                                                                            val) {
                                                                      description =
                                                                          val;
                                                                    },
                                                                  ),
                                                                  SizedBox(
                                                                    height: 15,
                                                                  ),
                                                                  Row(
                                                                    children: <
                                                                        Widget>[
                                                                      FlatButton(
                                                                        color: Colors
                                                                            .orange,
                                                                        onPressed:
                                                                            () {
                                                                          sss =
                                                                              Text('Rule edited');
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child:
                                                                            Text(
                                                                          '  Отмена  ',
                                                                          style:
                                                                              TextStyle(color: Colors.white),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            33,
                                                                      ),
                                                                      FlatButton(
                                                                        color: Colors
                                                                            .purple[800],
                                                                        onPressed:
                                                                            () async {
                                                                          counter =
                                                                              0;
                                                                          if (_sendToServer()) {
                                                                            status = await updateRequest(
                                                                                snapshot.data[index].ruleId,
                                                                                title,
                                                                                description,
                                                                                globals.accessTokenG);
                                                                            if (status.statusCode ==
                                                                                200) {
                                                                              sss = Text('');
                                                                              Navigator.pop(context);
                                                                              Fluttertoast.showToast(
                                                                                msg: 'Rule edited',
                                                                                toastLength: Toast.LENGTH_SHORT,
                                                                                gravity: ToastGravity.BOTTOM,
                                                                              );
                                                                              refreshState();
                                                                              setState(() {
                                                                                sss = Text('');
                                                                              });
                                                                            }
                                                                          }
                                                                          if (status != null &&
                                                                              status.statusCode == 400) {
                                                                            setState(() {
                                                                              sss = Text(
                                                                                'Title already exist!',
                                                                                style: TextStyle(color: Colors.red),
                                                                              );
                                                                            });
                                                                          }
                                                                        },
                                                                        child:
                                                                            Text(
                                                                          'Отправить',
                                                                          style:
                                                                              TextStyle(color: Colors.white),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  //_statusWidget(counter),
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
                                          } else {
                                            showDialog(
                                              context: context,
                                            builder: (BuildContext context) { return AlertDialog(
                                                title: SizedBox(
                                                  width: double.infinity,
                                                  child: Text(
                                                    'Are you sure to delete this rule?',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontFamily:
                                                            'RobotoBold',
                                                        color:
                                                            Colors.grey[700]),
                                                  ),
                                                ),
                                                content: Container(
                                                    height: 160,
                                                    child: SingleChildScrollView(
                                                      scrollDirection: Axis.vertical,
                                                      child: Column(
                                                        children: <Widget>[
                                                          Card(
                                                            elevation: 3,
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                  color: Colors
                                                                      .transparent,
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                    horizontal:
                                                                        15,
                                                                    vertical: 10,
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            snapshot
                                                                                .data[index]
                                                                                .title,
                                                                            textAlign:
                                                                                TextAlign.left,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Divider(
                                                                  color: Colors
                                                                      .black,
                                                                  thickness: 0.8,
                                                                ),
                                                                Container(
                                                                  color: Colors
                                                                      .transparent,
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                    horizontal:
                                                                        15,
                                                                    vertical: 10,
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            snapshot
                                                                                .data[index]
                                                                                .description,
                                                                            textAlign:
                                                                                TextAlign.left,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(height: 10),
                                                          Row(
                                                            children: <Widget>[
                                                              Container(
                                                                color: Color(
                                                                    0xFFea2937),
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
                                                              SizedBox(width: 60),
                                                              Container(
                                                                color: Color(
                                                                    0xFF213a8f),
                                                                width: 100,
                                                                height: 40,
                                                                child: FlatButton(
                                                                  onPressed:
                                                                      () async {
                                                                    status = await deleteRequest(
                                                                        snapshot
                                                                            .data[
                                                                                index]
                                                                            .ruleId,
                                                                        globals
                                                                            .accessTokenG);
                                                                    if (status
                                                                            .statusCode ==
                                                                        200) {
                                                                      Navigator.pop(
                                                                          context);
                                                                      Fluttertoast
                                                                          .showToast(
                                                                        msg:
                                                                            'Rule deleted',
                                                                        toastLength:
                                                                            Toast
                                                                                .LENGTH_SHORT,
                                                                        gravity:
                                                                            ToastGravity
                                                                                .BOTTOM,
                                                                      );
                                                                      setState(
                                                                          () {});
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
                                                      ),
                                                    )),
                                              );}
                                            );
                                          }
                                        }),
                                  ))
                            else
                              Text(''),
                            Positioned(
                              //top: 50,
                              child: Container(
                                padding: EdgeInsets.fromLTRB(10, 55, 10, 10),
                                child: Text(
                                  '${snapshot.data[index].description}',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'RobotoRegular',
                                      fontSize: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.data == 1) {
              return Scaffold(
                  body: Scaffold(
                      backgroundColor: Color(0xFF6F6F7),
                      body: Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            IcoFontIcons.exclamationTringle,
                            color: Colors.grey[500],
                            size: 45,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text("Check your internet connection...",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: "RobotoBold",
                                  color: Colors.grey[500])),
                        ],
                      ))),
                  drawer: MyDrawer());
            } else {
              return Center(
                  child: SpinKitCircle(
                color: Color(0xFF213A8F),
                size: 45,
              ));
            }
          },
        );
      }),
      floatingActionButton: globals.isAdmin == 1
          ? FloatingActionButton(
              child: Icon(Icons.add),
              backgroundColor: floatingButtonColor,
              onPressed: () {
                ruleTitle.text = '';
                ruleDescription.text = '';
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
                              height: 240,
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
                                          'Enter rule title',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontFamily: 'RobotoRegular',
                                          ),
                                        ),
                                      ),
                                      TextFormField(
                                        autofocus: true,
                                        controller: ruleTitle,
                                        decoration: InputDecoration(
                                          fillColor: Colors.grey.shade50,
                                        ),
                                        validator: validateTitle,
                                        onSaved: (String val) {
                                          title = val;
                                        },
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                      SizedBox(
                                        width: double.infinity,
                                        child: Text(
                                          'Enter rule description',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontFamily: 'RobotoRegular',
                                          ),
                                        ),
                                      ),
                                      TextFormField(
                                        maxLines: 2,
                                        keyboardType: TextInputType.multiline,
                                        decoration: InputDecoration(
                                          fillColor: Colors.grey.shade50,
                                        ),
                                        controller: ruleDescription,
                                        validator: validateDescription,
                                        onSaved: (String val) {
                                          description = val;
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
                                              ruleTitle.text = '';
                                              ruleDescription.text = '';
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
                                              counter = 0;
                                              if (_sendToServer()) {
                                                status = await postRequest(
                                                    ruleTitle.text,
                                                    ruleDescription.text,
                                                    globals.accessTokenG);
                                                if (status.statusCode == 200) {
                                                  ruleTitle.text = '';
                                                  ruleDescription.text = '';
                                                  sss = Text('');
                                                  Navigator.pop(context);
                                                  Fluttertoast.showToast(
                                                    msg: 'Rule added',
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                  );
                                                  refreshState();
                                                  setState(() {
                                                    sss = Text('');
                                                  });
                                                }
                                              }
                                              if (status != null &&
                                                  status.statusCode == 400) {
                                                setState(() {
                                                  sss = Text(
                                                    'Title already exist!',
                                                    style: TextStyle(
                                                        color: Colors.red),
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
                                      //_statusWidget(counter),
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
              })
          : Container(),
      drawer: MyDrawer(),
    );
  }
}
