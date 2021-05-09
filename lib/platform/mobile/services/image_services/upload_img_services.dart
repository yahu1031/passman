import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as imglib;

class UploadedImageConversionResponse {
  UploadedImageConversionResponse(
      this.editableImage, this.displayableImage, this.imageByteSize);
  imglib.Image editableImage;
  Image displayableImage;
  int imageByteSize;
}


/// Uploaded Image Conversion Request
///
/// {@category Services: Requests}
class UploadedImageConversionRequest {
  UploadedImageConversionRequest(this.file);
  File file;
}
