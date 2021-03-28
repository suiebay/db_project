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
import 'dart:io' show File, Platform;
import 'package:mds_reads/globals.dart' as globals;
import 'package:mds_reads/pages/books/books_information.dart';

import 'package:path/path.dart';

Future<http.Response> createRequest(String author, String title, String description, String pageNumber, String pageDeadline, String imgStorage, String category, String token) async {
  var url;
  Box box = Hive.box('config');
  if(Platform.isAndroid) url = '${box.get('url')}/api/project/mdsreads/books/new';
  else if(Platform.isIOS) url = '${box.get('url')}/api/project/mdsreads/books/new';

  Map data = {
    'id': null,
    'author': author,
    'title': title,
    'description': description,
    'pageNumber': pageNumber,
    'imgStorage': imgStorage,
    'category': category,
    'deadline' : pageDeadline,
  };
  //encode Map to JSON
  var body = json.encode(data);

  var response = await http.post(url,
      headers: {"Content-Type": "application/json", 'Authorization': 'Bearer $token'},
      body: body
  );
  return response;
}


Future<http.Response> updateRequest(String bookId, String title, String author, String category, String description, String pageNumber, String pageDeadline, String imgStorage, String token) async {
  var url;
  Box box = Hive.box('config');
  if(Platform.isAndroid) url = '${box.get('url')}/api/project/mdsreads/books/update';
  else if(Platform.isIOS) url = '${box.get('url')}/api/project/mdsreads/books/update';
  Map data = {
    'id': bookId,
    'title': title,
    'author': author,
    'category': category,
    'description': description,
    'pageNumber': pageNumber,
    'pageDeadline' : pageDeadline,
    'imgStorage': imgStorage,
  };
  //encode Map to JSON
  var body = json.encode(data);
  var response = await http.post(url,
      headers: {"Content-Type": "application/json", 'Authorization': 'Bearer $token'},
      body: body
  );
  return response;
}


