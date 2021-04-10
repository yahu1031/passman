import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:passman/main.dart';

enum DialogActions { yes, abort }

class Dialogs {
  static Future<dynamic?> yesAbortDialog(
    String title,
    String body,
  ) async {
    Future<DialogActions>? action = await showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(DialogActions.abort),
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
