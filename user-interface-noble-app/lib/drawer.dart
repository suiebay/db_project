import 'package:flutter/material.dart';
import 'package:icofont_flutter/icofont_flutter.dart';
import 'package:mds_reads/globals.dart' as globals;


import 'package:shared_preferences/shared_preferences.dart';

getStringValuesSF(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String stringValue = prefs.getString(key);
  return stringValue;
}

class MyDrawer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).unfocus();
    return Drawer(
      child: Container(
        color: Color(0xFF213A8F),
        child: Column(
          //padding: EdgeInsets.fromLTRB(0, 100, 0, 0),
          children: <Widget>[
            SizedBox(height: 10,),
            SafeArea(
              bottom: false,
              child: Container(
                width: double.infinity,
                color: Colors.white.withOpacity(0.08),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Image(
                    alignment: Alignment.center,
                    height: 70,
                    // fit: BoxFit.fitWidth,
                    image: AssetImage('assets/logo-white2.png')
                  ),
                ),
              ),
            ),
            SizedBox(height: 40,),
            InkWell(
              onTap: () {
                Navigator.pushReplacementNamed(
                    context, '/mycabinet');
              },
              child: Container(
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 20),
                    Icon(
                      Icons.home,
                      color: Colors.white.withOpacity(0.3),
                      size: 30,
                    ),
                    SizedBox(width: 15,),
                    Text(
                      'My Cabinet',
                      style: TextStyle(
                        fontFamily: 'RobotoMedium',
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: () {
                Navigator.pushReplacementNamed(
                    context, '/bookcategory');
              },
              child: Container(
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 20,),
                    Icon(
                      IcoFontIcons.library,
                      color: Colors.white.withOpacity(0.3),
                      size: 30,
                    ),
                    SizedBox(width: 15,),
                    Text(
                      'Books',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'RobotoMedium',
                          fontSize: 20
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: () {
                globals.searchByG = 'All';
                globals.previousSearchByG = 'All';
                Navigator.pushReplacementNamed(
                    context, '/ratingusers');
              },
              child: Container(
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 20,),
                    Icon(
                      IcoFontIcons.usersAlt5,
                      color: Colors.white.withOpacity(0.3),
                      size: 30,
                    ),
                    SizedBox(width: 15,),
                    Text(
                      'Users Rating',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'RobotoMedium',
                          fontSize: 20
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: () {
                globals.searchByG = 'All';
                globals.previousSearchByG = 'All';
                Navigator.pushReplacementNamed(
                    context, '/groups');
              },
              child: Container(
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 20,),
                    Icon(
                      IcoFontIcons.university,
                      color: Colors.white.withOpacity(0.3),
                      size: 30,
                    ),
                    SizedBox(width: 15,),
                    Text(
                      'Groups',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'RobotoMedium',
                          fontSize: 20
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: () {
                Navigator.pushReplacementNamed(
                    context, '/rules');
              },
              child: Container(
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 20,),
                    Icon(
                      IcoFontIcons.list,
                      color: Colors.white.withOpacity(0.3),
                      size: 30,
                    ),
                    SizedBox(width: 15,),
                    Text(
                      'Rules',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'RobotoMedium',
                          fontSize: 20
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // SizedBox(height: 20),
            // InkWell(
            //   onTap: () {
            //     Navigator.pushReplacementNamed(
            //         context, '/aboutus');
            //   },
            //   child: Container(
            //     child: Row(
            //       children: <Widget>[
            //         SizedBox(width: 20,),
            //         Icon(
            //           IcoFontIcons.infoCircle,
            //           color: Colors.white.withOpacity(0.3),
            //           size: 30,
            //         ),
            //         SizedBox(width: 15,),
            //         Text(
            //           'About us',
            //           style: TextStyle(
            //               color: Colors.white,
            //               fontFamily: 'RobotoMedium',
            //               fontSize: 20
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            // SizedBox(height: 20),
            // InkWell(
            //   onTap: () async {
            //     SharedPreferences preferences = await SharedPreferences.getInstance();
            //     await preferences.clear();
            //     Navigator.pushReplacementNamed(context, '/login');
            //   },
            //   child: Container(
            //     child: Row(
            //       children: <Widget>[
            //         SizedBox(width: 20,),
            //         Icon(
            //           IcoFontIcons.logout,
            //           color: Colors.white.withOpacity(0.3),
            //           size: 30,
            //         ),
            //         SizedBox(width: 15,),
            //         Text(
            //           'Logout',
            //           style: TextStyle(
            //               color: Colors.white,
            //               fontFamily: 'RobotoMedium',
            //               fontSize: 20
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            SizedBox(height: 20),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
              child: Container(
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 20,
                    ),
                    Icon(Icons.settings,
                      color: Colors.white.withOpacity(0.3),
                      size: 30,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      'Settings',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'RobotoMedium',
                          fontSize: 20),
                    ),
                  ],
                ),
              ),),
            Spacer(),
            Text(
              '© 2020 MDSP v0.1 Created by MDSG IT',
              style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'RobotoRegular',
                  color: Colors.grey[400]),
            ),
            SizedBox(
              height: 5,

            ),
          ],
        ),
      ),
    );
  }
}
