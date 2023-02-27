import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ImageController extends GetxController{
  Image? image;
  Uint8List? imageBytes;

  updateImage(img, bytes) {
    image = img;
    imageBytes = bytes;
  }
}