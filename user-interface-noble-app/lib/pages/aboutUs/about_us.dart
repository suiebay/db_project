import 'package:flutter/material.dart';
import 'package:mds_reads/pages/aboutUs/moderator.dart';
import 'dart:io' show Platform;


class AboutUs extends StatefulWidget {
  @override
  _ChooseLocationState createState() => _ChooseLocationState();
}

class _ChooseLocationState extends State<AboutUs> {

  List<Moderator> moderators = [
    Moderator(name: 'Arafat', description: 'CEO MDS Program', color: 1, image: 1, surname: 'Nurlakov'),
    Moderator(name: 'Zhiger', description: 'CEO MDS Reads', color: 1, image: 1, surname: 'Telukanov'),
    Moderator(name: 'Bakhytzhan', description: 'Project Developer', color: 1, image: 1, surname: 'Myktybayev'),
    Moderator(name: 'Adilet', description: 'Project Developer', color: 1, image: 1, surname: 'Amangossov'),
    Moderator(name: 'Bakhtyar', description: 'Project Developer', color: 1, image: 1, surname: 'Madeniyet'),
    Moderator(name: 'Bekzat', description: 'Project Developer', color: 1, image: 1, surname: 'Sailaubayev'),
    Moderator(name: 'Zhassulan', description: 'Project Developer', color: 1, image: 1, surname: 'Suiebay')
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F7),
      appBar: AppBar(
        backgroundColor: Color(0xFF213A8F),
        title: Text(
          'About us',
        ),
      ),
      body: GridView.builder(
        itemCount: moderators.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 6/7
        ),
        itemBuilder: (BuildContext context, int index) {
          return SafeArea(
            child: Container(
              //color: Colors.purple,
              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: Card(
                elevation: 3,
                child: Container(
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        left: 0,
                        right: 0,
                        height: 45,
                        child: Card(
                            margin: EdgeInsets.all(0),
                            color: Colors.blueGrey[500]
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: 0,
                        right: 0,
                        height: 5,
                        child: Container(
                            margin: EdgeInsets.all(0),
                            color: Colors.blueGrey[500]
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Spacer(),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CircleAvatar(
                                backgroundColor: Colors.transparent,
                                backgroundImage: AssetImage('assets/profile_boy.png'),
                                radius: Platform.isIOS ? 45 : 50,
                              ),
                              SizedBox(height: 20.0),
                              Text(
                                moderators[index].name,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Quick'
                                ),
                              ),
                              Text(
                                moderators[index].surname,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Quick'
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                moderators[index].description,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontFamily: 'RobotoLight'
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),

    );
  }
}
