import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:passman/platform/mobile/services/en_de_coding/decode.dart';
import 'package:passman/platform/mobile/services/en_de_coding/encode.dart';
import 'package:passman/utils/constants.dart';
import 'package:velocity_x/velocity_x.dart';

class EncodingResultScreen extends StatefulWidget {
  @override
  _EncodingResultScreenState createState() => _EncodingResultScreenState();
}

class _EncodingResultScreenState extends State<EncodingResultScreen> {
  Future<DecodeResultScreenRenderRequest>? renderRequest;
  String? uuid = fireServer.mAuth.currentUser!.uid;
  LoadingState? savingState, uploadingToStorageState;

  @override
  void initState() {
    super.initState();
    savingState = LoadingState.PENDING;
    uploadingToStorageState = LoadingState.PENDING;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)!.settings.arguments != null) {
      EncodeRequest encodeReq =
          ModalRoute.of(context)!.settings.arguments! as EncodeRequest;
      renderRequest = requestEncodeImage(encodeReq);
    }
  }

  Future<DecodeResultScreenRenderRequest> requestEncodeImage(
      EncodeRequest req) async {
    EncodeResponse response =
        await encodeMessageIntoImageAsync(req, context: context);
    return DecodeResultScreenRenderRequest(
        DecodeResultState.SUCCESS, response.data, response.displayableImage);
  }

  Future<void> uploadToStorage(Uint8List? _imageData) async {
    setState(() {
      uploadingToStorageState = LoadingState.LOADING;
    });
    String filename = '$uuid.png';
    Reference pathRef =
        fireServer.storageRef.child('UserImgData').child(filename);
    UploadTask uploadTask = pathRef.putData(_imageData!);
    await uploadTask.whenComplete(() async {
      String downImg = await uploadTask.snapshot.ref.getDownloadURL();
      await fireServer.userDataColRef.doc(uuid).update(<String, dynamic>{
        'img': downImg,
      });
    });
    setState(() {
      uploadingToStorageState = LoadingState.SUCCESS;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ZStack(
          <Widget>[
            FutureBuilder<DecodeResultScreenRenderRequest>(
              future: renderRequest,
              builder: (BuildContext context,
                  AsyncSnapshot<DecodeResultScreenRenderRequest> snapshot) {
                if (snapshot.hasData) {
                  return VxBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Lottie.asset(
                          LottieFiles.done,
                          height: 60,
                          repeat: true,
                          animate: true,
                        ),
                        VxBox(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: Image.memory(
                              snapshot.data!.encodedByteImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                            .withRounded(value: 10)
                            .border(width: 3, color: AppColors.appMainColor)
                            .make()
                            .h(context.screenWidth * 0.9)
                            .w(context.screenWidth * 0.9),
                        VxBox(
                          child: TextButton(
                            style: ButtonStyle(
                              overlayColor: MaterialStateColor.resolveWith(
                                (Set<MaterialState> states) =>
                                    Colors.transparent,
                              ),
                            ),
                            onPressed:
                                uploadingToStorageState == LoadingState.PENDING
                                    ? () {
                                        uploadToStorage(
                                          snapshot.data!.encodedByteImage,
                                        );
                                      }
                                    : null,
                            child:
                                uploadingToStorageState == LoadingState.LOADING
                                    ? 'Uploading to Database...'
                                        .text
                                        .black
                                        .fontFamily('LexendDeca')
                                        .semiBold
                                        .lg
                                        .make()
                                    : uploadingToStorageState ==
                                            LoadingState.PENDING
                                        ? 'Save'
                                            .text
                                            .black
                                            .fontFamily('LexendDeca')
                                            .semiBold
                                            .lg
                                            .make()
                                        : uploadingToStorageState ==
                                                LoadingState.SUCCESS
                                            ? 'Saved successfully'
                                                .text
                                                .black
                                                .fontFamily('LexendDeca')
                                                .semiBold
                                                .lg
                                                .make()
                                            : 'Error'
                                                .text
                                                .black
                                                .fontFamily('LexendDeca')
                                                .semiBold
                                                .lg
                                                .make(),
                          ),
                        ).make(),
                        const SizedBox(
                          height: 30.0,
                        ),
                      ],
                    ),
                  ).make().centered().px(10);
                } else if (snapshot.hasError) {
                  setState(() {
                    uploadingToStorageState = LoadingState.SUCCESS;
                  });
                  return VxBox(
                    child: VStack(
                      <Widget>[
                        const SizedBox(
                          height: 5.0,
                        ),
                        VxBox(
                          child: 'Whoops 😓'
                              .text
                              .xl2
                              .fontFamily('LexendDeca')
                              .make()
                              .centered(),
                        ).make(),
                        const SizedBox(
                          height: 5.0,
                        ),
                        VxBox(
                          child: '''
It seems something went wrong: \n${snapshot.error.toString()}'''
                              .text
                              .fontFamily('LexendDeca')
                              .center
                              .make(),
                        ).make(),
                      ],
                      alignment: MainAxisAlignment.center,
                      crossAlignment: CrossAxisAlignment.center,
                    ).centered(),
                  ).make().px(10);
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.appMainColor,
                          ),
                          strokeWidth: 3,
                        ),
                        'We are encoding the data into image...'
                            .text
                            .fontFamily('LexendDeca')
                            .make()
                            .py24(),
                      ],
                    ),
                  );
                }
              },
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
            uploadingToStorageState == LoadingState.SUCCESS
                ? IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    icon: const Icon(
                      Iconsdata.x,
                    ),
                    onPressed: () async => Navigator.pushReplacementNamed(
                      context,
                      PageRoutes.routeMobile,
                    ),
                  ).positioned(top: 20, right: 10)
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
