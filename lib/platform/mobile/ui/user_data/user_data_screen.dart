import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:passman/platform/mobile/ui/user_data/accounts_data.dart';
import 'package:passman/platform/mobile/ui/user_data/cards_screen.dart';
import 'package:passman/platform/mobile/ui/user_data/images_screen.dart';
import 'package:passman/services/crypto/encryption.dart';

import 'package:passman/utils/constants.dart';
import 'package:velocity_x/velocity_x.dart';

class UserDataScreen extends StatefulWidget {
  @override
  _UserDataScreenState createState() => _UserDataScreenState();
}

class _UserDataScreenState extends State<UserDataScreen>
    with TickerProviderStateMixin {
  String? accountName,
      username,
      password,
      pass,
      uName,
      tempacc,
      uuid = fireServer.mAuth.currentUser!.uid;
  TabController? _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        child: HStack(
          <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.appMainColor,
              ),
              width: 270,
              height: 50,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TabBar(
                  controller: _tabController!,
                  labelColor: Colors.white,
                  indicator: CircleTabIndicator(
                    color: Colors.white,
                    radius: 3,
                  ),
                  physics: const BouncingScrollPhysics(),
                  unselectedLabelColor: Colors.black,
                  tabs: <Widget>[
                    const Tab(
                      icon: Icon(Iconsdata.passwords),
                    ),
                    const Tab(
                      icon: Icon(Iconsdata.images),
                    ),
                    const Tab(
                      icon: Icon(Iconsdata.credit_card),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey[300],
              ),
              child: Center(
                child: IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  onPressed: () async {
                    await buildShowDialog(context);
                  },
                  icon: const Icon(
                    Icons.add_rounded,
                  ),
                ),
              ),
            ),
          ],
          alignment: MainAxisAlignment.spaceEvenly,
          crossAlignment: CrossAxisAlignment.center,
          axisSize: MainAxisSize.max,
        ).p8(),
      ),
      extendBody: true,
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          AccountsData(),
          ImagesScreen(),
          CardsScreen(),
        ],
      ),
    );
  }

  Future<void> uploadAccData() async {
    try {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('UserData/${uuid!}/Accounts')
          .doc(accountName);
      uName = encryption.uNameEncryption(username!).base64;
      pass = encryption.uPassEncryption(password!).base64;
      Map<String, String> userData = <String, String>{
        'username': uName!,
        'password': pass!
      };
      await documentReference.set(userData);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> buildShowDialog(BuildContext context) async {
    return VxDialog.showCustom(
      context,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text('Add Data'),
        content: VxBox(
          child: VStack(
            <Widget>[
              TextField(
                onChanged: (String value) {
                  accountName = value;
                },
                decoration: const InputDecoration(
                  hintText: 'Account Name',
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                onChanged: (String value) {
                  username = value;
                },
                decoration: const InputDecoration(
                  hintText: 'username / Email',
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                onChanged: (String value) {
                  password = value;
                },
                decoration: const InputDecoration(
                  hintText: 'Password',
                ),
              ),
            ],
            alignment: MainAxisAlignment.center,
            crossAlignment: CrossAxisAlignment.center,
            axisSize: MainAxisSize.max,
          ),
        ).height(170).make(),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              if (accountName == null || password == null || username == null) {
                VxDialog.showAlert(
                  context,
                  title: 'Sorry',
                  content: 'No field should be left empty.',
                  confirmBgColor: Colors.transparent,
                  confirmTextColor: AppColors.appMainColor,
                  barrierDismissible: false,
                );
              } else {
                await uploadAccData();
                Navigator.of(context).pop();
              }
            },
            child: 'Add'.text.center.fontFamily('LexendDeca').make().centered(),
          ),
        ],
      ),
    );
  }
}

class CircleTabIndicator extends Decoration {
  CircleTabIndicator({required Color color, required double radius})
      : _painter = _CirclePainter(color, radius);
  final BoxPainter _painter;

  @override
  BoxPainter createBoxPainter([Function()? onChanged]) => _painter;
}

class _CirclePainter extends BoxPainter {
  _CirclePainter(Color color, this.radius)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  final Paint _paint;
  final double radius;
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    Offset circleOffset = offset + Offset(40, 45 - radius);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}
