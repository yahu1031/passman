import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as imglib;
import 'package:passman/services/image_services/upload_img_services.dart';
import 'package:passman/services/utilities/get_capacity.dart';

UploadedImageConversionResponse convertUploadedImageToData(
    UploadedImageConversionRequest req) {
  imglib.Image editableImage = imglib.decodeImage(req.file.readAsBytesSync())!;
  Image displayableImage = Image.file(req.file, fit: BoxFit.cover);
  int imageByteSize = getEncoderCapacity(
      Uint16List.fromList(editableImage.getBytes().toList()));
  UploadedImageConversionResponse response = UploadedImageConversionResponse(
      editableImage, displayableImage, imageByteSize);
  return response;
}

Future<UploadedImageConversionResponse> convertUploadedImageToDataaAsync(
    UploadedImageConversionRequest req) async {
  UploadedImageConversionResponse response = await compute<
      UploadedImageConversionRequest,
      UploadedImageConversionResponse>(convertUploadedImageToData, req);
  return response;
}
