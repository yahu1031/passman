import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:passman/platform/mobile/components/marker.dart';
import 'package:passman/platform/mobile/services/en_de_coding/decode.dart';
import 'package:passman/platform/mobile/services/image_services/img_to_data.dart';
import 'package:passman/utils/constants.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:passman/platform/mobile/services/image_services/upload_img_services.dart';
import 'package:image/image.dart' as imglib;
import 'package:passman/platform/mobile/model/points.dart';
import 'package:passman/.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class PassmanLogin extends StatefulWidget {
  PassmanLogin({Key? key}) : super(key: key);
  @override
  _PassmanLoginState createState() => _PassmanLoginState();
}

class _PassmanLoginState extends State<PassmanLogin> {
  Image? image;
  imglib.Image? editableImage;
  List<Points>? password = <Points>[];
  final ImagePicker picker = ImagePicker();
  LoadingState? loadingState;
  bool pickedImg = false;
  File? _selectedImage, _image;

  Future<String> _getImage() async {
    if (mounted) {
      setState(() {
        loadingState = LoadingState.LOADING;
      });
    }
    String? uuid = fireServer.mAuth.currentUser!.uid;
    String? _imageLink;
    DefaultCacheManager cache = DefaultCacheManager();
    DocumentSnapshot value = await fireServer.userDataColRef.doc(uuid).get();
    setState(() {
      _imageLink = value.data()!['img'];
    });

    _image = await cache.getSingleFile(_imageLink!);
    _selectedImage = File(_image!.path);
    UploadedImageConversionResponse response =
        await convertUploadedImageToDataaAsync(
      UploadedImageConversionRequest(
        _selectedImage!,
      ),
    );
    if (mounted) {
      setState(() {
        editableImage = response.editableImage;
        pickedImg = true;
        image = response.displayableImage;
        loadingState = LoadingState.SUCCESS;
      });
    }
    return _imageLink!;
  }

  @override
  void initState() {
    super.initState();
    loadingState = LoadingState.PENDING;
    _getImage();
    password!.removeRange(0, password!.length);
  }

  @override
  Widget build(BuildContext context) {
    Future<void> sendToDecode() async {
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
        child: ZStack(
          <Widget>[
            loadingState == LoadingState.PENDING
                ? const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.appMainColor),
                    strokeWidth: 3,
                  ).centered()
                : VStack(
                    pickedImg == true
                        ? <Widget>[
                            VxBox(
                              child: GestureDetector(
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
                                },
                                child: ZStack(
                                  <Widget>[
                                    VxBox()
                                        .bgImage(
                                          DecorationImage(
                                            fit: BoxFit.cover,
                                            image: Image(
                                              image: FileImage(_selectedImage!),
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
                                .border(width: 3, color: AppColors.appMainColor)
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
                                          password!
                                              .removeRange(0, password!.length);
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
                                            ? () => sendToDecode()
                                            : null,
                                      )
                                    : const SizedBox(
                                        width: 49,
                                        height: 49,
                                      ),
                              ],
                              alignment: MainAxisAlignment.spaceBetween,
                              axisSize: MainAxisSize.max,
                              crossAlignment: CrossAxisAlignment.center,
                            ),
                          ]
                        : <Widget>[
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.appMainColor),
                              strokeWidth: 3,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            'Fetching your data...'
                                .text
                                .fontFamily('LexendDeca')
                                .lg
                                .semiBold
                                .make(),
                          ],
                    alignment: MainAxisAlignment.center,
                    axisSize: MainAxisSize.max,
                    crossAlignment: CrossAxisAlignment.center,
                  ).centered(),
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
                Navigator.pushReplacementNamed(
                  context,
                  PageRoutes.routeMobile,
                );
              },
            ).positioned(top: 20, right: 20),
          ],
        ),
      ),
    );
  }
}
