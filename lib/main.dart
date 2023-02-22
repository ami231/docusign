import 'package:flutter/material.dart';
import 'package:signature/doc.dart';
import 'package:signature/write.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/homePage',
      getPages: [
        GetPage(name: "/homePage", page: ()=> const MyHomePage()),
        GetPage(name: "/writeSignature", page: () => const WriteSignature()),
        GetPage(name: "/openDocument", page: () => OpenDocument()),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () {
                  Get.to(const WriteSignature());
                },
                child: const Text('create signature'),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: ElevatedButton(
            //     onPressed: () async {
            //       var status = await Permission.storage.status;
            //       if (status.isGranted) {
            //         Get.to(const OpenDocument());
            //       } else if (status.isDenied) {
            //         // if (await Permission.storage.request().isGranted){
            //         //   Navigator.pushNamed(context, '/openDocument');
            //         // }
            //         Get.to(const OpenDocument());
            //       } else if (await status.isPermanentlyDenied) {
            //         openAppSettings();
            //       }
            //     },
            //     child: const Text('open document'),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
