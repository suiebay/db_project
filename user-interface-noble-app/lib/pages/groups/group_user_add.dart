import 'dart:convert';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:mds_reads/pages/groups/group_list.dart';
import 'package:mds_reads/pages/groups/users.dart';
import 'package:http/http.dart' as http;
import 'package:mds_reads/globals.dart' as globals;

Future<dynamic> getGroupUsers(http.Client client, String id, String token) async {
  Box box = Hive.box('config');
  var url = '${box.get('url')}/api/reads/group-user-list/$id';

  final http.Response response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
  );

  return response;
}

Future<http.Response> updateReadsGroup(String id, String title, String mentorId, String profileIds, String token) async {
  Box box = Hive.box('config');
  var url = '${box.get('url')}/api/project/mdsreads/groups/update';

  Map data = {
    'id': id,
    'title': title,
    'mentorId': mentorId,
    'profileIds': profileIds,
  };
  //encode Map to JSON
  var body = json.encode(data);

  var response = await http.post(url,
      headers: {"Content-Type": "application/json", 'Authorization': 'Bearer $token'},
      body: body
  );
  return response;
}


class GroupUserAdd extends StatefulWidget {
  GroupDetails groupDetails;

  GroupUserAdd ({ this.groupDetails });

  @override
  _GroupUserAddState createState() => _GroupUserAddState();
}

class _GroupUserAddState extends State<GroupUserAdd> {
  GlobalKey<AutoCompleteTextFieldState<Users>> key = new GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<Users>> keyMentor = new GlobalKey();
  AutoCompleteTextField searchTextField;
  AutoCompleteTextField searchTextFieldMentor;
  TextEditingController controller = new TextEditingController();
  TextEditingController controllerMentor = new TextEditingController();
  List<String> added = [];
  List<String> postAdded = [];
  String addedMentor = "";
  String addedMentorId = "";
  String currentText = "";
  String currentTextMentor = "";
  MediaQueryData queryData;
  var status;
  bool isLoading = false;
  _GroupUserAddState();


  void _loadData() async {
    await UsersViewModel.loadPlayers();
  }

  void _loadData2() async {
    await MentorsViewModel.loadPlayers();
  }

