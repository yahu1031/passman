import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  UserData({
    this.ip,
    this.location,
    this.name,
    this.img,
    this.logged_in_time,
    this.platform,
    this.browser,
    this.web_login,
  });
  factory UserData.fromDocument(DocumentSnapshot? doc) => UserData(
        ip: doc?.data()!['ip'],
        location: doc?.data()!['location'],
        name: doc?.data()!['name'],
        img: doc?.data()!['img'],
        logged_in_time: doc?.data()!['logged_in_time'],
        platform: doc?.data()!['platform'],
        browser: doc?.data()!['browser'],
        web_login: doc?.data()!['web_login'],
      );
  final String? ip, name, browser, platform, img, location;
  Timestamp? logged_in_time;
  final bool? web_login;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'ip': ip,
        'location': location,
        'name': name,
        'img': img,
        'logged_in_time': logged_in_time,
        'platform': platform,
        'browser': browser,
        'web_login': web_login,
      };
}
