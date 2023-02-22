import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:get/get.dart';
import 'package:signature/doc.dart';
import 'image_controller.dart';


class WriteSignature extends StatefulWidget {
  const WriteSignature({Key? key}) : super(key: key);

  @override
  State<WriteSignature> createState() => _WriteSignatureState();
}

class _WriteSignatureState extends State<WriteSignature> {


  String title = 'Write your signature here:';
  final GlobalKey<SfSignaturePadState> _signaturePadState = GlobalKey();
  final imageController = Get.put(ImageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  color: Colors.grey,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SfSignaturePad(
                      key: _signaturePadState,
                      backgroundColor: Colors.transparent,
                      strokeColor: Colors.black,
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () async {
                    final data =
                    await _signaturePadState.currentState!.toImage(pixelRatio: 3.0);
                    final bytes = await data.toByteData(format: ui.ImageByteFormat.png);
                    final image = Image.memory(bytes!.buffer.asUint8List());
                    imageController.updateImage(image);
                    Get.to(const OpenDocument());
                  },
                  child: const Text('SAVE'),
                ),
              ],
        ),
      ),
    );
  }
}
