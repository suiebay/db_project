import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:mds_reads/pages/error_page.dart';

import 'package:mds_reads/pages/user/user_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../drawer.dart';
import 'package:mds_reads/globals.dart' as globals;

class RatingUsers extends StatefulWidget {
  @override
  _MyHomeState createState() => new _MyHomeState();
}

getStringValuesSF(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String stringValue = prefs.getString(key);
  return stringValue;
}

addStringToSF(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
}

class _MyHomeState extends State<RatingUsers> {
  List _searchResult = [];
  String filter = 'Title';
  String searchText = 'Loading...';
  TextEditingController controller = new TextEditingController();
  int counter = 0;


  Map isClosedMap = Map<String, bool>();

  void refreshState() {
    setState(() {
    });
  }

  static int page = 1;
  static int pageSearch = 1;
  ScrollController _sc = new ScrollController();
  ScrollController _scSearch = new ScrollController();
  bool isLoading = false;
  List users = new List();
  bool networkImg = false;

  @override
  void initState() {
    super.initState();
    page = 1;
    pageSearch = 1;

    this._getMoreDataAll(page);

    _sc.addListener(() {
      if (_sc.position.pixels ==
          _sc.position.maxScrollExtent) {
        _getMoreDataAll(page);
      }
    });
    _scSearch.addListener(() {
      if (_scSearch.position.pixels ==
          _scSearch.position.maxScrollExtent) {
        _getMoreDataSearch(pageSearch, controller.text);
      }
    });
  }

