import 'package:flutter/material.dart';
import 'package:passman/Components/constants.dart';

class DataCard extends StatefulWidget {
  const DataCard(
    this.accountName, {
    this.title,
    this.content,
    required this.onPressed,
  });
  final String? title, content, accountName;
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
            Text(
              widget.accountName!,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
            IconButton(
              icon: const Icon(
                Iconsdata.copy,
                color: Colors.grey,
              ),
              onPressed: () => widget.onPressed,
            )
          ],
        ),
      );
}
// Text(
                //   widget.content!,
                //   style: const TextStyle(
                //     color: Colors.grey,
                //     fontSize: 18.0,
                //     fontWeight: FontWeight.normal,
                //   ),
                // )