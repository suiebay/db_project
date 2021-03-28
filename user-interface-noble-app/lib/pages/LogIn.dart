import 'dart:convert';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:icofont_flutter/icofont_flutter.dart';
import 'dart:io' show Platform;

import 'package:mds_reads/pages/user/user_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mds_reads/globals.dart' as globals;

import '../main.dart';

class Token {
  final String accessToken;
  final String refreshToken;

  Token(this.accessToken, this.refreshToken);

  Token.fromJson(Map<String, dynamic> json)
      : accessToken = json['accessToken'],
        refreshToken = json['refreshToken'];

  Map<String, dynamic> toJson() =>
      {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
}

Future<http.Response> logInRequest(String username, String password) async {
  Box box = Hive.box('config');
  var url;
  print(box.get('url'));
  if(Platform.isAndroid) url = '${box.get('url')}/api/auth/signin';
  else if(Platform.isIOS) url = '${box.get('url')}/api/auth/signin';

  Map data = {
    'username': username,
    'password': password,
  };
  //encode Map to JSON
  var body = json.encode(data);
  var response;
  try {
    response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: body
    );
  } catch (_){
    print('error');
    throw _;
  }


  return response;
}

Future<http.Response> getRoles(String token) async {
  Box box = Hive.box('config');
  var url;
  if(Platform.isAndroid) { url = ('${box.get('url')}/api/user/role'); }
  else if(Platform.isIOS) { url = ('${box.get('url')}/api/user/role'); }

  var response = await http.get(url,
    headers: {'Authorization': 'Bearer $token'},
  );

  return response;
}

getStringValuesSF(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String stringValue = prefs.getString(key);
  return stringValue;
}

Future<http.Response> getMyProfile(http.Client client, String token) async {
  Box box = Hive.box('config');
  var url;
  if(Platform.isAndroid) { url = '${box.get('url')}/api/myprofile'; }
  else if(Platform.isIOS) { url = '${box.get('url')}/api/myprofile'; }

  final http.Response response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
  );

  return response;
}

class LogInPage extends StatefulWidget {
  @override
  _LogInPageState createState() => _LogInPageState();
}

addStringToSF(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
}

addIntToSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt('stringValue', 10);
}

class _LogInPageState extends State<LogInPage> {
  var status;
  var profileInformation;
  final username = TextEditingController();
  final password = TextEditingController();
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  String changedPassword;
  String changedUsername;
  bool isLoading = false;
  bool isChanged = true;

  String validateUsername(String value) {
    if (value.length == 0) {
      return '';
    }
    return null;
  }

  String validatePassword(String value) {
    if (value.length == 0) {
      return '';
    }
    return null;
  }

