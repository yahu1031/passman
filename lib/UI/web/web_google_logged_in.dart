import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/services/authentication.dart';
import 'package:provider/provider.dart';

class WebGoogleLoggedin extends StatefulWidget {
  @override
  _WebGoogleLoggedinState createState() => _WebGoogleLoggedinState();
}

class _WebGoogleLoggedinState extends State<WebGoogleLoggedin> {
  @override
  Widget build(BuildContext context) {
    GoogleSignInProvider provider =
        Provider.of<GoogleSignInProvider>(context, listen: false);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Center(
            child: Lottie.asset(
              'assets/lottie/google.json',
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              tooltip: 'Log out as ${provider.getCurrentUser().toUpperCase()}.',
              icon: const Icon(TablerIcons.logout),
              onPressed: () {
                provider.logout();
              },
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Tooltip(
              message: provider.getCurrentUser().toUpperCase(),
              child: CircleAvatar(
                backgroundImage: provider.getUserImage() as ImageProvider,
                foregroundColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                foregroundImage: provider.getUserImage() as ImageProvider,
                minRadius: 4 * SizeConfig.imageSizeMultiplier,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
