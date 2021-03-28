import 'dart:convert';
import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mds_reads/pages/user/profile_details.dart';
import 'dart:io' show File, Platform;

import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mds_reads/globals.dart' as globals;

Future<http.Response> changeProfileAvatar(String id, String imgStorage, String token) async {
  Box box = Hive.box('config');
  var url;
  if(Platform.isAndroid) url = '${box.get('url')}/api/profile/change-avatar';
  else if(Platform.isIOS) url = '${box.get('url')}/api/profile/change-avatar';

  Map data = {
    'id': id,
    'avatar': imgStorage,
  };
  //encode Map to JSON
  var body = json.encode(data);

  var response = await http.post(url,
      headers: {"Content-Type": "application/json", 'Authorization': 'Bearer $token'},
      body: body
  );
  return response;
}

getStringValuesSF(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String stringValue = prefs.getString(key);
  return stringValue;
}

ProfileDetails parseProfileDetails(String responseBody) {
  Map something = jsonDecode(responseBody);
  var somesome = ProfileDetails.fromJson(something);

  return somesome;
}

Future<Map<dynamic, dynamic>> uploadImage(String type, File file, String token) async {
  Box box = Hive.box('config');
  var url;
  if(Platform.isAndroid) url = '${box.get('url')}/api/file/upload/$type';
  else if(Platform.isIOS) url = '${box.get('url')}/api/file/upload/$type';

  Map<String, String> headers = {'Authorization': 'Bearer $token'};

  // ignore: deprecated_member_use
  var stream = new http.ByteStream(DelegatingStream.typed(file.openRead()));
  var length = await file.length();
  var uri = Uri.parse(url);
  var request = new http.MultipartRequest("POST", uri);
  request.headers.addAll(headers);

  var multipartFile = new http.MultipartFile('file', stream, length,
      filename: basename(file.path));
  request.files.add(multipartFile);

  var response = await request.send();
  final respStr = await response.stream.bytesToString();
  Map valueMap;
  valueMap = json.decode(respStr);

  return valueMap;
}

class UserEdit extends StatefulWidget {
  @override
  _BooksListState createState() => _BooksListState();
}


class Item {
  const Item(this.name,this.icon);
  final String name;
  final Icon icon;
}

class _BooksListState extends State<UserEdit> {
  var imageUrl;
  var ans;
  var status;
  File imageFile;

  void refreshState() {
    setState(() {});
  }

  File _image;

  Future galleryPicker() async {
    final pickedImage = await ImagePicker().getImage(source: ImageSource.gallery);

    _cropImage(pickedImage.path);

  }

  Future imagePicker() async {
    final cameraImage = await ImagePicker().getImage(source: ImageSource.camera);

    _cropImage(cameraImage.path);

  }

  _cropImage(filePath) async {
    final croppedImage = await ImageCropper.cropImage(sourcePath: filePath,);
    // print(croppedImage);
    if (croppedImage != null) {
      setState(() {
        _image = File(croppedImage.path);
      });
    }
  }

  Future<http.Response> getMyProfile(http.Client client, String token) async {
    Box box = Hive.box('config');
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
    );

    return response;
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
          backgroundColor: Color(0xFFF6F6F7),
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
              'Edit Profile',
            ),
          ),
          body: FutureBuilder<http.Response>(
              future: getMyProfile(http.Client(), globals.accessTokenG),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  String body = utf8.decode(snapshot.data.bodyBytes);
                  ans = parseProfileDetails(body);
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 20.0),
                        Center(
                          child: Container(
                            width: 140,
                            height: 140,
                            color: Colors.transparent,
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              backgroundImage: _image != null ?
                              FileImage(_image) : ans.avatar != null && ans.avatar != ''
                                  ? NetworkImage(ans.avatar)
                                  : ans.gender == 1 ? AssetImage('assets/profile_boy.png')
                                  : AssetImage('assets/profile_girl.png'),
                              radius: 50,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0,),
                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (BuildContext bc) {
                                  return Container(
                                    child: new Wrap(
                                      children: <Widget>[
                                        new ListTile(
                                            leading: new Icon(
                                                Icons.photo_camera),
                                            title: new Text('Camera'),
                                            onTap: () =>
                                            {
                                              Navigator.pop(context),
                                              imagePicker()
                                            }
                                        ),
                                        new ListTile(
                                          leading: new Icon(
                                              Icons.photo_library),
                                          title: new Text('Gallery'),
                                          onTap: () =>
                                          {
                                            Navigator.pop(context),
                                            galleryPicker(),
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }
                            );
                          },
                          child: Card(
                            color: Color(0xFFffffff),
                            elevation: 2.0,
                            child: Container(
                              width: 220,
                              height: 50,
                              child: Row(
                                  children: <Widget>[
                                    Spacer(),
                                    Icon(Icons.cloud_upload),
                                    SizedBox(width: 20),
                                    Text(
                                      "Change Image",
                                      style: TextStyle(
                                          color: Color(0xFF213A8F),
                                          fontSize: 16.0,
                                          fontFamily: 'RobotoBold'
                                      ),
                                    ),
                                    Spacer()
                                  ]
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20,),
                        SizedBox(
                          height: 40,
                          width: 350,
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                            color: Color(0xFF213a8f),
                            onPressed: () async {
                              if (_image != null) {
                                imageUrl = await uploadImage(
                                    'reads', _image, globals.accessTokenG);
                              }
                              status = await changeProfileAvatar(
                                  ans.userId,
                                  _image != null ? imageUrl['value'] : null,
                                  globals.accessTokenG
                              );
                              if (status.statusCode == 200) {
                                Navigator.pop(context);
                                Fluttertoast.showToast(
                                    msg: 'Profile updated',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                );
                              }
                            },
                            child: Text(
                              'Save',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: 'RobotoBold',
                                  color: Colors.white
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Center(child: SpinKitCircle(
                    color: Color(0xFF213a8f),
                    size: 40,
                  ));
                }
              }
          )
      ),
    );
  }
}
