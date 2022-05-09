import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:universal_io/io.dart' as universal;
import 'package:flutter/rendering.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.green),
      home: const MyHomePage(title: '#PHOTO HASH'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  XFile? image;
  img.Image? photo;

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      setState(() => this.image = image);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
    final Uint8List bytes = await image!.readAsBytes();
    photo = img.decodeImage(bytes);
  }

  Future converthash() async {
    List<int> photodata = photo!.data;
    int leng = photodata.length;

    int height = photo!.height;
    int width = photo!.width;

    img.Image image = img.Image(width, height);

    img.fill(image, img.getColor(255, 255, 255));

    int index_x = 0;
    for (int i = 0; i < height; i++) {
      int index_y = 0;
      for (int j = 0; j < width; j++) {
        int blue = (photodata[i * height + j] >> 16) & 0xff;
        int red = photodata[i * height + j] & 0xff;
        int green = (photodata[i * height + j] >> 8) & 0xff;
        int alpha = (photodata[i * height + j] >> 24) & 0xff;
        double avg = (blue + red + green + alpha) / 4;

        img.drawChar(image, img.arial_14, index_x, index_y, 'H');
        index_y += 8;
      }
      index_x += 8;
    }

    File('test.png').writeAsBytesSync(img.encodePng(image));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: const Color(0xffdbe9f4),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(2.0),
                width: double.infinity,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.blueGrey),
                height: 70.0,
                child: Row(
                  children: const [
                    Text(
                      "#PHOTO HASH",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                )),
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(10.0),
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.blueGrey),
              width: double.infinity,
              height: 350.0,
              child: image == null
                  ? MaterialButton(
                      height: 30.0,
                      color: Colors.blue,
                      child: const Text("Pick Image from Gallery",
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold)),
                      onPressed: () {
                        pickImage();
                      })
                  : Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: kIsWeb
                              ? Image.network(
                                  image!.path,
                                  height: 200.0,
                                  width: 200,
                                )
                              : Image.file(
                                  File(image!.path),
                                  height: 200.0,
                                  width: 200,
                                ),
                        ),
                        MaterialButton(
                            height: 30.0,
                            color: Colors.blue,
                            child: const Text("Pick Image from Gallery",
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold)),
                            onPressed: () {
                              pickImage();
                            }),
                      ],
                    ),
            ),
            MaterialButton(
                height: 50.0,
                color: Colors.blue,
                child: const Text("Convert",
                    style: TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.bold)),
                onPressed: () {
                  converthash();
                })
          ],
        ),
      ),
    );
  }
}
