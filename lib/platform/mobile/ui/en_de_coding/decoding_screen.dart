import 'package:flutter/material.dart';
import 'package:passman/platform/mobile/ui/user_data/user_data_screen.dart';
import 'package:passman/platform/mobile/services/en_de_coding/decode.dart';
import 'package:passman/utils/constants.dart';
import 'package:velocity_x/velocity_x.dart';

class DecodingResultScreen extends StatefulWidget {
  DecodingResultScreen(this.decodeResultData);
  final dynamic decodeResultData;
  @override
  _DecodingResultScreenState createState() => _DecodingResultScreenState();
}

class _DecodingResultScreenState extends State<DecodingResultScreen> {
  Future<String>? decodedMsg;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    DecodeRequest req = widget.decodeResultData.request;
    decodedMsg = decodeMsg(req);
  }

  Future<String> decodeMsg(DecodeRequest req) async {
    DecodeResponse response =
        await decodeMessageFromImageAsync(req, context: context);
    String msg = response.decodedMsg;
    return msg;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<String?>(
          future: decodedMsg,
          builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
            if (!snapshot.hasData ||
                snapshot.connectionState == ConnectionState.waiting) {
              return VStack(
                <Widget>[
                  const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.appMainColor),
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
                crossAlignment: CrossAxisAlignment.center,
                axisSize: MainAxisSize.max,
              ).centered();
            } else if (snapshot.hasData) {
              if (snapshot.data! == widget.decodeResultData.points) {
                return UserDataScreen();
              } else {
                return const CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.appMainColor),
                  strokeWidth: 3,
                ).centered();
              }
            } else if (snapshot.hasError) {
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
              return VxBox(
                child: ListView(
                  children: <Widget>[
                    const SizedBox(
                      height: 5.0,
                    ),
                    const CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.appMainColor),
                      strokeWidth: 3,
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    '''
Please be patient, password manager is decoding your data...'''
                        .text
                        .center
                        .black
                        .fontFamily('LexendDeca')
                        .make(),
                  ],
                ),
              ).make();
            }
          },
        ),
      ),
    );
  }
}
