import 'dart:typed_data';

final int byteSize = 8;
final int byteCnt = 2;
final int dataLength = byteSize * byteCnt;

int getEncoderCapacity(Uint16List img) => img.length;

/// !Helper function to convert string to bytes
Uint16List msg2bytes(String msg) => Uint16List.fromList(msg.codeUnits);

String bytes2msg(Uint16List bytes) => String.fromCharCodes(bytes);

int getMsgSize(String msg) {
  Uint16List byteMsg = msg2bytes(msg);
  return byteMsg.length * dataLength;
}

/// * Helper function to expand byte messages to bit messages
Uint16List expandMsg(Uint16List msg) {
  Uint16List expanded = Uint16List(msg.length * dataLength);
  for (int i = 0; i < msg.length; ++i) {
    int msgByte = msg[i];
    for (int j = 0; j < dataLength; ++j) {
      int lastBit = msgByte & 1;
      expanded[i * dataLength + (dataLength - j - 1)] = lastBit;
      msgByte = msgByte >> 1;
    }
  }
  return expanded;
}