Future<Map<dynamic, dynamic>> uploadImage(String type, File file, String token) async {
  var url;
  Box box = Hive.box('config');
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

class BooksAddDialog extends StatefulWidget {

  BooksInformation booksInformation;
  BooksAddDialog(this.booksInformation);


  @override
  _BooksListState createState() => _BooksListState();
}

class Item {
  const Item(this.name,this.icon);
  final String name;
  final Icon icon;
}

class _BooksListState extends State<BooksAddDialog> {



  var status;
  var imageUrl;
  String filter = 'Title';
  var bookTitle = TextEditingController();
  var bookDescription = TextEditingController();
  var bookAuthor = TextEditingController();
  var bookPageNumber = TextEditingController();
  var bookDeadline = TextEditingController();
  Widget sss = Text('');
  Widget ttt = Text('');

  Text selectedCategory;
  List<Text> categories = <Text>[
    const Text('1\'st Grade'),
    const Text('2\'nd Grade'),
    const Text('3\'rd Grade'),
    const Text('4\'th Grade'),
    const Text('5\'th Grade'),
    const Text('6\'th Grade'),
    const Text('7\'th Grade'),
    const Text('Additional Books')
  ];

  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  String title, description, author, pageNumber, pageDeadline;

  String validateName(String value) {
    if (value.length == 0) {
      return "Name is Required";
    }
    return null;
  }

  String validateAuthor(String value) {
    if (value.length == 0) {
      return "Author is Required";
    }
    return null;
  }

  String validateDescription(String value) {
    if (value.length == 0) {
      return "Description is Required";
    }
    return null;
  }

  String validateDeadline(String value){
    if (value.length == 0) {
      return "Deadline is Required";
    }
    return null;
  }

  String validatePageNumber(String value) {
    String patttern = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Page Number is Required";
    } else if (!regExp.hasMatch(value)) {
      return "Page Number must be digits";
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

  File _image;

  Future galleryPicker() async {
    final pickedImage = await ImagePicker().getImage(
        source: ImageSource.gallery);

    _cropImage(pickedImage.path);
  }

  Future imagePicker() async {
    final cameraImage = await ImagePicker().getImage(source: ImageSource.camera);

    _cropImage(cameraImage.path);
  }

  _cropImage(filePath) async {
    final croppedImage = await ImageCropper.cropImage(
      sourcePath: filePath,
    );

    if (croppedImage != null) {
      setState(() {
        _image = File(croppedImage.path);
      });
    }
  }

  bool isLoading = false;

  bool isAddBook;




  @override
  void initState() {
    super.initState();
    if (widget.booksInformation == null){
      isAddBook = true;
    }
    else{
      isAddBook = false;
    }
    if (isAddBook == false) {
      bookTitle = new TextEditingController(text: widget.booksInformation.title);
      bookDescription = new TextEditingController(text: widget.booksInformation.description);
      bookAuthor = new TextEditingController(text: widget.booksInformation.author);
      bookPageNumber = new TextEditingController(text: widget.booksInformation.pageNumber.toString());
      bookDeadline = new TextEditingController(text: widget.booksInformation.pageDeadline.toString());
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
            isAddBook ?  'Add Book' :  'Edit Book'
//            'Add Book',
          ),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0),
              Center(
                child: isAddBook ? Container(
                  width: 125,
                  height: 140,
                  color: Colors.transparent,
                  child: _image == null
                      ? Image.asset('assets/item_book.png')
                      : Image.file(_image),
                ) : Container(
                    width: 125,
                    height: 140,
                    color: Colors.transparent,
                    child: _image != null
                        ? Image.file(_image) : widget.booksInformation
                        .imgStorage != null
                        ? Image.network(widget.booksInformation.imgStorage)
                        : Image.asset('assets/item_book.png')
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
                                  leading: new Icon(Icons.photo_camera),
                                  title: new Text('Camera'),
                                  onTap: () =>
                                  {
                                    Navigator.pop(context),
                                    imagePicker()
                                  }
                              ),
                              new ListTile(
                                leading: new Icon(Icons.photo_library),
                                title: new Text('Gallery'),
                                onTap: () =>
                                {
                                  Navigator.pop(context),
                                  galleryPicker()
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
                          SizedBox(width: 14),
                          Icon(Icons.cloud_upload),
                          SizedBox(width: 20),
                          Text(
                            "Upload Book Image",
                            style: TextStyle(
                                color: Color(0xFF213A8F),
                                fontSize: 16.0,
                                fontFamily: 'RobotoBold'
                            ),
                          ),
                        ]
                    ),
                  ),
                ),
              ),
              Form(
                key: _key,
                // ignore: deprecated_member_use
                autovalidate: _validate,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Enter book name',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: 'RobotoRegular',
                          ),
                        ),
                      ),
                      isAddBook? TextFormField(
                        controller: bookTitle,
                        decoration: InputDecoration(
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: validateName,
                      ) : TextFormField(
                        controller: bookTitle,
                        decoration: InputDecoration(
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: validateName,
                        onSaved: (String val) {
                          title = val;
                        },
                      ),
                      SizedBox(height: 5),
                      Center(child: ttt != Text('') ? ttt : null),
                      SizedBox(height: 10,),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Enter author',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: 'RobotoRegular',
                          ),
                        ),
                      ),
                      isAddBook ? TextFormField(
                        controller: bookAuthor,
                        decoration: InputDecoration(
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: validateAuthor,
                      ) : TextFormField(
                        controller: bookAuthor,
                        decoration: InputDecoration(
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: validateAuthor,
                        onSaved: (String val) {
                          author = val;
                        },
                      ),
                      SizedBox(height: 15,),
                      isAddBook ? Center(
                        child: DropdownButton<Text>(
                          hint: Text("Select category"),
                          value: selectedCategory,
                          onChanged: (Text value) {
                            setState(() {
                              sss = Text('');
                              selectedCategory = value;
                            });
                          },
                          items: categories.map((Text category) {
                            return DropdownMenuItem<Text>(
                              value: category,
                              child: Row(
                                children: <Widget>[
                                  SizedBox(width: 10,),
                                  Text(
                                    category.data,
                                    style: TextStyle(
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ) : StatefulBuilder(
                          builder: (context, setState) {
                            return Center(
                              child: DropdownButton<Text>(
                                hint: Text(
                                    widget.booksInformation.category),
                                value: selectedCategory,
                                onChanged: (Text value) {
                                  setState(() {
                                    sss = Text('');
                                    selectedCategory = value;
                                  });
                                },
                                items: categories.map((Text category) {
                                  return DropdownMenuItem<Text>(
                                    value: category,
                                    child: Row(
                                      children: <Widget>[
                                        SizedBox(width: 10,),
                                        Text(
                                          category.data,
                                          style: TextStyle(
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          }
                      ),
                      sss,
                      SizedBox(height: 15,),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Enter description',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: 'RobotoRegular',
                          ),
                        ),
                      ),
                      isAddBook ? TextFormField(
                        maxLines: 2,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          fillColor: Colors.grey.shade50,
                        ),
                        controller: bookDescription,
                        validator: validateDescription,
                      ) : TextFormField(
                        maxLines: 2,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          fillColor: Colors.grey.shade50,
                        ),
                        controller: bookDescription,
                        validator: validateDescription,
                        onSaved: (String val) {
                          description = val;
                        },
                      ),
                      SizedBox(height: 30,),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Enter page number',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: 'RobotoRegular',
                          ),
                        ),
                      ),
                      isAddBook ? TextFormField(
                        keyboardType: TextInputType.number,
                        controller: bookPageNumber,
                        decoration: InputDecoration(
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: validatePageNumber,
                      ) : TextFormField(
                        keyboardType: TextInputType.number,
                        controller: bookPageNumber,
                        decoration: InputDecoration(
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: validatePageNumber,
                        onSaved: (String val) {
                          pageNumber = val;
                        },
                      ),

                      SizedBox(height: 30,),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Enter deadline (by day)',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: 'RobotoRegular',
                          ),
                        ),
                      ),
                      isAddBook ? TextFormField(
                        keyboardType: TextInputType.number,
                        controller: bookDeadline,
                        decoration: InputDecoration(
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: validateDeadline,
                      ) : TextFormField(
                        keyboardType: TextInputType.number,
                        controller: bookDeadline,
                        decoration: InputDecoration(
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: validateDeadline,
                        onSaved: (String val) {
                          pageDeadline = val;
                        },
                      ),

                      SizedBox(height: 15),
                      SizedBox(
                        height: 50,
                        width: 350,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  30.0)),
                          color: Color(0xFF213a8f),
                          onPressed: () async {
                            if (selectedCategory == null) {
                              setState(() {
                                sss = Text(
                                  'Category does not exist',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                );
                              });
                            } else {
                              setState(() {
                                sss = Text('');
                              });
                            }
                            if (isAddBook) {
                              if (_sendToServer() &&
                                  selectedCategory != null) {
                                setState(() {
                                  isLoading = true;
                                });
                                if (_image != null) {
                                  imageUrl =
                                  await uploadImage(
                                      'reads', _image, globals.accessTokenG);
                                }
                                status = await createRequest(
                                    bookAuthor.text,
                                    bookTitle.text,
                                    bookDescription.text,
                                    bookPageNumber.text,
                                    bookDeadline.text,
                                    _image != null
                                        ? imageUrl['value']
                                        : null,
                                    selectedCategory.data,
                                    globals.accessTokenG
                                );
                                if (status.statusCode == 200) {
                                  ttt = Text('');
                                  Navigator.pop(context);
                                  Fluttertoast.showToast(
                                    msg: 'Book added',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                  );
                                  setState(() {
                                    isLoading = false;
                                    ttt = Text('');
                                  });
                                }
                                if (status != null &&
                                    status.statusCode == 400) {
                                  setState(() {
                                    isLoading = false;
                                    ttt = Text(
                                      'Title already exist!',
                                      style: TextStyle(
                                          color: Colors.red
                                      ),
                                    );
                                  });
                                }
                              }
                            } else{
                              if (_sendToServer() &&
                                  (selectedCategory != null ||
                                      widget.booksInformation.category != null)) {
                                setState(() {
                                  isLoading = true;
                                });
                                if (_image != null) {
                                  imageUrl =
                                  await uploadImage(
                                      'reads', _image, globals.accessTokenG);
                                }
                                status = await updateRequest(
                                    widget.booksInformation.bookId,
                                    bookTitle.text,
                                    bookAuthor.text,
                                    selectedCategory != null ? selectedCategory
                                        .data : widget.booksInformation.category,
                                    bookDescription.text,
                                    bookPageNumber.text,
                                    bookDeadline.text,
                                    _image != null ? imageUrl['value'] : widget
                                        .booksInformation.getImgStorage(),
                                    globals.accessTokenG
                                );
                                if (status.statusCode == 200) {
                                  ttt = Text('');
                                  Navigator.pop(context);
                                  Fluttertoast.showToast(
                                    msg: 'Book saved',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                  );
                                  setState(() {
                                    isLoading = false;
                                    ttt = Text('');
                                  });
                                }
                                if (status != null &&
                                    status.statusCode == 400) {
                                  setState(() {
                                    isLoading = false;
                                    ttt = Text(
                                      'Title already exist!',
                                      style: TextStyle(
                                          color: Colors.red
                                      ),
                                    );
                                  });
                                }
                              }
                            }
                          },
                          child: isLoading ? SpinKitCircle(
                            color: Colors.white,
                            size: 25,
                          ) :  Text(
                            isAddBook ? 'Add Book' : 'Save Book',
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
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

