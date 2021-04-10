import 'package:flutter/material.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/models/user_data.dart';

class LoginDetails extends StatelessWidget {
  const LoginDetails({
    Key? key,
    required this.userData,
    required this.content,
    required this.title,
    required this.icon,
  }) : super(key: key);
  final String content, title;
  final UserData userData;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Icon(
          icon,
          color: Colors.black,
          size: 2 * SizeConfig.textMultiplier,
        ),
        Text(
          '$title :',
          style: TextStyle(
            fontFamily: 'LexendDeca',
            fontSize: 2.25 * SizeConfig.textMultiplier,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          content,
          style: TextStyle(
            fontFamily: 'LexendDeca',
            fontSize: 2 * SizeConfig.textMultiplier,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