  bool _sendToServer() {
    if (_key.currentState.validate()) {
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

  bool _obscureText = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  FocusNode _focusNode;
  FocusNode _focusNode2;

  @override
  void initState() {
    super.initState();
    _focusNode = new FocusNode();
    _focusNode.addListener(_onOnFocusNodeEvent);
    _focusNode2 = new FocusNode();
    _focusNode2.addListener(_onOnFocusNodeEvent2);
  }

  _onOnFocusNodeEvent() {
    setState(() {
      // Re-renders
    });
  }

  _onOnFocusNodeEvent2() {
    setState(() {
      // Re-renders
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
            backgroundColor: Color(0xFF213a8f),
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: Color(0xFF213A8F),
              elevation: 0,
            ),
            body: Center(
              child: SingleChildScrollView(
                reverse: true,
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery
                      .of(context)
                      .viewInsets
                      .bottom),
                  child: Form(
                    key: _key,
                    // ignore: deprecated_member_use
                    autovalidate: _validate,
                    child: Column(
                      children: <Widget>[
                        Image(
                            height: 70,
                            fit: BoxFit.fitWidth,
                            image: AssetImage('assets/logo-white2.png')
                        ),
                        SizedBox(height: 40,),
                        Theme(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 35),
                            child: TextFormField(
                              validator: validateUsername,
                              controller: username,
                              textAlign: TextAlign.left,
                              cursorColor: Colors.grey[700],
                              cursorWidth: 1.5,
                              focusNode: _focusNode,
                              style: TextStyle(
                                  fontFamily: 'RobotoMedium',
                                  fontSize: 16,
                                  color: Colors.grey[800]
                              ),
                              maxLines: 1,
                              decoration: InputDecoration(
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(50.0)),
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 1.0,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(50.0),
                                  ),
                                  borderSide: BorderSide(
                                    color: Colors.red[600],
                                    width: 1.0,
                                  ),
                                ),
                                errorStyle: TextStyle(
                                    height: 0,
                                    fontSize: 12,
                                    fontFamily: "RobotoBold",
                                    color: Colors.red
                                ),
                                contentPadding: EdgeInsets
                                    .symmetric(
                                    vertical: 0.0),
                                filled: true,
                                fillColor: _focusNode.hasFocus &&
                                    _validate == false
                                    ? Colors.white
                                    : _validate == true &&
                                    (changedUsername == null ||
                                        changedUsername.length == 0)
                                    ? Colors.red[100]
                                    : Colors.grey[100],
                                hintText: 'Username',
                                hintStyle: TextStyle(
                                    fontFamily: 'RobotoMedium',
                                    fontSize: 16,
                                    height: 0.6,
                                    color: Colors.grey[400]
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(50.0),
                                  ),
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(50.0)),
                                  borderSide: BorderSide(
                                      color: Colors.transparent),
                                ),
                                prefixIcon: Icon(
                                  IcoFontIcons.uiUser,
                                  color: Colors.grey[400],
                                ),
                              ),
                              onChanged: (text) {
                                setState(() {
                                  changedUsername = text;
                                  isChanged = true;
                                });
                              },
                            ),
                          ),
                          data: Theme.of(context)
                              .copyWith(
                            primaryColor: Colors.grey[400],),
                        ),
                        SizedBox(height: 30,),
                        Theme(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 35),
                            child: TextFormField(
                              validator: validatePassword,
                              controller: password,
                              textAlign: TextAlign.left,
                              cursorColor: Colors.grey[700],
                              cursorWidth: 1.5,
                              focusNode: _focusNode2,
                              style: TextStyle(
                                  fontFamily: 'RobotoMedium',
                                  fontSize: 16,
                                  color: Colors.grey[800]
                              ),
                              maxLines: 1,
                              decoration: InputDecoration(
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(50.0)),
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1.0,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(50.0),
                                    ),
                                    borderSide: BorderSide(
                                      color: Colors.red[600],
                                      width: 1.0,
                                    ),
                                  ),
                                  errorStyle: TextStyle(
                                      height: 0,
                                      fontSize: 12,
                                      fontFamily: "RobotoBold",
                                      color: Colors.red
                                  ),
                                  contentPadding: EdgeInsets
                                      .symmetric(
                                      vertical: 0.0),
                                  filled: true,
                                  fillColor: _focusNode2.hasFocus &&
                                      _validate == false
                                      ? Colors.white
                                      : _validate == true &&
                                      (changedPassword == null ||
                                          changedPassword.length == 0)
                                      ? Colors.red[100]
                                      : Colors.grey[100],
                                  hintText: 'Password',
                                  hintStyle: TextStyle(
                                      fontFamily: 'RobotoMedium',
                                      fontSize: 16,
                                      height: 0.6,
                                      color: Colors.grey[400]
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(50.0),
                                    ),
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(50.0)),
                                    borderSide: BorderSide(
                                        color: Colors.transparent),
                                  ),
                                  prefixIcon: Icon(
                                    IcoFontIcons.lock,
                                    color: Colors.grey[400],
                                  ),
                                  suffixIcon: IconButton(
                                    icon: _obscureText ? Padding(
                                      padding: const EdgeInsets
                                          .only(
                                          top: 1),
                                      child: Icon(IcoFontIcons.eye),
                                    ) : Icon(
                                        IcoFontIcons.eyeBlocked),
                                    color: Colors.grey[400],
                                    onPressed: _toggle,
                                  )
                              ),
                              obscureText: _obscureText,
                              onChanged: (text) {
                                setState(() {
                                  changedPassword = text;
                                  isChanged = true;
                                });
                              },
                            ),
                          ),
                          data: Theme.of(context)
                              .copyWith(
                            primaryColor: Colors.grey[600],),
                        ),
                        SizedBox(height: 33),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 35),
                          child: SizedBox(
                            height: 45,
                            width: MediaQuery
                                .of(context)
                                .size
                                .width,
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius
                                      .circular(
                                      50.0)),
                              color: isChanged == true
                                  ? Color(0xFFf49330)
                                  : Color(0xFFf49330).withOpacity(
                                  0.7),
                              onPressed: () async {
                                FocusScope.of(context).unfocus();
                                Fluttertoast.cancel();
                                if (isChanged == true) {
                                  if (_sendToServer()) {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    status = await logInRequest(
                                      username.text,
                                      password.text,
                                    );
                                    if (status != null && status.statusCode == 200) {
                                      Map tokenMap = jsonDecode(status.body);
                                      var tokens = Token.fromJson(tokenMap);
                                      addStringToSF('accessToken', tokens.accessToken);
                                      addStringToSF('refreshToken', tokens.refreshToken);
                                      globals.accessTokenG = tokens.accessToken;
                                      globals.searchByG = 'All';
                                      globals.previousSearchByG = 'All';
                                      profileInformation = await getMyProfile(
                                          http.Client(), tokens.accessToken);
                                      if (profileInformation.statusCode == 200) {
                                        String body = utf8.decode(
                                            profileInformation.bodyBytes);
                                        //var ans = parseProfileDetails(body);
                                        var ans = json.decode(body);
                                        globals.gender = ans['gender'];
                                        addStringToSF('userId', ans['id']);
                                        BackgroundFetch.configure(BackgroundFetchConfig(
                                          minimumFetchInterval: 15,
                                          forceAlarmManager: false,
                                          stopOnTerminate: false,
                                          startOnBoot: true,
                                          enableHeadless: true,
                                          requiresBatteryNotLow: false,
                                          requiresCharging: false,
                                          requiresStorageNotLow: false,
                                          requiresDeviceIdle: false,
                                          requiredNetworkType: NetworkType.NONE,
                                        ), backgroundFetchHeadlessTask).then((int status) {
                                          backgroundFetchHeadlessTask("com.transistorsoft.customtask");
                                          print('[BackgroundFetch] configure success: $status');
                                        }).catchError((e) {
                                          print('[BackgroundFetch] configure ERROR: $e');
                                        });
                                        var isAdmin = await getRoles(globals.accessTokenG);
                                        String bodyAdmin = utf8.decode(isAdmin.bodyBytes);
                                        final responseJson = json.decode(bodyAdmin);
                                        print(responseJson);
                                        if(responseJson['value'].contains('ADMIN')) {
                                          globals.isAdmin = responseJson['status'];
                                          addStringToSF('isAdmin', '1');
                                        }
                                        print(responseJson['value']);
                                        if(responseJson['value'].contains('MENTOR')) {
                                          globals.isMentor = 1;
                                          addStringToSF('isMentor', '1');
                                        }

                                        setState(() {
                                          isLoading = false;
                                        });
                                        // Navigator.pop(context);
                                        // Navigator.pop(context);
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UserPage(
                                                    profileDetails: ans),
                                          ),
                                        );
                                        Fluttertoast.showToast(
                                          msg: 'Login successful',
                                          toastLength: Toast
                                              .LENGTH_SHORT,
                                          gravity: ToastGravity
                                              .BOTTOM,
                                        );
                                      }
                                    } else {
                                      setState(() {
                                        isLoading = false;
                                        isChanged = false;
                                      });
                                      Fluttertoast.showToast(
                                        msg: 'User not found or password wrong',
                                        toastLength: Toast
                                            .LENGTH_SHORT,
                                        gravity: ToastGravity
                                            .BOTTOM,
                                      );
                                    }
                                  }
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center,
                                children: <Widget>[
                                  isLoading ? SpinKitCircle(
                                    color: Colors.white,
                                    size: 25,
                                  ) : Text(
                                    'Login',
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontFamily: 'RobotoBold',
                                        color: Colors.white
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom + MediaQuery.of(context).padding.top,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
        )
    );
  }
}
