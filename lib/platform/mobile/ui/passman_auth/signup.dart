import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'package:image_picker/image_picker.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:passman/platform/mobile/model/points.dart';
import 'package:passman/platform/mobile/services/image_services/img_to_data.dart';
import 'package:passman/platform/mobile/services/image_services/upload_img_services.dart';
import 'package:passman/platform/mobile/services/en_de_coding/encode.dart';
import 'package:passman/utils/constants.dart';
import 'package:passman/platform/mobile/components/marker.dart';
import 'package:passman/.dart';

class PassmanSignup extends StatefulWidget {
  @override
  _PassmanSignupState createState() => _PassmanSignupState();
}

class _PassmanSignupState extends State<PassmanSignup> {
  LoadingState? uploadingState;
  imglib.Image? editableImage;
  PickedFile? _image;
  File? _selectedImage;
  int? imageByteSize;
  Image? image;
  bool _isImgPicked = false;
  final ImagePicker picker = ImagePicker();
  List<Points>? password;

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
  }

  @override
  Widget build(BuildContext context) {
    for (Points item in password!) {
      log('${item.x}  ${item.y}');
    }
    String pointString =
        password!.map((Points pass) => '(${pass.x} ${pass.y})').join('');
    Future<void> sendToEncode() async {
      EncodeRequest req =
          EncodeRequest(editableImage!, pointString, token: imgSecretPassKey);
      await Navigator.pushReplacementNamed(
          context, PageRoutes.routePassmanEncodingScreen,
          arguments: req);
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Center(
              child: uploadingState == LoadingState.LOADING
                  ? const CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.appMainColor),
                      strokeWidth: 3,
                    )
                  : VStack(
                      _isImgPicked == true
                          ? <Widget>[
                              VxBox(
                                child: GestureDetector(
                                  onPanDown: (DragDownDetails details) {
                                    double clickX = details.localPosition.dx
                                        .floorToDouble();
                                    double clickY = details.localPosition.dy
                                        .floorToDouble();
                                    password!.add(
                                      Points(
                                        (clickX / binSize).floorToDouble(),
                                        (clickY / binSize).floorToDouble(),
                                      ),
                                    );
                                    setState(() {
                                      password!.length;
                                    });
                                  },
                                  child: ZStack(
                                    <Widget>[
                                      VxBox()
                                          .bgImage(
                                            DecorationImage(
                                              fit: BoxFit.cover,
                                              image: Image(
                                                image:
                                                    FileImage(_selectedImage!),
                                              ).image,
                                            ),
                                          )
                                          .withRounded(value: 7)
                                          .make()
                                          .h(350)
                                          .w(350),
                                      for (Points pass in password!)
                                        Marker(
                                          dx: pass.x * binSize,
                                          dy: pass.y * binSize,
                                        ),
                                    ],
                                  ),
                                ),
                              )
                                  .border(
                                      width: 3, color: AppColors.appMainColor)
                                  .withRounded(value: 10)
                                  .make(),
                              const SizedBox(
                                height: 30,
                              ),
                              HStack(
                                 <Widget>[
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
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            tooltip: 'Undo',
                                            icon: const Icon(
                                              Iconsdata.undo,
                                              color: AppColors.appMainColor,
                                            ),
                                            onPressed: () {
                                              password!.removeLast();
                                              setState(() {
                                                password!.length;
                                              });
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
                                      child: 'Change Image'
                                          .text
                                          .extraBold
                                          .xl
                                          .color(AppColors.appMainColor)
                                          .fontFamily('LexendDeca')
                                          .make(),
                                    ),
                                  ),
                                  password!.length > 3
                                      ? IconButton(
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          tooltip: password!.length > 3
                                              ? 'Next'
                                              : 'Next button disbled',
                                          icon: Icon(
                                            Icons.arrow_forward_ios,
                                            color: password!.length > 3
                                                ? AppColors.appMainColor
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
                                alignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAlignment: CrossAxisAlignment.center,
                                axisSize: MainAxisSize.max,
                              ),
                            ]
                          : <Widget>[
                              GestureDetector(
                                onTap: _pickImage,
                                child: Tooltip(
                                  message: 'Choose an image',
                                  child: Image.asset(
                                    'assets/images/img_placeholder.png',
                                    height: 250,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                              ),
                            ],
                      alignment: MainAxisAlignment.center,
                      crossAlignment: CrossAxisAlignment.center,
                    ),
            ),
            Hero(
              tag: 'dp',
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.transparent,
                backgroundImage:
                    NetworkImage(fireServer.mAuth.currentUser!.photoURL!),
              ),
            ).positioned(top: 20, left: 20),
            IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              icon: const Icon(
                Iconsdata.x,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ).positioned(top: 20, right: 10),
          ],
        ),
      ),
    );
  }
}