  @override
  void dispose() {
    _sc.dispose();
    _scSearch.dispose();
    super.dispose();
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
            IconButton(
              icon: new Icon(Icons.filter_list),
              onPressed: () async{
                FocusScope.of(context).unfocus();
                showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                    ),
                    builder: (BuildContext bc){
                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
//                        height: globals.isAdmin == 1 ? 361 : 302,
                        height: MediaQuery.of(context).size.height * .35,
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              InkWell(
                                child: SizedBox(
//                                  width: double.infinity,
                                  child: Row(
//                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      CircleAvatar(
                                        backgroundColor: Colors.transparent,
                                        backgroundImage: AssetImage('assets/all_profile.png'),
                                        radius: 22,
                                      ),
                                      SizedBox(width: 10,),
                                      Text(
                                        'ALL READERS',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontFamily: globals.searchByG == 'All' ? 'RobotoMedium' : 'RobotoLight'
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  globals.previousSearchByG = globals.searchByG;
                                  globals.searchByG = 'All';
                                  if (globals.previousSearchByG != globals.searchByG) {
                                    _getMoreDataAll(1);
                                  }
                                },
                              ),
                              SizedBox(height: 20, child: Divider(color: Colors.grey,),),
                              InkWell(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Row(
//                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(width: 5,),
                                      Image(
                                          height: 45,
                                          fit: BoxFit.fitWidth,
                                          image: AssetImage(
                                              'assets/ic_gold.png')
                                      ),
                                      SizedBox(width: 14),
                                      Text(
                                        'GOLD READERS',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontFamily: globals.searchByG == 'Gold' ? 'RobotoMedium' : 'RobotoLight'
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  globals.previousSearchByG = globals.searchByG;
                                  globals.searchByG = 'Gold';
                                  if (globals.previousSearchByG != globals.searchByG) {
                                    _getMoreDataAll(1);
                                  }
                                },
                              ),
                              SizedBox(height: 20, child: Divider(color: Colors.grey,),),
                              InkWell(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Row(
//                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(width: 5,),
                                      Image(
                                          height: 45,
                                          fit: BoxFit.fitWidth,
                                          image: AssetImage(
                                              'assets/ic_silver.png')
                                      ),
                                      SizedBox(width: 14),
                                      Text(
                                        'SILVER READERS',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontFamily: globals.searchByG == 'Silver' ? 'RobotoMedium' : 'RobotoLight'
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  globals.previousSearchByG = globals.searchByG;
                                  globals.searchByG = 'Silver';
                                  if (globals.previousSearchByG != globals.searchByG) {
                                    _getMoreDataAll(1);
                                  }
                                },
                              ),
                              SizedBox(height: 20, child: Divider(color: Colors.grey,),),
                              InkWell(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Row(
//                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(width: 5,),
                                      Image(
                                          height: 45,
                                          fit: BoxFit.fitWidth,
                                          image: AssetImage(
                                              'assets/ic_bronze.png')
                                      ),
                                      SizedBox(width: 14),
                                      Text(
                                        'BRONZE READERS',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontFamily: globals.searchByG == 'Bronze' ? 'RobotoMedium' : 'RobotoLight'
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  globals.previousSearchByG = globals.searchByG;
                                  globals.searchByG = 'Bronze';
                                  if (globals.previousSearchByG != globals.searchByG) {
                                    _getMoreDataAll(1);
                                  }
                                },
                              ),
                              SizedBox(height: 20, child: Divider(color: Colors.grey,),),
                              InkWell(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Row(
//                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(width: 5,),
                                      Image(
                                          width: 31,
                                          fit: BoxFit.fitWidth,
                                          image: AssetImage(
                                              'assets/none2.png')
                                      ),
                                      SizedBox(width: 14),
                                      Text(
                                        'UNRATED READERS',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontFamily: globals.searchByG == 'Unrated' ? 'RobotoMedium' : 'RobotoLight'
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  globals.previousSearchByG = globals.searchByG;
                                  globals.searchByG = 'Unrated';
                                  if (globals.previousSearchByG != globals.searchByG) {
                                    _getMoreDataAll(1);
                                  }
                                },
                              ),
                              globals.isAdmin == 1 ? SizedBox(height: 18, child: Divider(color: Colors.grey,),) : Container(),
                              globals.isAdmin == 1 ?  InkWell(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Row(
//                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      CircleAvatar(
                                        backgroundColor: Colors.transparent,
                                        backgroundImage: AssetImage('assets/user_def.png'),
                                        radius: 20,
                                      ),
                                      SizedBox(width: 10,),
                                      Text(
                                        'ADMIN READERS',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontFamily: globals.searchByG == 'Admin' ? 'RobotoMedium' : 'RobotoLight'
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  globals.previousSearchByG = globals.searchByG;
                                  globals.searchByG = 'Admin';
                                  if (globals.previousSearchByG != globals.searchByG) {
                                    _getMoreDataAll(1);
                                  }
                                },
                              ) : Container(),
                            ],
                          ),
                        ),
                      );
                    }
                );

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
                            hintText: 'Search',
                            border: InputBorder.none),
                        onChanged: onSearchTextChangedWait
                      ),
                      trailing: controller.text != ''
                          ? new IconButton(
                        icon: new Icon(Icons.cancel),
                        onPressed: () {
                          controller.clear();
                          onSearchTextChanged('');
                        },)
                          : null
                  ),
                ),
                //color: Colors.red,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 60),
              child: StatefulBuilder(
                  builder: (context, setState) {
                    return _searchResult.length != 0 &&
                        controller.text.isNotEmpty &&
                        controller.text.length >= 3
                        ? ListView.builder(
                      itemCount: _searchResult.length % 20 == 0
                          ? _searchResult
                          .length + 1
                          : _searchResult.length,
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      itemBuilder: (context, index) {
                        if (index == _searchResult.length) {
                          return _buildProgressIndicator();
                        } else {
                          _searchResult[index]['firstName'] =
                          _searchResult[index]['firstName'] == ''
                              ? ''
                              : _searchResult[index]['firstName'];
                          _searchResult[index]['lastName'] =
                          _searchResult[index]['lastName'] == ''
                              ? ''
                              : _searchResult[index]['lastName'];
                          _searchResult[index]['middleName'] =
                          _searchResult[index]['middleName'] == null
                              ? ''
                              : _searchResult[index]['middleName'];
                          _searchResult[index]['groupId'] =
                          _searchResult[index]['groupId'] == 'null'
                              ? ''
                              : _searchResult[index]['groupId'];
                          _searchResult[index]['firstName'] =
                              _searchResult[index]['firstName'].trim();
                          _searchResult[index]['lastName'] =
                              _searchResult[index]['lastName'].trim();
                          _searchResult[index]['middleName'] =
                              _searchResult[index]['middleName'].trim();
                          _searchResult[index]['lastName'] =
                          _searchResult[index]['lastName'] == ''
                              ? ''
                              : ' ${_searchResult[index]['lastName']}';
                          _searchResult[index]['middleName'] =
                          _searchResult[index]['middleName'] == null
                              ? ''
                              : ' ${_searchResult[index]['middleName']}';
                          return InkWell(
                            onTap: () {
                              Navigator.push(context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UserPage(profileDetails: _searchResult[index]),
                                ),
                               ).then((value) {
                                refreshState();
                              });
                            },
                            child: Column(
                              children: <Widget>[
                                Container(
                                    margin: EdgeInsets.fromLTRB(4, 0, 4, 0),
                                    height: 90,
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                            child: Stack(
                                                children: <Widget>[
                                                  Container(
                                                      child: CircleAvatar(
                                                        backgroundColor: Colors.transparent,
                                                        backgroundImage: _searchResult[index]['avatar'] != null && _searchResult[index]['avatar'] != '' && (_searchResult[index]['gender'] == globals.gender || globals.isAdmin == 1) ?
                                                        NetworkImage(_searchResult[index]['avatar'])
                                                            : _searchResult[index]['gender'] == 1 ? AssetImage('assets/profile_boy.png')
                                                            : AssetImage('assets/profile_girl.png'),
                                                        radius: 40,
                                                      ),
                                                      padding: EdgeInsets.all(3.0),
                                                      decoration: BoxDecoration(
                                                        color: _searchResult[index]['readsPoint'] >= 750 && _searchResult[index]['readsFinishedBooks'] >= 50 && _searchResult[index]['readsReviewNumber'] >= 50
                                                            ? Color(0xFFFFD700)
                                                            : _searchResult[index]['readsPoint'] >= 300 &&  _searchResult[index]['readsFinishedBooks'] >= 20 && _searchResult[index]['readsReviewNumber'] >= 20
                                                            && (_searchResult[index]['readsPoint'] < 750 || _searchResult[index]['readsFinishedBooks'] < 50 && _searchResult[index]['readsReviewNumber'] < 50)
                                                            ? Color(0xFFC0C0C0)
                                                            : _searchResult[index]['readsPoint'] >= 75 && _searchResult[index]['readsFinishedBooks'] >= 5 && _searchResult[index]['readsReviewNumber'] >= 5
                                                            && (_searchResult[index]['readsPoint'] < 300 || _searchResult[index]['readsFinishedBooks'] < 20 && _searchResult[index]['readsReviewNumber'] < 20)
                                                            ? Color(0xFFCD7F32)
                                                            : Colors.white,
                                                        shape: BoxShape
                                                            .circle,
                                                      )
                                                  ),
                                                  Positioned(
                                                    bottom: 0,
                                                    right: 0,
                                                    child: Image(
                                                      image: _searchResult[index]['readsPoint'] >= 750 && _searchResult[index]['readsFinishedBooks'] >= 50 && _searchResult[index]['readsReviewNumber'] >= 50
                                                          ? AssetImage('assets/ic_gold.png')
                                                          : _searchResult[index]['readsPoint'] >= 300 && _searchResult[index]['readsFinishedBooks'] >= 20 && _searchResult[index]['readsReviewNumber'] >= 20
                                                          && (_searchResult[index]['readsPoint'] < 750 || _searchResult[index]['readsFinishedBooks'] < 50 && _searchResult[index]['readsReviewNumber'] < 50)
                                                          ? AssetImage('assets/ic_silver.png')
                                                          : _searchResult[index]['readsPoint'] >= 75 && _searchResult[index]['readsFinishedBooks'] >= 5 && _searchResult[index]['readsReviewNumber'] >= 5
                                                          && (_searchResult[index]['readsPoint'] < 300 || _searchResult[index]['readsFinishedBooks'] < 20 && _searchResult[index]['readsReviewNumber'] < 20)
                                                          ? AssetImage('assets/ic_bronze.png')
                                                          : AssetImage('assets/transparent.png'),
                                                      width: 30,
                                                    ),
                                                  )
                                                ]
                                            )
                                        ),
                                        SizedBox(width: 15,),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Spacer(),
                                            SizedBox(
                                              width: 200,
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                child: Text(
                                                  '${_searchResult[index]['firstName']}${_searchResult[index]['lastName']}${_searchResult[index]['middleName']}',
                                                  style: TextStyle(
                                                      fontFamily: 'RobotoBold',
                                                      fontSize: 15,
                                                      color: Colors.grey[600]
                                                  ),
                                                  overflow: TextOverflow
                                                      .ellipsis,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 6,),
                                            SizedBox(
                                              width: 200,
                                              child: Row(
                                                children: <Widget>[
                                                  Column(
                                                    children: <Widget>[
                                                      SizedBox(
                                                        height: 1,),
                                                      Icon(
                                                        Icons.stars,
                                                        size: 17,
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(width: 3,),
                                                  Text(
                                                    _searchResult[index]['readsPoint']
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors
                                                            .grey[600],
                                                        fontSize: 15,
                                                        fontFamily: 'RobotoBold'
                                                    ),
                                                  ),
                                                  SizedBox(width: 13,),
                                                  Icon(
                                                    Icons.book,
                                                    size: 17,
                                                  ),
                                                  SizedBox(width: 3,),
                                                  Text(
                                                    _searchResult[index]['readsFinishedBooks']
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors
                                                            .grey[600],
                                                        fontSize: 15,
                                                        fontFamily: 'RobotoBold'
                                                    ),
                                                  ),
                                                  SizedBox(width: 13,),
                                                  Column(
                                                    children: <Widget>[
                                                      SizedBox(
                                                        height: 1,),
                                                      Icon(
                                                        Icons.rate_review,
                                                        size: 17,
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(width: 3,),
                                                  Text(
                                                    _searchResult[index]['readsReviewNumber']
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors
                                                            .grey[600],
                                                        fontSize: 15,
                                                        fontFamily: 'RobotoBold'
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 6,),
                                            SizedBox(
                                              width: 200,
                                              child: Text(
                                                //'${users[index]['groupId']} ',
                                                'MDS Group',
                                                style: TextStyle(
                                                    fontFamily: 'RobotoBold',
                                                    fontSize: 15,
                                                    color: Colors.grey[600]
                                                ),
                                              ),
                                            ),
                                            Spacer(),
                                          ],
                                        ),
                                        Spacer(),
                                        Text(
                                          (index + 1).toString(),
                                          style: TextStyle(
                                              fontSize: 25,
                                              fontFamily: 'QuickLight'
                                          ),
                                        ),
                                        SizedBox(width: 9,)
                                      ],
                                    )
                                ),
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
                        }
                      },
                      controller: _scSearch,
                    ) : controller.text.length >= 3 &&
                        _searchResult.length == 0
                        ?
                    SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: searchText != 'Loading...' ? Text(
                          searchText,
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'RobotoBold',
                              color: Colors.grey[500]
                          ),
                        ) : SpinKitCircle(
                          color: Color(0xFF213a8f),
                          size: 40,
                        ),
                      ),
                    )
                        : controller.text.length >= 1 &&
                        controller.text.length <= 2 ?
                    SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          'At least 3 letters to search...',
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'RobotoBold',
                              color: Colors.grey[500]
                          ),
                        ),
                      ),
                    ) : ListView.builder(
                      itemCount: users.length % 20 == 0
                          ? users.length + 1
                          : users.length,
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      itemBuilder: (BuildContext context, int index) {
                        if (index == users.length) {
                          return _buildProgressIndicator();
                        } else {
                          users[index]['firstName'] =
                          users[index]['firstName'] == ''
                              ? ''
                              : users[index]['firstName'];
                          users[index]['lastName'] =
                          users[index]['lastName'] == ''
                              ? ''
                              : users[index]['lastName'];
                          users[index]['middleName'] =
                          users[index]['middleName'] == null
                              ? ''
                              : users[index]['middleName'];
                          users[index]['groupId'] =
                          users[index]['groupId'] == 'null'
                              ? ''
                              : users[index]['groupId'];
                          users[index]['firstName'] =
                              users[index]['firstName'].trim();
                          users[index]['lastName'] =
                              users[index]['lastName'].trim();
                          users[index]['middleName'] =
                              users[index]['middleName'].trim();
                          users[index]['lastName'] =
                          users[index]['lastName'] == ''
                              ? ''
                              : ' ${users[index]['lastName']}';
                          users[index]['middleName'] =
                          users[index]['middleName'] == null
                              ? ''
                              : ' ${users[index]['middleName']}';
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UserPage(profileDetails: users[index]),
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
                                            child: Stack(
                                                children: <Widget>[
                                                  Container(
                                                      child: CircleAvatar(
                                                        backgroundColor: Colors.transparent,
                                                        backgroundImage: users[index]['avatar'] != null && users[index]['avatar'] != '' && (users[index]['gender'] == globals.gender || globals.isAdmin == 1)
                                                            ? NetworkImage(users[index]['avatar'])
                                                            : users[index]['gender'] == 1 ? AssetImage('assets/profile_boy.png')
                                                            : AssetImage('assets/profile_girl.png'),
                                                        radius: 40,
                                                      ),
                                                      padding: EdgeInsets.all(3.0),
                                                      decoration: BoxDecoration(
                                                        color: users[index]['readsPoint'] >= 750 && users[index]['readsFinishedBooks'] >= 50 && users[index]['readsReviewNumber'] >= 50
                                                            ? Color(0xFFFFD700)
                                                            : users[index]['readsPoint'] >= 300 &&  users[index]['readsFinishedBooks'] >= 20 && users[index]['readsReviewNumber'] >= 20
                                                            && (users[index]['readsPoint'] < 750 || users[index]['readsFinishedBooks'] < 50 && users[index]['readsReviewNumber'] < 50)
                                                            ? Color(0xFFC0C0C0)
                                                            : users[index]['readsPoint'] >= 75 && users[index]['readsFinishedBooks'] >= 5 && users[index]['readsReviewNumber'] >= 5
                                                            && (users[index]['readsPoint'] < 300 || users[index]['readsFinishedBooks'] < 20 && users[index]['readsReviewNumber'] < 20)
                                                            ? Color(0xFFCD7F32)
                                                            : Colors.white,
                                                        shape: BoxShape.circle,
                                                      )
                                                  ),
                                                  Positioned(
                                                    bottom: 0,
                                                    right: 0,
                                                    child: Image(
                                                      image: users[index]['readsPoint'] >= 750 && users[index]['readsFinishedBooks'] >= 50 && users[index]['readsReviewNumber'] >= 50
                                                          ? AssetImage('assets/ic_gold.png')
                                                          : users[index]['readsPoint'] >= 300 && users[index]['readsFinishedBooks'] >= 20 && users[index]['readsReviewNumber'] >= 20
                                                          && (users[index]['readsPoint'] < 750 || users[index]['readsFinishedBooks'] < 50 && users[index]['readsReviewNumber'] < 50)
                                                          ? AssetImage('assets/ic_silver.png')
                                                          : users[index]['readsPoint'] >= 75 && users[index]['readsFinishedBooks'] >= 5 && users[index]['readsReviewNumber'] >= 5
                                                          && (users[index]['readsPoint'] < 300 || users[index]['readsFinishedBooks'] < 20 && users[index]['readsReviewNumber'] < 20)
                                                          ? AssetImage('assets/ic_bronze.png')
                                                          : AssetImage('assets/transparent.png'),
                                                      width: 30,
                                                    ),
                                                  )
                                                ]
                                            )
                                        ),
                                        SizedBox(width: 15,),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(
                                              width: 200,
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                child: Text(
                                                  '${users[index]['firstName']}${users[index]['lastName']}${users[index]['middleName']}',
                                                  style: TextStyle(
                                                      fontFamily: 'RobotoBold',
                                                      fontSize: 15,
                                                      color: Colors.grey[600]
                                                  ),
                                                  overflow: TextOverflow
                                                      .ellipsis,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 6,),
                                            SizedBox(
                                              width: 200,
                                              child: Row(
                                                children: <Widget>[
                                                  Column(
                                                    children: <Widget>[
                                                      SizedBox(
                                                        height: 1,),
                                                      Icon(
                                                        Icons.stars,
                                                        size: 17,
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(width: 3,),
                                                  Text(
                                                    users[index]['readsPoint']
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors
                                                            .grey[600],
                                                        fontSize: 15,
                                                        fontFamily: 'RobotoBold'
                                                    ),
                                                  ),
                                                  SizedBox(width: 13,),
                                                  Icon(
                                                    Icons.book,
                                                    size: 17,
                                                  ),
                                                  SizedBox(width: 3,),
                                                  Text(
                                                    users[index]['readsFinishedBooks']
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors
                                                            .grey[600],
                                                        fontSize: 15,
                                                        fontFamily: 'RobotoBold'
                                                    ),
                                                  ),
                                                  SizedBox(width: 13,),
                                                  Column(
                                                    children: <Widget>[
                                                      SizedBox(
                                                        height: 1,),
                                                      Icon(
                                                        Icons.rate_review,
                                                        size: 17,
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(width: 3,),
                                                  Text(
                                                    users[index]['readsReviewNumber']
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors
                                                            .grey[600],
                                                        fontSize: 15,
                                                        fontFamily: 'RobotoBold'
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 6,),
                                            SizedBox(
                                              width: 200,
                                              child: Text(
                                                //'${users[index]['groupId']} ',
                                                'MDS Group',
                                                style: TextStyle(
                                                    fontFamily: 'RobotoBold',
                                                    fontSize: 15,
                                                    color: Colors
                                                        .grey[600]
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacer(),
                                        Text(
                                          (index + 1).toString(),
                                          style: TextStyle(
                                              fontSize: 25,
                                              fontFamily: 'QuickLight'
                                          ),
                                        ),
                                        SizedBox(width: 9,)
                                      ],
                                    )
                                ),
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
                        }
                      },
                      controller: _sc,
                    );
                  }
              ),
            ),

          ],
        ),
        drawer: MyDrawer(),
      ),
    );
  }

  void _getMoreDataAll(int pageNum) async {
    Box box = Hive.box('config');
    controller.text = '';

    if(globals.previousSearchByG != globals.searchByG) {
      setState(() {
        searchText = 'Loading...';
        page = 1;
        pageNum = 1;
        users.clear();
        globals.previousSearchByG = globals.searchByG;
      });
    }
    if(pageNum == 1 || pageNum >= 2 && (pageNum - 1) * 20 == users.length) {
      if (controller.text.length == 0) {
        if (!isLoading) {
          setState(() {
            isLoading = true;
          });
          try {
            var url;
            if (globals.searchByG == 'All') {
              if (Platform.isAndroid) {
                url = ('${box.get('url')}/api/reads/user-list/$pageNum');
              }
              else if (Platform.isIOS) {
                url = ('${box.get('url')}/api/reads/user-list/$pageNum');
              }
            }
            if (globals.searchByG == 'Gold') {
              if (Platform.isAndroid) {
                url =
                ('${box.get('url')}/api/reads/gold-user-list/$pageNum');
              }
              else if (Platform.isIOS) {
                url =
                ('${box.get('url')}/api/reads/gold-user-list/$pageNum');
              }
            }
            if (globals.searchByG == 'Silver') {
              if (Platform.isAndroid) {
                url =
                ('${box.get('url')}/api/reads/silver-user-list/$pageNum');
              }
              else if (Platform.isIOS) {
                url =
                ('${box.get('url')}/api/reads/silver-user-list/$pageNum');
              }
            }
            if (globals.searchByG == 'Bronze') {
              if (Platform.isAndroid) {
                url =
                ('${box.get('url')}/api/reads/bronze-user-list/$pageNum');
              }
              else if (Platform.isIOS) {
                url =
                ('${box.get('url')}/api/reads/bronze-user-list/$pageNum');
              }
            }
            if (globals.searchByG == 'Unrated') {
              if (Platform.isAndroid) {
                url =
                ('${box.get('url')}/api/reads/unrated-user-list/$pageNum');
              }
              else if (Platform.isIOS) {
                url =
                ('${box.get('url')}/api/reads/unrated-user-list/$pageNum');
              }
            }
            if (globals.searchByG == 'Admin') {
              if (Platform.isAndroid) {
                url = ('${box.get('url')}/api/reads/admin-list/$pageNum');
              }
              else if (Platform.isIOS) {
                url = ('${box.get('url')}/api/reads/admin-list/$pageNum');
              }
            }

            var response;

            response = await http.get(url,
              headers: {'Authorization': 'Bearer ${globals.accessTokenG}'},
            ).timeout(Duration(seconds: globals.duration));

            String body = utf8.decode(response.bodyBytes);
            final responseJson = json.decode(body);

            for (int i = 0; i < responseJson.length; i++) {
              if (!users.contains(responseJson[i])) {
                users.add(responseJson[i]);
              }
            }

            setState(() {
              searchText = 'User not found';
              isLoading = false;
              page++;
            });
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
      }
    }
  }

  _getMoreDataSearch(int pageNum, String word) async {
    Box box = Hive.box('config');
    if(word.length >= 3) {
      if (pageSearch == 1 ||
          pageSearch >= 2 && (pageSearch - 1) * 20 == _searchResult.length) {
        if (!isLoading) {
          setState(() {
            searchText = 'Loading...';
            isLoading = true;
          });
          var url;
          if (Platform.isAndroid) {
            url = '${box.get('url')}/api/reads/user-list/$pageNum/search?word=$word';
          }
          else if (Platform.isIOS) {
            url = '${box.get('url')}/api/reads/user-list/$pageNum/search?word=$word';
          }
          final http.Response response = await http.get(url,
            headers: {'Authorization': 'Bearer ${globals.accessTokenG}'},
          );


          String body = utf8.decode(response.bodyBytes);
          final responseJson = json.decode(body);

          for (int i = 0; i < responseJson.length; i++) {
            if (!_searchResult.contains(responseJson[i])) {
              _searchResult.add(responseJson[i]);
            }
          }

          setState(() {
            searchText = 'User not found';
            isLoading = false;
            pageSearch++;
          });
        }
      }
    } else {
      pageSearch = 1;
      _searchResult.clear();
    }
    if(word.length == 0 || word == ''){
      page = 1;
      users.clear();
      globals.searchByG = 'All';
      globals.previousSearchByG = 'All';
      _getMoreDataAll(1);
    }
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: <Widget>[
        Center(
          child: new Opacity(
            opacity: isLoading ? 1.0 : 00,
            child: SpinKitCircle(
              color: Color(0xFF213a8f),
              size: 40,
            ),
          ),
        ),
      ],
    );
  }

  Timer searchOnStoppedTyping;

  onSearchTextChangedWait(String text){
    pageSearch = 1;
    _searchResult.clear();
    const duration = Duration(milliseconds:1000);
    if (searchOnStoppedTyping != null) {
      setState(() {
        searchText = 'Loading...';
        searchOnStoppedTyping.cancel();
      });
    }

    setState(() {
      searchOnStoppedTyping = new Timer(duration, () => onSearchTextChanged(text));
      searchText = 'Loading...';
      users.clear();
    });
  }

  onSearchTextChanged(String text) async {
    pageSearch = 1;
    _searchResult.clear();
    users.clear();
    setState(() {
      searchText = 'Loading...';
    });

    if (text.length >= 3) {
      if (text.isEmpty) {
        setState(() {});
        return;
      }

      await _getMoreDataSearch(pageSearch, text);

      setState(() {});
    }

    if(text.length == 0 || text == ''){
      page = 1;
      users.clear();
      globals.searchByG = 'All';
      globals.previousSearchByG = 'All';
      _getMoreDataAll(1);
    }
  }
}