import 'package:flutter/material.dart';
import 'package:passman/utils/constants.dart';
import 'package:velocity_x/velocity_x.dart';

class DataCard extends StatelessWidget {
  const DataCard(
    this.accountName, {
    this.title,
    this.content,
    required this.copyPressed,
    this.onLongPress,
  });
  final String? title, content, accountName;
  final Function()? copyPressed, onLongPress;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Card(
        elevation: 5,
        child: VxBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                accountName!,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
              IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                icon: const Icon(
                  Iconsdata.copy,
                  color: Colors.grey,
                ),
                onPressed: copyPressed,
              )
            ],
          ),
        )
            .height(50)
            .width(
              context.mq.size.width > 600
                  ? context.mq.size.width * 0.25
                  : context.mq.size.width,
            )
            .white
            .withRounded(value: 20)
            .make()
            .pSymmetric(v: 32.0, h: 24.0),
      ),
    );
  }
}
