import 'dart:io' show Platform;
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/UI/desktop/desktop.dart';
import 'package:passman/services/decryption.dart';
import 'package:passman/services/random.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class Mobile extends StatefulWidget {
  const Mobile({Key key}) : super(key: key);
  @override
  _MobileState createState() => _MobileState();
}

class _MobileState extends State<Mobile> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode result;
  QRViewController controller;
  bool flash = false;
  bool flipCam = false;
  final Decryption decryption = Decryption();
  final RandomNumberGenerator randomNumberGenerator = RandomNumberGenerator();
  String generatedString;
  final Logger logger = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            _buildQrView(context),
            Positioned(
              top: 10,
              right: 10,
              child: !flipCam
                  ? IconButton(
                      onPressed: () async {
                        await controller?.toggleFlash();
                        setState(
                          () {
                            flash = !flash;
                          },
                        );
                      },
                      icon: FutureBuilder<bool>(
                        future: controller?.getFlashStatus(),
                        builder: (BuildContext context,
                            AsyncSnapshot<bool> snapshot) {
                          return Icon(
                            flash ? TablerIcons.bulb : TablerIcons.bulb_off,
                            color: flash
                                ? Colors.white
                                : Colors.grey[300].withOpacity(0.3),
                            size: 10 * SizeConfig.imageSizeMultiplier,
                          );
                        },
                      ),
                    )
                  : const SizedBox(),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                onPressed: () async {
                  await controller?.flipCamera();
                  setState(() {
                    flipCam = !flipCam;
                  });
                },
                icon: FutureBuilder<CameraFacing>(
                  future: controller?.getCameraInfo(),
                  builder: (BuildContext context,
                      AsyncSnapshot<CameraFacing> snapshot) {
                    if (snapshot.data != null) {
                      return Icon(
                        TablerIcons.rotate,
                        color: Colors.white,
                        size: 10 * SizeConfig.imageSizeMultiplier,
                      );
                    } else {
                      return const Text('loading');
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showCode(Barcode result) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Code',
            style: GoogleFonts.lexendDeca(
              fontSize: 5 * SizeConfig.textMultiplier,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            (result != null) ? result.code : 'Scan a code',
            style: GoogleFonts.lexendDeca(
              fontSize: 3 * SizeConfig.textMultiplier,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await controller?.resumeCamera();
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: GoogleFonts.lexendDeca(
                  fontSize: 2 * SizeConfig.textMultiplier,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQrView(BuildContext context) {
    final double scanArea = 70 * SizeConfig.widthMultiplier;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((Barcode scanData) async {
      setState(() {
        result = scanData;
      });
      await controller?.pauseCamera();
      showCode(result);
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
