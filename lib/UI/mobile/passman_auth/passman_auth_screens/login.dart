import 'dart:io';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as imglib;
import 'package:logger/logger.dart';
import 'package:passman/Components/constants.dart';
import 'package:passman/keys.dart';
import 'package:passman/Components/markers.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/models/points.dart';
import 'package:passman/services/decode.dart';
import 'package:passman/services/image_services/img_to_data.dart';
import 'package:passman/services/image_services/upload_img_services.dart';
import 'package:passman/services/utilities/enums.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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
  File? _selectedImage, _image;

  Future<String> _getImage() async {
    setState(() {
      loadingState = LoadingState.LOADING;
    });
    String? uuid = mAuth.currentUser!.uid;
    String? _imageLink;
    DefaultCacheManager cache = DefaultCacheManager();
    await userDataColRef.doc(uuid).get().then(
          (DocumentSnapshot value) => setState(() {
            _imageLink = value.data()!['img'];
          }),
        );

    _image = await cache.getSingleFile(_imageLink!);
    _selectedImage = File(_image!.path);
    UploadedImageConversionResponse response =
        await convertUploadedImageToDataaAsync(
      UploadedImageConversionRequest(
        _selectedImage!,
      ),
    );
    setState(() {
      editableImage = response.editableImage;
      pickedImg = true;
      image = response.displayableImage;
    });
    setState(() {
      loadingState = LoadingState.SUCCESS;
    });
    return _imageLink!;
  }

  @override
  void initState() {
    super.initState();
    loadingState = LoadingState.PENDING;
    _getImage();
  }

  @override
  void dispose() {
    super.dispose();
    _getImage();
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
      await Navigator.pushReplacementNamed(
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
              child: loadingState == LoadingState.PENDING
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: pickedImg == true
                          ? <Widget>[
                              Container(
                                height: SizeConfig.widthMultiplier * 90,
                                width: SizeConfig.widthMultiplier * 90,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 3,
                                    color: Colors.blue[400]!,
                                  ),
                                  borderRadius: BorderRadius.circular(7),
                                ),
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
                                    loggerNoStack
                                        .d('length is ${password!.length}');
                                  },
                                  child: Stack(
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
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
                              const CircularProgressIndicator(),
                              SizedBox(
                                height: 5 * SizeConfig.heightMultiplier,
                              ),
                              Text(
                                'Fetching your data...',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 1.75 * SizeConfig.textMultiplier,
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ]),
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
