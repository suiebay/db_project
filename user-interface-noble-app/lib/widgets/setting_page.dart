import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:icofont_flutter/icofont_flutter.dart';
import 'package:mds_reads/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mds_reads/globals.dart' as globals;

class SettingsMaterialPage extends StatefulWidget {
  SettingsMaterialPage({Key key}) : super(key: key);
  @override
  _SettingsMaterialPageState createState() => _SettingsMaterialPageState();
}

class _SettingsMaterialPageState extends State<SettingsMaterialPage> {
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
        drawer: MyDrawer(),
        appBar: AppBar(
          backgroundColor: Color(0xFF213A8F),
          title: Text("Settings"),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(13),
              child: Text(
                "About",
                style: TextStyle(
                    color: Color(0xFF213A8F),
                    fontSize: 22,
                    fontWeight: FontWeight.w600),
              ),
            ),
            InkWell(
              child: Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                padding: EdgeInsets.only(left: 23, top: 5, bottom: 5),
                child: Text(
                  "Contact Us",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
              onTap: () => Navigator.pushNamed(context, '/contactus'),
            ),
            Divider(
              thickness: 0.6,
              color: Colors.black,
            ),
            InkWell(
              child: Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                padding: EdgeInsets.only(left: 23, top: 5, bottom: 5),
                child: Text(
                  "About Us",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
              onTap: () => Navigator.pushNamed(context, '/aboutus'),
            ),
            Divider(
              thickness: 0.6,
              color: Colors.black,
            ),
            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              padding: EdgeInsets.only(left: 23, top: 5, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Version",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Text(
                      "1.1",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              thickness: 0.6,
              color: Colors.black,
            ),
            Container(
              child: Center(
                child: FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: RaisedButton(
                      splashColor: Color(0xFF213A8F),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: Color(0xFFea2937))),
                      padding: EdgeInsets.all(10),
                      elevation: 10,
                      color: Colors.red[600],
                      onPressed: () async {
                        SharedPreferences preferences =
                        await SharedPreferences.getInstance();
                        await preferences.clear();
                        Box box = Hive.box('config');
                        box.clear();
                        globals.accessTokenG = '';
                        globals.searchByG = null;
                        globals.previousSearchByG = null;
                        globals.gender = null;
                        globals.isAdmin = 0;
                        globals.duration = 15;
                        globals.isMentor = 0;
                        Navigator.pushReplacementNamed(context, '/config');
                      },
                      child: Row(
                        children: [
                          Icon(
                            IcoFontIcons.logout,
                            color: Colors.white,
                            size: 27,
                          ),
                          SizedBox(width: 17),
                          Text(
                            "Log Out",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}