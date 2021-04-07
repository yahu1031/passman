import 'package:flutter/material.dart';

class DataCard extends StatefulWidget {
  const DataCard(this.title, this.content, {required this.onPressed});
  final String title, content;
  final Function onPressed;
  @override
  _DataCardState createState() => _DataCardState();
}

class _DataCardState extends State<DataCard> {
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.transparent,
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.content,
                  style: const TextStyle(
                    color: Colors.transparent,
                    fontSize: 18.0,
                    fontWeight: FontWeight.normal,
                  ),
                )
              ],
            ),
            IconButton(
              icon: const Icon(
                Icons.delete,
                color: Colors.redAccent,
              ),
              onPressed: () => widget.onPressed,
            )
          ],
        ),
      );
}
