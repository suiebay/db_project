import 'package:flutter/material.dart';
import 'package:icofont_flutter/icofont_flutter.dart';
import 'package:mds_reads/drawer.dart';

class ErrorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(''),
          backgroundColor: Color(0xFF213A8F),
        ),
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
                    SizedBox(height: 10,),
                    Text(
                        "Check your internet connection...",
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: "RobotoBold",
                            color: Colors.grey[500]
                        )
                    ),
                  ],
                )
            )
        ),
        drawer: MyDrawer()
    );
  }
}
