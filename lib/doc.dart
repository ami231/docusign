import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'image_controller.dart';
import 'overlayedWidget.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

import 'pdfWidget.dart';
import 'matrix_controller.dart';

class OpenDocument extends StatefulWidget {
  const OpenDocument({
    Key? key,
  }) : super(key: key);

  @override
  State<OpenDocument> createState() => _OpenDocumentState();
}

class _OpenDocumentState extends State<OpenDocument> {
  bool pdfIsPicked = false;
  bool signatureIsAdded = false;
  final imageController = Get.put(ImageController());
  String filePath = '';
  final matrixController = Get.put(MatrixController());
  final GlobalKey globalKey = GlobalKey();
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
                    ? Padding(
                        padding: const EdgeInsets.only(top: 150.0),
                        child: RepaintBoundary(
                          key: globalKey,
                          child: Stack(
                            children: [
                              PdfWidget(
                                filePath: filePath,
                              ),
                              if (signatureIsAdded)
                                OverlayedWidget(
                                  child: Container(
                                    child: imageController.image,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )
                    : IconButton(
                        onPressed: () async {
                          final FilePickerResult? result =
                              await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                          if (result == null) return;
                          final file = result.files.first;
                          setState(() {
                            filePath = file.path!;
                            pdfIsPicked = true;
                          });
                          //rendererPdfImage(file);
                        },
                        icon: const Icon(
                          Icons.add_circle,
                          size: 40.0,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            if (pdfIsPicked)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    if (!signatureIsAdded)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            signatureIsAdded = true;
                          });
                        },
                        child: const Text('insert signature'),
                      ),
                    IconButton(
                      onPressed: () => exportPdf(filePath),
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


void exportPdf(path) async {
  final matrixController = Get.put(MatrixController());
  final imageController = Get.put(ImageController());

  // final template = File(path).readAsBytesSync();
  // final pdf = pw.Document.load(PdfDocumentParserBase(template));

  final pdf = pw.Document();
  pdf.addPage(pw.Page(build: (pw.Context context){return pw.Container();}));


  pdf.editPage(
    0,
    pw.Page(
      build: (pw.Context context) {
        return pw.Stack(
          children: [
            pw.Transform(
              transform: matrixController.currentPosition.value,
              child: pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Container(
                  child: pw.Image(pw.MemoryImage(imageController.imageBytes!))
                )
              ),
            ),
          ],
        );
      },
    ),
  );

  Uint8List savedPdf = await pdf.save();

  final output = await getTemporaryDirectory();
  var filePath = "${output.path}/example.pdf";
  final file = File(filePath);
  await file.writeAsBytes(savedPdf);
  await Share.shareXFiles([XFile(filePath)]);
}
