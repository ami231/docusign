import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ImageController extends GetxController{
  Image? image;

  updateImage(img) {
    image = img;
  }

}