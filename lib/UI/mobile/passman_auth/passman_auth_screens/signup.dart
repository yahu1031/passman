import 'dart:io';

import 'package:passman/keys.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as imglib;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:passman/Components/constants.dart';
import 'package:passman/Components/markers.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/models/points.dart';
import 'package:passman/services/encode.dart';
import 'package:passman/services/image_services/img_to_data.dart';
import 'package:passman/services/image_services/upload_img_services.dart';
import 'package:passman/services/utilities/enums.dart';

class PassmanSignup extends StatefulWidget {
  const PassmanSignup({Key? key}) : super(key: key);
  @override
  _PassmanSignupState createState() => _PassmanSignupState();
}

class _PassmanSignupState extends State<PassmanSignup> {
  Logger loggerNoStack = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );
  FirebaseAuth mAuth = FirebaseAuth.instance;
  imglib.Image? editableImage;
  PickedFile? _image;
  File? _selectedImage;
  int? imageByteSize;
  Image? image;
  bool _isImgPicked = false;
  final ImagePicker picker = ImagePicker();
  List<Points>? password;
  LoadingState? uploadingState;

  Future<void> _pickImage() async {
    setState(() {
      uploadingState = LoadingState.LOADING;
    });
    password!.removeRange(0, password!.length);
    _image = (await picker.getImage(source: ImageSource.gallery));
    _selectedImage = File(_image!.path);
    if (_image != null) {
      UploadedImageConversionResponse response =
          await convertUploadedImageToDataaAsync(
              UploadedImageConversionRequest(_selectedImage!));
      editableImage = response.editableImage;
      setState(() {
        image = response.displayableImage;
        _isImgPicked = true;
        imageByteSize = response.imageByteSize;
      });
    }
    setState(() {
      uploadingState = LoadingState.SUCCESS;
    });
  }

  @override
  void initState() {
    super.initState();
    _isImgPicked = false;
    password = <Points>[];
    uploadingState = LoadingState.PENDING;
  }

  @override
  void dispose() {
    super.dispose();
    _pickImage();
  }

  @override
  Widget build(BuildContext context) {
    for (Points item in password!) {
      print('${item.x}  ${item.y}');
    }
    String pointString =
        password!.map((Points pass) => '(${pass.x} ${pass.y})').join('');
    Future<void> sendToEncode() async {
      EncodeRequest req =
          EncodeRequest(editableImage!, pointString, token: imgSecretPassKey);
      await Navigator.pushNamed(
          context, PageRoutes.routePassmanEncodingScreen,
          arguments: req);
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Center(
              child: uploadingState == LoadingState.LOADING
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _isImgPicked == true
                          ? <Widget>[
                              GestureDetector(
                                onPanDown: (DragDownDetails details) {
                                  double clickX =
                                      details.localPosition.dx.floorToDouble();
                                  double clickY =
                                      details.localPosition.dy.floorToDouble();
                                  password!.add(
                                    Points(
                                      (clickX / binSize).floorToDouble(),
                                      (clickY / binSize).floorToDouble(),
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
                                          image: Image(
                                            image: FileImage(_selectedImage!),
                                          ).image,
                                        ),
                                      ),
                                    ),
                                    for (Points pass in password!)
                                      Marker(
                                        dx: pass.x * binSize,
                                        dy: pass.y * binSize,
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
                                              loggerNoStack.d(
                                                'length is ${password!.length}',
                                              );
                                            },
                                          ),
                                        )
                                      : const SizedBox(
                                          width: 49,
                                          height: 49,
                                        ),
                                  Tooltip(
                                    message: 'Change Image',
                                    child: GestureDetector(
                                      onTap: _pickImage,
                                      child: Text(
                                        'Change Image',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontFamily: 'Quicksand',
                                          fontSize:
                                              3 * SizeConfig.textMultiplier,
                                          color: Colors.blue[400],
                                        ),
                                      ),
                                    ),
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
                                              ? () => sendToEncode()
                                              : null,
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
