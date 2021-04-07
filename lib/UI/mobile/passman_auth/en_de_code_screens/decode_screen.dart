import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:passman/Components/constants.dart';
import 'package:passman/Components/data_card.dart';
import 'package:passman/Components/screen_adapter.dart';
import 'package:passman/Components/size_config.dart';
import 'package:passman/UI/mobile/pass_not_match.dart';
import 'package:passman/services/decode.dart';

class DecodingResultScreen extends StatefulWidget {
  DecodingResultScreen(this.decodeResultData);
  final dynamic decodeResultData;

  @override
  State<StatefulWidget> createState() => _DecodingResultScreen();
}

class _DecodingResultScreen extends State<DecodingResultScreen> {
  Future<String>? decodedMsg;
  String accountName = '';
  String username = '';
  String password = '';
  String? tempacc;
  String? uuid = mAuth.currentUser!.uid;
  void createpasss() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection(uuid!).doc(accountName);
    Map<String, String> passs = <String, String>{
      'Username': username,
      'password': password
    };

    documentReference.set(passs).whenComplete(() {
      print('$username created');
      // print();
    });
  }

  void deletepasss(dynamic item) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection(uuid!).doc(item);
    documentReference.delete().whenComplete(() {
      print('$item deleted');
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // if (ModalRoute.of(context).settings.arguments != null) {
    DecodeRequest req = widget.decodeResultData.request;
    // DecodeRequest req = ModalRoute.of(context).settings.arguments;
    decodedMsg = decodeMsg(req);
    // }
  }

  Future<String> decodeMsg(DecodeRequest req) async {
    DecodeResponse response =
        await decodeMessageFromImageAsync(req, context: context);
    String msg = response.decodedMsg;
    return msg;
  }

  @override
  Widget build(BuildContext context) => ScreenAdapter(
        child: FutureBuilder<String>(
          future: decodedMsg,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (!snapshot.hasData ||
                snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasData) {
              if (snapshot.data == widget.decodeResultData.points) {
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
                        onPressed: () => Navigator.of(context).pop(true),
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
                                          hintText: 'Username / Email',
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
                                        createpasss();
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
                  body: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection(uuid!)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshots) {
                        if (!snapshots.hasData || snapshots.hasData) {
                          if (!snapshot.hasData) {
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
                          } else {
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshots.data!.docs.length,
                              itemBuilder: (BuildContext context, int index) {
                                DocumentSnapshot documentSnapshot =
                                    snapshots.data!.docs[index];
                                return DataCard(
                                  documentSnapshot['Username'],
                                  documentSnapshot['password'],
                                  onPressed: () {
                                    deletepasss(documentSnapshot.id);
                                  },
                                );
                              },
                            );
                          }
                        } else {
                          return const Align(
                            alignment: FractionalOffset.bottomCenter,
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
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
