import 'dart:io';

import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:passman/Components/markers.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/models/points.dart';

class PassmanSignup extends StatefulWidget {
  const PassmanSignup({Key key}) : super(key: key);
  @override
  _PassmanSignupState createState() => _PassmanSignupState();
}

class _PassmanSignupState extends State<PassmanSignup> {
  Logger loggerNoStack = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );
  File _image;
  final ImagePicker picker = ImagePicker();
  List<Points> password = <Points>[];
  PickedFile pickedFile;

  Future<void> _pickImage() async {
    await password.removeRange(0, password.length);
    pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      password.length;
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        loggerNoStack.e('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _image != null
                    ? <Widget>[
                        GestureDetector(
                          onPanDown: (DragDownDetails details) {
                            final double clickX =
                                details.localPosition.dx.toDouble();
                            final double clickY =
                                details.localPosition.dy.toDouble();
                            password.add(
                              Points(
                                clickX.toDouble(),
                                clickY.toDouble(),
                              ),
                            );
                            setState(() {
                              password.length;
                            });
                            if (password.length >= 3) {
                              loggerNoStack.d('length is ${password.length}');
                            }
                          },
                          child: Stack(
                            children: <Widget>[
                              Container(
                                height: SizeConfig.widthMultiplier * 90,
                                width: SizeConfig.widthMultiplier * 90,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 3,
                                    color: Colors.blue[400],
                                  ),
                                  borderRadius: BorderRadius.circular(7),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: Image(
                                      image: FileImage(_image),
                                    ).image,
                                  ),
                                ),
                              ),
                              for (Points pass in password)
                                Marker(
                                  dx: pass.x,
                                  dy: pass.y,
                                ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5 * SizeConfig.heightMultiplier,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            password.length >= 1
                                ? IconButton(
                                    tooltip: 'Undo',
                                    icon: Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.blue[400],
                                    ),
                                    onPressed: () {
                                      password.removeLast();
                                      setState(() {
                                        password.length;
                                      });
                                      if (password.length >= 3) {
                                        loggerNoStack
                                            .d('length is ${password.length}');
                                      }
                                    },
                                  )
                                : const SizedBox(
                                    width: 49,
                                    height: 49,
                                  ),
                            GestureDetector(
                              onTap: _pickImage,
                              child: Text(
                                'Change Image',
                                style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 3 * SizeConfig.textMultiplier,
                                  color: Colors.blue[400],
                                ),
                              ),
                            ),
                            password.length >= 3
                                ? IconButton(
                                    tooltip: 'Next',
                                    icon: Icon(
                                      Icons.arrow_forward_ios,
                                      color: password.length >= 3
                                          ? Colors.blue[400]
                                          : Colors.grey,
                                    ),
                                    disabledColor: Colors.grey,
                                    onPressed:
                                        password.length >= 3 ? () {} : null,
                                  )
                                : const SizedBox(
                                    width: 49,
                                    height: 49,
                                  ),
                          ],
                        ),
                      ]
                    : <Widget>[
                        GestureDetector(
                          onTap: _pickImage,
                          child: Tooltip(
                            message: 'Choose an image',
                            child: Image.asset(
                              'assets/images/img_placeholder.png',
                              height: 70 * SizeConfig.imageSizeMultiplier,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                      ],
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_outlined,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
