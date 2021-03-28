import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:mds_reads/pages/LogIn.dart';
import 'package:mds_reads/pages/aboutUs/about_us.dart';
import 'package:mds_reads/pages/books/book_main.dart';
import 'package:mds_reads/pages/books/booksList.dart';
import 'package:mds_reads/pages/books/category_book.dart';
import 'package:mds_reads/pages/config/presentation/config_page.dart';
import 'package:mds_reads/pages/groups/group_list.dart';
import 'package:mds_reads/pages/groups/group_main.dart';
import 'package:mds_reads/pages/groups/group_user_add.dart';
import 'package:mds_reads/pages/rating/rating_users.dart';
import 'package:mds_reads/pages/rules/rules.dart';
import 'package:mds_reads/pages/user/profile_details.dart';
import 'package:mds_reads/pages/user/user_book_finish.dart';
import 'package:mds_reads/widgets/contact_us.dart';
import 'package:mds_reads/widgets/setting_page.dart';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mds_reads/pages/user/user_edit.dart';
import 'package:mds_reads/pages/user/user_page.dart';
import 'package:mds_reads/splashscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:mds_reads/globals.dart' as globals;

import 'injection_container.dart';

Future<http.Response> postReview(String role, String token) async {
  Box box = Hive.box('config');
  var url;
  if (Platform.isAndroid)
    url = '${box.get('url')}/api/account/islogging-reads';
  else if (Platform.isIOS)
    url = '${box.get('url')}/api/account/islogging-reads';
  var response;
  try {
    response = await http.post(url,
        headers: {'Authorization': 'Bearer $token'}, body: role);
  } catch (_) {
    print('ahaha');
  }

  return response;
}

Future<http.Response> checkNotification() async {
  Box box = Hive.box('config');
  var url = '${box.get('url')}/api/project/mdsreads/notification/check/$userId';

  var response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      // 'Authorization': 'Bearer $tokenA',
    },
  );

  return response;
}

getStringValuesSF(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String stringValue = prefs.getString(key);
  return stringValue;
}

String roleA;
String roleM;
String tokenA;
String userRole = "student";
var responseJson;
String userId;

ProfileDetails ans;

void backgroundFetchHeadlessTask(String taskId) async {
  WidgetsFlutterBinding.ensureInitialized();
  userId = await getStringValuesSF('userId');
  print(userId);
  tokenA = await getStringValuesSF('accessToken');
  responseJson = await checkNotification();
  String body = utf8.decode(responseJson.bodyBytes);
  globals.responseJson = json.decode(body);

  if(globals.responseJson != null && globals.responseJson.length != 0) {
    FlutterLocalNotificationsPlugin flip = new FlutterLocalNotificationsPlugin();

    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var IOS = new IOSInitializationSettings();

    var settings = new InitializationSettings(android, IOS);
    flip.initialize(settings);


    for (int i = 0; i < globals.responseJson.length; i++) {
      if (globals.responseJson[i] != null &&
          globals.responseJson[i].length != 0)
        _showNotificationWithDefaultSound(flip, globals.responseJson[i], i);
    }
  }

  BackgroundFetch.finish(taskId);

  BackgroundFetch.scheduleTask(TaskConfig(
      taskId: "com.transistorsoft.customtask",
      delay: 21600000,
      periodic: true,
      forceAlarmManager: true,
      stopOnTerminate: false,
      enableHeadless: true,
      startOnBoot: true
  ));



  return Future.value(true);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await Hive.initFlutter();
  Box box2 = await Hive.openBox('config');
  box2.put('url', 'http://10.48.86.161:8080');

  setupInjections();

  roleA = await getStringValuesSF('isAdmin');
  roleM = await getStringValuesSF('isMentor');
  tokenA = await getStringValuesSF('accessToken');

  globals.accessTokenG = tokenA;
  if(roleM != null && tokenA != null) {
    globals.isMentor = int.parse(roleM);
    globals.searchByG = 'All';
    globals.previousSearchByG = 'All';
    if(roleM == "1") {
       userRole = "READS_MENTOR";
    }
  }

  if (roleA != null && tokenA != null) {
    globals.isAdmin = int.parse(roleA);
    globals.searchByG = 'All';
    globals.previousSearchByG = 'All';
    if (roleA == "1") {
      userRole = "admin";
    }
  }
  // print(roleA + " " + roleM);
  var resp;
  if(box2.get('url') != null)
    resp = await postReview(userRole, tokenA);

  // if (tokenA != null) {
  //   BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  // }

  // await NotificationPermissions.requestNotificationPermissions();

  // await BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);

  // BackgroundFetch.scheduleTask(TaskConfig(
  //     taskId: "com.transistorsoft.customtask",
  //     delay: 10000,
  //     periodic: false,
  //     forceAlarmManager: true,
  //     stopOnTerminate: false,
  //     enableHeadless: true
  // ));
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(resp),

//    initialRoute: resp.statusCode != 200 ? '/login' : '/mycabinet',
    // initialRoute: '/test',
    routes: {
      '/login': (context) => LogInPage(),
      '/mycabinet': (context) => UserPage(),
      '/bookmain': (context) => BookMain(),
      '/bookslist': (context) => BooksList(),
      '/bookcategory': (context) => CategoryBook(),
//      '/booksadddialog': (context) => BooksAddDialog(),
      '/aboutus': (context) => AboutUs(),
      '/rules': (context) => Rules(),
      '/useredit': (context) => UserEdit(),
      '/bookfinish': (context) => UserBookFinish(),
      '/ratingusers': (context) => RatingUsers(),
      '/groups': (context) => GroupList(),
      '/groupmain': (context) => GroupMain(),
      '/groupuseradd': (context) => GroupUserAdd(),
      '/settings': (context) => SettingsMaterialPage(),
      '/contactus': (context) => ContactUsRoute(),
      '/config': (context) => ConfigPage(),
    },
  ));

}

Future _showNotificationWithDefaultSound(flip, array, int index) async {
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      'your channel description',
      importance: Importance.Max,
      priority: Priority.High,
      styleInformation: BigTextStyleInformation('')
  );
  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
  var platformChannelSpecifics = new NotificationDetails(
      androidPlatformChannelSpecifics,
      iOSPlatformChannelSpecifics
  );

  flip.show(index, array[0],
      array[1],
      platformChannelSpecifics, payload: 'Default_Sound'
  );
}
