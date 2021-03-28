import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:mds_reads/globals.dart' as globals;

class Users {
  String id;
  String autocompleteTerm;

  Users({
    this.id,
    this.autocompleteTerm
  });

  factory Users.fromJson(Map<String, dynamic> parsedJson) {
    return Users(
        id: parsedJson['id'],
        autocompleteTerm: parsedJson['fio'] as String
    );
  }
}

class UsersViewModel {
  static List<Users> players;

  static Future loadPlayers() async {
    try {
      players = new List<Users>();
      String jsonString = await getUsers(http.Client(), globals.accessTokenG);
      List categoryJson = json.decode(jsonString);
      for (int i = 0; i < categoryJson.length; i++) {
        players.add(new Users.fromJson(categoryJson[i]));
      }
    } catch (e) {
      print(e);
    }
  }
}

dynamic getUsers(http.Client client, String token) async {
  Box box = Hive.box('config');
  var url = '${box.get('url')}/api/profiles/all/list';

  final http.Response response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
  );
  String body = utf8.decode(response.bodyBytes);

  return body;
}

class MentorsViewModel {
  static List<Users> mentors;

  static Future loadPlayers() async {
    try {
      mentors = new List<Users>();
      String jsonString = await getMentors(http.Client(), globals.accessTokenG);
      List categoryJson = json.decode(jsonString);
      for (int i = 0; i < categoryJson.length; i++) {
        mentors.add(new Users.fromJson(categoryJson[i]));
      }
    } catch (e) {
    }
  }
}

dynamic getMentors(http.Client client, String token) async {
  Box box = Hive.box('config');
  var url = '${box.get('url')}/api/profiles/roles/readsmentorlist';

  final http.Response response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
  );
  String body = utf8.decode(response.bodyBytes);

  return body;
}