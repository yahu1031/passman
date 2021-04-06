import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as imglib;
import 'package:logger/logger.dart';
import 'package:passman/Components/constants.dart';
import 'package:passman/.dart';
import 'package:passman/Components/markers.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/models/points.dart';
import 'package:passman/services/decode.dart';
import 'package:passman/services/image_services/img_to_data.dart';
import 'package:passman/services/image_services/upload_img_services.dart';
import 'package:passman/services/utilities/enums.dart';

class PassmanLogin extends StatefulWidget {
  const PassmanLogin({Key? key}) : super(key: key);
  @override
  _PassmanLoginState createState() => _PassmanLoginState();
}

class _PassmanLoginState extends State<PassmanLogin> {
  Logger loggerNoStack = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );
  Image? image;
  imglib.Image? editableImage;
  List<Points>? password = <Points>[];
  final ImagePicker picker = ImagePicker();
  LoadingState? loadingState;
  bool pickedImg = false;

  Future<String> _getImage() async {
    setState(() {
      loadingState = LoadingState.SUCCESS;
    });
    String? uuid = mAuth.currentUser!.uid;
    String? _imageLink;
    await userDataColRef.doc(uuid).get().then(
          (DocumentSnapshot value) => setState(() {
            _imageLink = value.data()!['img'];
          }),
        );
    try {
      UploadedImageConversionResponse response =
          await convertUploadedImageToDataaAsync(
        UploadedImageConversionRequest(
          File(_imageLink!),
        ),
      );
      editableImage = response.editableImage;
      setState(() {
        pickedImg = true;
        image = response.displayableImage;
      });
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      loadingState = LoadingState.SUCCESS;
    });
    return _imageLink!;
  }

  @override
  void initState() {
    super.initState();
    loadingState = LoadingState.PENDING;
  }

  @override
  Widget build(BuildContext context) {
    for (Points item in password!) {
      print('${item.x}  ${item.y}');
    }
    Future<void> sendToDecode() async {
      // ignore: unused_local_variable
      String pointString =
          password!.map((Points pass) => '(${pass.x} ${pass.y})').join('');
      DecodeRequest req =
          DecodeRequest(editableImage!, token: imgSecretPassKey);
      await Navigator.pushNamed(
        context,
        PageRoutes.routePassmanDecodingScreen,
        arguments: DecodeResultData(pointString, req),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Center(
              child: loadingState == LoadingState.LOADING
                  ? const CircularProgressIndicator()
                  : FutureBuilder<String>(
                      future: _getImage(),
                      builder: (BuildContext context,
                          AsyncSnapshot<dynamic> snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              GestureDetector(
                                onPanDown: (DragDownDetails details) {
                                  double clickX =
                                      details.localPosition.dx.toDouble();
                                  double clickY =
                                      details.localPosition.dy.toDouble();
                                  password!.add(
                                    Points(
                                      clickX.toDouble(),
                                      clickY.toDouble(),
                                    ),
                                  );
                                  setState(() {
                                    password!.length;
                                  });
                                  loggerNoStack
                                      .d('length is ${password!.length}');
                                },
                                child: Stack(
                                  children: <Widget>[
                                    Container(
                                      height: SizeConfig.widthMultiplier * 90,
                                      width: SizeConfig.widthMultiplier * 90,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 3,
                                          color: Colors.blue[400]!,
                                        ),
                                        borderRadius: BorderRadius.circular(7),
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: Image.network(
                                            snapshot.data.toString(),
                                          ).image,
                                        ),
                                      ),
                                    ),
                                    for (Points pass in password!)
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  password!.isNotEmpty
                                      ? GestureDetector(
                                          onLongPress: () {
                                            password!.removeRange(
                                                0, password!.length);
                                            setState(() {
                                              password!.length;
                                            });
                                          },
                                          child: IconButton(
                                            tooltip: 'Undo',
                                            icon: Icon(
                                              Icons.arrow_back_ios,
                                              color: Colors.blue[400],
                                            ),
                                            onPressed: () {
                                              password!.removeLast();
                                              setState(() {
                                                password!.length;
                                              });
                                              log(
                                                'length is ${password!.length}',
                                              );
                                            },
                                          ),
                                        )
                                      : const SizedBox(
                                          width: 49,
                                          height: 49,
                                        ),
                                  password!.length > 3
                                      ? IconButton(
                                          tooltip: password!.length > 3
                                              ? 'Next'
                                              : 'Next button disbled',
                                          icon: Icon(
                                            Icons.arrow_forward_ios,
                                            color: password!.length > 3
                                                ? Colors.blue[400]
                                                : Colors.grey,
                                          ),
                                          disabledColor: Colors.grey,
                                          onPressed: password!.length > 3
                                              ? () => sendToDecode()
                                              // ? () {}
                                              : null,
                                        )
                                      : const SizedBox(
                                          width: 49,
                                          height: 49,
                                        ),
                                ],
                              ),
                            ],
                          );
                        }
                        ;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const CircularProgressIndicator(),
                            SizedBox(
                              height: 5 * SizeConfig.heightMultiplier,
                            ),
                            Text(
                              'Fetching your image...',
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 1.75 * SizeConfig.textMultiplier,
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                              ),
                            )
                          ],
                        );
                      },
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

// 88.5  304.25
// 109.5  306.25
// 243.5  302.25
// 135.5  229.25
