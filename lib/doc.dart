import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf_image_renderer/pdf_image_renderer.dart';
import 'package:get/get.dart';
import 'image_controller.dart';
import 'overlayedWidget.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class OpenDocument extends StatefulWidget {
  const OpenDocument({
    Key? key,
  }) : super(key: key);

  @override
  State<OpenDocument> createState() => _OpenDocumentState();
}

class _OpenDocumentState extends State<OpenDocument> {
  var pdfImage;
  bool pdfIsPicked = false;
  bool signatureIsAdded = false;
  final imageController = Get.put(ImageController());

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
      pdfImage = img;
      pdfIsPicked = true;
    });
  }

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
                              Image(
                                image: MemoryImage(pdfImage),
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
                      onPressed: () => exportPdf(globalKey),
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

Future<Uint8List?> captureWidget(globalKey) async {
  try {
    final RenderRepaintBoundary boundary = globalKey.currentContext.findRenderObject();
    final ui.Image image = await boundary.toImage();
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List? pngBytes = byteData?.buffer.asUint8List();
    return pngBytes;
  } catch (exception) {throw const FormatException(); }
}

void exportPdf(globalKey) async {
  final Uint8List imageBytes;
  imageBytes = (await captureWidget(globalKey))!;
  final pdf = pw.Document();
  pdf.addPage(
      pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(pw.MemoryImage(imageBytes)),
            );
          }
      )
  );
  Uint8List savedPdf = await pdf.save();

  final output = await getTemporaryDirectory();
  var filePath = "${output.path}/example.pdf";
  final file = File(filePath);
  await file.writeAsBytes(savedPdf);
  await Share.shareXFiles([XFile(filePath)]);
}