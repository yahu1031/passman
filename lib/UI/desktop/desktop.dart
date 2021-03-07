import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/UI/desktop/enter_code.dart';
import 'package:passman/services/encryption.dart';
import 'package:passman/services/random.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class Desktop extends StatefulWidget {
  const Desktop({Key key}) : super(key: key);
  @override
  _DesktopState createState() => _DesktopState();
}

class _DesktopState extends State<Desktop> {
  @override
  Widget build(BuildContext context) {
    final Logger logger = Logger(
      printer: PrettyPrinter(methodCount: 0),
    );
    String generatedString =
        Provider.of<RandomNumberGenerator>(context).getString;
    String encryptedString = Provider.of<Encryption>(context).getString;
    void encryptingString(BuildContext context) {
      Provider.of<RandomNumberGenerator>(context, listen: false)
          .randomStringGenerator(6);
      logger.i(generatedString);
    }

    encryptingString(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            QrImage(
              data: encryptedString,
              version: 7,
              size: 30 * SizeConfig.imageSizeMultiplier,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Scan the QR Code and ',
                  style: GoogleFonts.quicksand(
                    fontSize: SizeConfig.textMultiplier,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<dynamic>(
                        builder: (BuildContext context) => EnterCode(),
                      ),
                    );
                  },
                  child: Text(
                    'Enter Code',
                    style: GoogleFonts.quicksand(
                      fontSize: SizeConfig.textMultiplier,
                      color: Colors.blue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
