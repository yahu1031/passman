import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passman/platform/mobile/components/data_card.dart';
import 'package:passman/services/crypto/decryption.dart';
import 'package:passman/utils/constants.dart';
import 'package:velocity_x/velocity_x.dart';

class AccountsData extends StatefulWidget {
  @override
  _AccountsDataState createState() => _AccountsDataState();
}

class _AccountsDataState extends State<AccountsData> {
  String uuid = fireServer.mAuth.currentUser!.uid;
  static Future<void> copy(String text) async {
    if (text.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: text));
      return;
    } else {
      throw ('Please enter a string');
    }
  }

  Future<void> deleteAccData(String? item) async {
    try {
      DocumentReference documentReference =
          FirebaseFirestore.instance.doc('UserData/$uuid/Accounts/$item');
      await documentReference.delete();
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot?>(
        stream: FirebaseFirestore.instance
            .collection('UserData/$uuid/Accounts')
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshots) {
          if (snapshots.hasData) {
            if (snapshots.data!.docs.isEmpty) {
              return 'No data to fetch'
                  .text
                  .black
                  .medium
                  .fontFamily('LexendDeca')
                  .semiBold
                  .center
                  .make()
                  .centered();
            } else {
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshots.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  DocumentSnapshot documentSnapshot =
                      snapshots.data!.docs[index];
                  return DataCard(
                    decryption.uNameDecryption(documentSnapshot['username']),
                    copyPressed: () async {
                      await copy(
                        decryption.uPassDecryption(
                          documentSnapshot['password'],
                        ),
                      ).whenComplete(() async {
                        log('Copied to clipboard');
                      });
                    },
                    onLongPress: () async {
                      VxDialog.showConfirmation(
                        context,
                        barrierDismissible: false,
                        title: 'Delete ${documentSnapshot.id}',
                        content:
                            'Do you want to delete ${documentSnapshot.id} ?',
                        cancelTextColor: Colors.black,
                        confirm: 'Delete',
                        confirmTextColor: Colors.white,
                        confirmBgColor: Colors.red,
                        onCancelPress: () => Navigator.of(context).pop(),
                        onConfirmPress: () async =>
                            deleteAccData(documentSnapshot.id),
                      );
                    },
                  );
                },
              );
            }
          } else if (!snapshots.hasData) {
            return const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.appMainColor),
              strokeWidth: 3,
            ).centered();
          } else if (snapshots.hasError) {
            return 'Sorry there was some error while fetching data'
                .text
                .black
                .lg
                .fontFamily('LexendDeca')
                .semiBold
                .center
                .make()
                .centered();
          }
          return const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.appMainColor),
            strokeWidth: 3,
          );
        },
      ),
    );
  }
}