  @override
  void initState() {
    _loadData();
    _loadData2();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
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
              'Group',
            ),
          ),
          body: FutureBuilder<dynamic>(
              future: getGroupUsers(
                  http.Client(), widget.groupDetails.id, globals.accessTokenG),
              builder: (context, users) {
                if (users.hasData) {
                  String bodyU = utf8.decode(users.data.bodyBytes);
                  var responseJson = json.decode(bodyU);
                  for (var i in responseJson) {
                    if (!postAdded.contains(i['id'])) {
                      added.add("${i['firstName']} ${i['lastName']}");
                      postAdded.add(i['id']);
                    }
                  }
                  if(widget.groupDetails.mentorId != null) {
                    for(var mentor in MentorsViewModel.mentors) {
                      if(mentor.id == widget.groupDetails.mentorId) {
                        addedMentorId = mentor.id;
                        addedMentor = mentor.autocompleteTerm;
                      }
                    }
                  }
                  return StatefulBuilder(
                      builder: (context, setState) {
                        return SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Container(
                              height: queryData.size.height * 0.89,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      color: Colors.white,
                                      height: 65,
                                      child: Card(
                                        elevation: 2,
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              15, 5, 10, 0),
                                          child: searchTextFieldMentor =
                                              AutoCompleteTextField<Users>(
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16.0),
                                                  decoration: InputDecoration(
                                                    // filled: true,
                                                      hintText: 'Search Mentor Name',
                                                      // hintStyle: TextStyle(color: Colors.grey[400]),
                                                      // fillColor: Colors.grey[700]
                                                      border: InputBorder.none
                                                  ),
                                                  itemSubmitted: (item) =>
                                                      setState(() {
                                                        searchTextFieldMentor.textField
                                                            .controller.text =
                                                            item.autocompleteTerm;
                                                        if (item.autocompleteTerm != "") {
                                                          addedMentor = item.autocompleteTerm;
                                                          addedMentorId = item.id;
                                                        }
                                                      }),
                                                  clearOnSubmit: true,
                                                  key: keyMentor,
                                                  suggestions: MentorsViewModel.mentors,
                                                  textChanged: (text) =>
                                                  currentTextMentor = text,
                                                  itemBuilder: (context, item) {
                                                    return Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        Text(item.autocompleteTerm,
                                                          style: TextStyle(
                                                              fontSize: 16.0
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.all(15.0),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                  itemSorter: (a, b) {
                                                    return a.autocompleteTerm
                                                        .compareTo(b.autocompleteTerm);
                                                  },
                                                  itemFilter: (item, query) {
                                                    return item.autocompleteTerm
                                                        .toLowerCase().contains(
                                                        query.toLowerCase());
                                                  }
                                              ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        color: Colors.white,
                                        height: 65,
                                        child: Card(
                                          elevation: 2,
                                          child: Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                15, 5, 10, 0),
                                            child: searchTextField =
                                                AutoCompleteTextField<
                                                    Users>(
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16.0),
                                                    decoration: InputDecoration(
                                                        hintText: 'Search User Name',
                                                        border: InputBorder
                                                            .none
                                                    ),
                                                    itemSubmitted: (item) =>
                                                        setState(() {
                                                          searchTextField
                                                              .textField
                                                              .controller
                                                              .text =
                                                              item
                                                                  .autocompleteTerm;
                                                          if (item
                                                              .autocompleteTerm !=
                                                              "" && !added
                                                              .contains(
                                                              item
                                                                  .autocompleteTerm)) {
                                                            added.add(
                                                                item
                                                                    .autocompleteTerm);
                                                            postAdded.add(
                                                                item.id);
                                                          }
                                                        }),
                                                    clearOnSubmit: true,
                                                    key: key,
                                                    suggestions: UsersViewModel
                                                        .players,
                                                    textChanged: (text) =>
                                                    currentText = text,
                                                    itemBuilder: (context,
                                                        item) {
                                                      return Row(
                                                        mainAxisAlignment: MainAxisAlignment
                                                            .spaceBetween,
                                                        children: <Widget>[
                                                          Text(
                                                            item
                                                                .autocompleteTerm,
                                                            style: TextStyle(
                                                                fontSize: 16.0
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .all(
                                                                15.0),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                    itemSorter: (a, b) {
                                                      return a
                                                          .autocompleteTerm
                                                          .compareTo(
                                                          b
                                                              .autocompleteTerm);
                                                    },
                                                    itemFilter: (item,
                                                        query) {
                                                      return item
                                                          .autocompleteTerm
                                                          .toLowerCase()
                                                          .contains(
                                                          query
                                                              .toLowerCase());
                                                    }
                                                ),
                                          ),
                                        )
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Divider(
                                          color: Colors.grey[500]
                                      ),
                                    ),
                                    addedMentor != '' ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height: 32,
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width,
                                        child: Card(
                                          color: Colors.green[300],
                                          margin: EdgeInsets.all(0),
                                          elevation: 1,
                                          child: Row(
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets
                                                    .only(
                                                    left: 15),
                                                child: Text(
                                                    addedMentor,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily: "RobotoRegular"
                                                    )
                                                ),
                                              ),
                                              Spacer(),
                                              Padding(
                                                padding: const EdgeInsets
                                                    .only(
                                                    bottom: 1),
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.cancel,
                                                    size: 17,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      addedMentor = "";
                                                      addedMentorId = null;
                                                    });
                                                  },),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ) : Container(),
                                    Container(
                                      // color: Colors.green,
                                      height: addedMentor != '' ? queryData
                                          .size
                                          .height - 378 : queryData.size
                                          .height -
                                          330,
                                      child: ListView.builder(
                                        itemCount: added.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.all(
                                                8.0),
                                            child: Container(
                                              height: 32,
                                              child: Card(
                                                color: Colors.grey[300],
                                                margin: EdgeInsets.all(0),
                                                elevation: 1,
                                                child: Row(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .only(
                                                          left: 15),
                                                      child: Text(
                                                        added[index],
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontFamily: "RobotoRegular"
                                                        ),
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .only(
                                                          bottom: 1),
                                                      child: IconButton(
                                                        icon: Icon(
                                                          Icons.cancel,
                                                          size: 17,
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            added.remove(
                                                                added[index]);
                                                            postAdded
                                                                .remove(
                                                                postAdded[index]);
                                                          });
                                                        },),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Spacer(),
                                    Center(
                                      child: SizedBox(
                                        height: 45,
                                        width: 350,
                                        child: FlatButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(
                                                  30.0)),
                                          color: Color(0xFF213a8f),
                                          onPressed: () async {
                                            isLoading = true;
                                            var profileIds;
                                            if(postAdded.isNotEmpty) {
                                              profileIds = postAdded
                                                  .reduce((value,
                                                  element) =>
                                              value + ',' + element);
                                            }
                                            status = await updateReadsGroup(
                                                widget.groupDetails.id,
                                                widget.groupDetails.title,
                                                addedMentorId,
                                                profileIds,
                                                globals.accessTokenG);
                                            if (status.statusCode == 200) {
                                              Navigator.pop(context);
                                              Fluttertoast.showToast(
                                                msg: 'Group updated',
                                                toastLength: Toast
                                                    .LENGTH_SHORT,
                                                gravity: ToastGravity
                                                    .BOTTOM,
                                              );
                                              setState(() {
                                                isLoading = false;
                                              });
                                            }
                                          },
                                          child: isLoading ? SpinKitCircle(
                                            color: Colors.white,
                                            size: 25,
                                          ) : Text(
                                            'Update',
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontFamily: 'RobotoBold',
                                                color: Colors.white
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                  ]
                              ),
                            )
                        );
                      }
                  );
                } else {
                  return Center(
                      child: SpinKitCircle(
                        color: Color(0xFF213A8F),
                        size: 40,
                      )
                  );
                }
              }
          )
      ),
    );
  }
}
