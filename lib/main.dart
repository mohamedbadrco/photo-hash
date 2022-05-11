import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
//import 'package:flutter/services.dart';
//import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

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
  Uint8List? imagebytes;
  String gscale1 =
      "\$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\|()1{}[]?-_+~<>i!lI;:,\"^`'.";

  String gscale2 = '@%#*+=-:. ';

  double _valuecom = 0.5;

  double _valueblur = 0.0;

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      setState(() => this.image = image);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
    imagebytes = await image!.readAsBytes();
    setState(() => {});
  }

  Future converthash() async {
    photo = img.decodeImage(imagebytes!);

    List<int> photodata = photo!.data;

    int height = photo!.height;

    int width = photo!.width;

    img.Image imageg = img.Image(width * 14, height * 14);

    img.fill(imageg, img.getColor(255, 255, 255));

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        //get pixle colors

        int red = photodata[i * width + j] & 0xff;
        int green = (photodata[i * width + j] >> 8) & 0xff;
        int blue = (photodata[i * width + j] >> 16) & 0xff;
        int alpha = (photodata[i * width + j] >> 24) & 0xff;

        //cal avg
        double avg = (blue + red + green + alpha) / 4;

        var k = gscale2[((avg * 9) / 255).round()];

        img.drawChar(imageg, img.arial_14, j * 14, i * 14, k,
            color: 0Xff000000);
      }
    }

    imagebytes = Uint8List.fromList(img.encodePng(imageg));
    setState(() => {});
    print('done');
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
              width: double.infinity,
              child: imagebytes == null
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
                  : Stack(
                      alignment: AlignmentDirectional.bottomCenter,
                      children: [
                        Container(
                            width: MediaQuery.of(context).size.width,
                            child: Image.memory(
                              imagebytes!,
                              width: MediaQuery.of(context).size.width,
                              alignment: Alignment.center,
                            )),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(10.0),
                              child: ClipRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 10.0, sigmaY: 10.0),
                                  child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(25)),
                                          color: Colors.black.withOpacity(0.5)),
                                      child: Column(
                                        children: [
                                          MaterialButton(
                                              height: 30.0,
                                              color: Colors.blue,
                                              child: const Text("Chang Image ",
                                                  style: TextStyle(
                                                      color: Colors.white70,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              onPressed: () {
                                                pickImage();
                                              }),
                                          SfSlider(
                                            min: 0.1,
                                            max: 1.0,
                                            value: _valuecom,
                                            showTicks: true,
                                            showLabels: true,
                                            enableTooltip: true,
                                            minorTicksPerInterval: 1,
                                            onChanged: (dynamic value) {
                                              setState(() {
                                                _valuecom = value;
                                              });
                                            },
                                          ),
                                          SfSlider(
                                            min: 0.0,
                                            max: 10.0,
                                            value: _valueblur,
                                            interval: 1.0,
                                            showTicks: true,
                                            showLabels: true,
                                            enableTooltip: true,
                                            minorTicksPerInterval: 1,
                                            onChanged: (dynamic value) {
                                              setState(() {
                                                _valueblur = value;
                                              });
                                            },
                                          ),
                                          MultiSelectChipDisplay(
                                            items: _filtersnames
                                                .map((e) =>
                                                    MultiSelectItem(e, e))
                                                .toList(),
                                            onTap: (value) {
                                              setState(() {
                                                _selectedAnimals.remove(value);
                                              });
                                            },
                                          ),
                                          MaterialButton(
                                              height: 50.0,
                                              color: Colors.blue,
                                              child: const Text("Convert",
                                                  style: TextStyle(
                                                      color: Colors.white70,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              onPressed: () {
                                                converthash();
                                              }),
                                        ],
                                      )),
                                ),
                              ),
                            ),
                          ],
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
