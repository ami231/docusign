import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MatrixController extends GetxController {
  final Rx<Matrix4> currentPosition = Matrix4.identity().obs;

  matrixUpdate(m){
    currentPosition(m);
  }
}
