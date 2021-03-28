
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:mds_reads/pages/config/presentation/config_page.dart';
import 'package:mds_reads/pages/user/user_page.dart';
import 'pages/LogIn.dart';
import 'splash_screen_values.dart';
import 'package:http/http.dart' as http;


// ignore: must_be_immutable
class SplashScreen extends StatefulWidget {
  var response;

  SplashScreen(http.Response this.response);


  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    Box box = Hive.box('config');

    // if(Platform.isAndroid) {
    //   final newVersion = NewVersion(context: context);
    //   newVersion.showAlertIfNecessary();
    // }
    print(widget.response);
    // print(widget.response.statusCode);
    print(box.get('url'));
    print(widget.response);
    return Scaffold(
      body: SplashScreenValues(
        seconds: 2,
        navigateAfterSeconds: (widget.response == null || widget.response.statusCode != 200) ? LogInPage() : UserPage(),
        image: new Image.asset('assets/logo-white2.png', height: 130,),
        photoSize: 100,
        backgroundColor: Color(0xff213a8f),
        loaderColor: Colors.white,
      ),
    );
  }
}
