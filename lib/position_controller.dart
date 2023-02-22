import 'package:get/get.dart';

class PositionController extends GetxController{
  final RxDouble xAxis = (0.0).obs;
  final RxDouble yAxis = (0.0).obs;
  final scaleFactor = (1.0).obs;
  final initialScale = (1.0).obs;
  final resizingModeOn = false.obs;

  updatePosition(double x, double y){
    xAxis(xAxis.value + x);
    yAxis(yAxis.value + y);
  }

  updateScaleFactor(scale){
    scaleFactor(initialScale.value * scale);
    print(scaleFactor.value);
  }
  updateInitialScale(){
    initialScale(scaleFactor.value);
  }

  updateResizingMode(){
    if (resizingModeOn.value){
      resizingModeOn(false);
    }
    else{
      resizingModeOn(true);
    }
  }
}