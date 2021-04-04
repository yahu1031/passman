import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  UserData({
    this.ip,
    this.name,
    this.img,
    this.logged_in_time,
    this.platform,
    this.web_login,
  });
  factory UserData.fromDocument(DocumentSnapshot? doc) => UserData(
        ip: doc?.data()!['ip'],
        name: doc?.data()!['name'],
        img: doc?.data()!['img'],
        logged_in_time: doc?.data()!['logged_in_time'],
        platform: doc?.data()!['platform'],
        web_login: doc?.data()!['web_login'],
      );
  final String? ip, name, platform, img;
  Timestamp? logged_in_time;
  final bool? web_login;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'ip': ip,
        'name': name,
        'img': img,
        'logged_in_time': logged_in_time,
        'platform': platform,
        'web_login': web_login,
      };
}
