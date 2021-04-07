// import 'dart:developer';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:passman/Components/constants.dart';
import 'package:passman/Components/screen_adapter.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/services/decode.dart';
import 'package:passman/services/encode.dart';
import 'package:passman/services/utilities/enums.dart';

class EncodingResultScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EncodingResultScreen();
}

class _EncodingResultScreen extends State<EncodingResultScreen> {
  Future<DecodeResultScreenRenderRequest>? renderRequest;
  String? uuid = FirebaseAuth.instance.currentUser!.uid;
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
    Reference pathRef = storageRef.child('UserImgData').child(filename);
    UploadTask uploadTask = pathRef.putData(_imageData!);
    await uploadTask.whenComplete(() async {
      String downImg = await uploadTask.snapshot.ref.getDownloadURL();
      await userDataColRef.doc(uuid).update(<String, dynamic>{
        'img': downImg,
      });
    });
    setState(() {
      uploadingToStorageState = LoadingState.SUCCESS;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Center(
                child: ScreenAdapter(
                  child: FutureBuilder<DecodeResultScreenRenderRequest>(
                    future: renderRequest,
                    builder: (BuildContext context,
                        AsyncSnapshot<DecodeResultScreenRenderRequest>
                            snapshot) {
                      if (snapshot.hasData) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 0.0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Lottie.asset(
                                    LottieFiles.done,
                                    height: 30 * SizeConfig.widthMultiplier,
                                    repeat: true,
                                    animate: true,
                                  ),
                                ),
                              ),
                              Container(
                                height: MediaQuery.of(context).size.width * 0.9,
                                width: MediaQuery.of(context).size.width * 0.9,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 3,
                                    color: Colors.black,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(7),
                                  child: Image.memory(
                                    snapshot.data!.encodedByteImage,
                                  ),
                                ),
                              ),
                              Container(
                                child: TextButton(
                                  onPressed: uploadingToStorageState ==
                                          LoadingState.PENDING
                                      ? () {
                                          uploadToStorage(
                                            snapshot.data!.encodedByteImage,
                                          );
                                        }
                                      : null,
                                  child: Text(
                                    uploadingToStorageState ==
                                            LoadingState.LOADING
                                        ? 'Uploading to Database...'
                                        : uploadingToStorageState ==
                                                LoadingState.PENDING
                                            ? 'Save'
                                            : uploadingToStorageState ==
                                                    LoadingState.SUCCESS
                                                ? 'Saved successfully'
                                                : 'Error',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Quicksand',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 2 * SizeConfig.textMultiplier,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 30.0,
                              ),
                            ],
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 0.0,
                          ),
                          child: ListView(
                            children: <Widget>[
                              const SizedBox(
                                height: 5.0,
                              ),
                              Center(
                                child: Container(
                                  child: const Text(
                                    'Whoops >_<',
                                    style: TextStyle(fontSize: 30.0),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              Container(
                                child: Center(
                                  child: Text(
                                    'It seems something went wrong: ' +
                                        snapshot.error.toString(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const CircularProgressIndicator(),
                              const Text(
                                'We are encoding the data into image...',
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_outlined,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        ),
      );
}
