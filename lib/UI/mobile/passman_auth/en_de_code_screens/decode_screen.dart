import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:passman/Components/constants.dart';
import 'package:passman/Components/data_card.dart';
import 'package:passman/Components/screen_adapter.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/UI/mobile/pass_not_match.dart';
import 'package:passman/services/decode.dart';
import 'package:passman/services/decryption.dart';
import 'package:passman/services/encryption.dart';

class DecodingResultScreen extends StatefulWidget {
  DecodingResultScreen(this.decodeResultData);
  final dynamic decodeResultData;

  @override
  State<StatefulWidget> createState() => _DecodingResultScreen();
}

class _DecodingResultScreen extends State<DecodingResultScreen> {
  Future<String>? decodedMsg;
  String? accountName,
      username,
      password,
      pass,
      uName,
      tempacc,
      uuid = mAuth.currentUser!.uid;
  final Encryption encryption = Encryption();
  final Decryption decryption = Decryption();
  void uploadAccData() {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('UserData/${uuid!}/Accounts')
        .doc(accountName);
    uName = encryption.stringEncryption(username!).base64;
    pass = encryption.stringEncryption(password!).base64;
    Map<String, String> userData = <String, String>{
      'username': uName!,
      'password': pass!
    };

    documentReference.set(userData).whenComplete(() {
      print('$username created');
      // print();
    });
  }

  void deleteAccData(dynamic item) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection(uuid!).doc(item);
    documentReference.delete().whenComplete(() {
      print('$item deleted');
    });
  }

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
  Widget build(BuildContext context) => ScreenAdapter(
        child: FutureBuilder<String?>(
          future: decodedMsg,
          builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
            if (!snapshot.hasData ||
                snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const CircularProgressIndicator(),
                      SizedBox(
                        height: 5 * SizeConfig.heightMultiplier,
                      ),
                      Text(
                        'Fetching your data...',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 1.75 * SizeConfig.textMultiplier,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasData) {
              if (snapshot.data! == widget.decodeResultData.points) {
                print('matches');
                return Scaffold(
                  appBar: AppBar(
                    title: Text(mAuth.currentUser!.displayName!),
                    centerTitle: true,
                    automaticallyImplyLeading: false,
                    actions: <Widget>[
                      IconButton(
                        icon: const Icon(
                          IconData(
                            0xeba8,
                            fontFamily: 'IconsFont',
                          ),
                        ),
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          PageRoutes.routeState,
                        ),
                      ),
                    ],
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                title: const Text('Add Data'),
                                content: Container(
                                  height: 170,
                                  child: Column(
                                    children: <Widget>[
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
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                      onPressed: () {
                                        uploadAccData();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Add'))
                                ],
                              ));
                    },
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                  body: StreamBuilder<QuerySnapshot?>(
                    stream: FirebaseFirestore.instance
                        .collection('UserData/${uuid!}/Accounts')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot?> snapshots) {
                      if (snapshots.hasData) {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshots.data!.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            DocumentSnapshot documentSnapshot =
                                snapshots.data!.docs[index];
                            return DataCard(
                              decryption.stringDecryption(
                                  documentSnapshot['username']),
                              // documentSnapshot['password'],
                              onPressed: () {
                                deleteAccData(documentSnapshot.id);
                              },
                            );
                          },
                        );
                      } else if (!snapshots.hasData) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const CircularProgressIndicator(),
                            SizedBox(
                              height: 5 * SizeConfig.heightMultiplier,
                            ),
                            Text(
                              'Trying to fetch your data...',
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 1.75 * SizeConfig.textMultiplier,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        );
                      }
                    return const CircularProgressIndicator();
                    },
                  ),
                );
              } else {
                print("doesn't match");
                return SorryPage();
              }
            } else if (snapshot.hasError) {
              return Container(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                child: ListView(
                  children: <Widget>[
                    const SizedBox(
                      height: 5.0,
                    ),
                    Container(
                      child: const Center(
                          child: Text(
                        'Whoops >_<',
                        style: TextStyle(fontSize: 30.0),
                      )),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Container(
                      child: const Center(
                        child: Text(
                          'It seems something went wrong',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                  ],
                ),
              );
            } else {
              return Container(
                child: ListView(
                  children: <Widget>[
                    const SizedBox(
                      height: 5.0,
                    ),
                    const CircularProgressIndicator(),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 0.0),
                      child: const Text(
                        '''
Please be patient, password manager is decoding your message...''',
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      );
}
