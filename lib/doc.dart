import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_image_renderer/pdf_image_renderer.dart';
import 'package:get/get.dart';
import 'position_controller.dart';
import 'image_controller.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';

class OpenDocument extends StatefulWidget {
  const OpenDocument({
    Key? key,
  }) : super(key: key);

  @override
  State<OpenDocument> createState() => _OpenDocumentState();
}

class _OpenDocumentState extends State<OpenDocument> {
  var image;
  bool pdfIsPicked = false;
  bool signatureIsAdded = false;

  void rendererPdfImage(PlatformFile file) async {
    String path = file.path!;
    final pdf = PdfImageRendererPdf(path: path);
    await pdf.open();
    await pdf.openPage(pageIndex: 0);
    final size = await pdf.getPageSize(pageIndex: 0);

    final img = await pdf.renderPage(
      pageIndex: 0,
      x: 0,
      y: 0,
      width: size.width,
      height: size.height,
      scale: 1,
      // for quality (zooming)
      background: Colors.white,
    );

    await pdf.closePage(pageIndex: 0);
    pdf.close();

    setState(() {
      image = img;
      pdfIsPicked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: pdfIsPicked
                    ? Stack(
                        children: [
                          Image(
                            image: MemoryImage(image),
                          ),
                          if (signatureIsAdded) SignaturePosition(),
                        ],
                      )
                    : IconButton(
                        onPressed: () async {
                          final FilePickerResult? result =
                              await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                          if (result == null) return;
                          final file = result.files.first;
                          rendererPdfImage(file);
                        },
                        icon: const Icon(
                          Icons.add_circle,
                          size: 40.0,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            if(pdfIsPicked) Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  if(!signatureIsAdded) ElevatedButton(
                    onPressed: () {
                      setState(() {
                        signatureIsAdded = true;
                      });
                    },
                    child: const Text('insert signature'),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.share),
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SignaturePosition extends StatelessWidget {
  SignaturePosition({
    Key? key,
  }) : super(key: key);
  final positionController = Get.put(PositionController());
  final imageController = Get.put(ImageController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        var size = positionController.initialScale.value * 100;
        bool resizingMode = positionController.resizingModeOn.value;
        return Positioned(
          left: positionController.xAxis.value,
          top: positionController.yAxis.value,
          child: !resizingMode ? Draggable<int>(
            data: 10,
            feedback: Container(
              color: resizingMode ? Colors.green : Colors.red,
              height: size,
              width: size,
            ),
            onDragUpdate: (details) {
              var x = details.delta.dx;
              var y = details.delta.dy;
              positionController.updatePosition(x, y);
            },
            child: GestureDetector(
              onTap: (){
                positionController.updateResizingMode();
              },
              child: Container(
                height: size,
                width: size,
                color: resizingMode ? Colors.green : Colors.red,
              ),
            )
          ) : GestureDetector(
            onTap: positionController.updateResizingMode(),
            onScaleStart: (details) {
              positionController.updateInitialScale();
            },
            onScaleUpdate: (details) {
              positionController.updateScaleFactor(details.scale);
            },
            child: Container(
              color: resizingMode ? Colors.green : Colors.red,
              height: size,
              width: size,
            ),
          ),
        );
      },
    );
  }
}
