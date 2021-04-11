import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:passman/Components/size_config.dart';

enum DialogActions { yes, abort }

class Dialogs {
  static Future<dynamic?> yesAbortDialog(
    BuildContext context,
    String title,
    String body,
    VoidCallback? onPressed,
  ) async {
    Future<DialogActions>? action = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'LexendDeca',
            fontSize: 1.5 * SizeConfig.textMultiplier,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        content: Text(
          body,
          style: TextStyle(
            fontFamily: 'LexendDeca',
            fontSize: 1.15 * SizeConfig.textMultiplier,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: onPressed,
            child: Text(
              'OK',
              style: TextStyle(
                fontFamily: 'LexendDeca',
                fontWeight: FontWeight.w900,
                color: Colors.blue[400],
              ),
            ),
          ),
        ],
      ),
    );
    return (action != null) ? action : DialogActions.abort;
  }
}
