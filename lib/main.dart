import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:syncfusion_flutter_sliders/sliders.dart';
//import 'package:multi_select_flutter/multi_select_flutter.dart';
//import 'package:flutter/services.dart';
//import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

void main() {
  runApp(const MyApp());
}

class Imgfilterobj {
  final String gscale1 =
      "\$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/|()1{}[]?-_+~<>i!lI;:,\"^`'. ";

  final String gscale2 = '@%#*+=-:. ';

  final String gscale3 = "BWMoahkbdpqwmZOQLCJUYXzcvunxrjftilI ";

  final List<int> rainbow = [
    0Xffd30094,
    0Xff82004b,
    0Xffff0000,
    0Xff00ff00,
    0Xff00ffff,
    0Xff007fff,
    0Xff0000ff
  ];

  Uint8List? bytes;
  double? _vacom;
  double? _vablur;
  Map<String, bool>? filters;
  Map<String, bool>? brc;
  Map<String, bool>? fonts;
  Map<String, bool>? symbols;
  Map<String, bool>? type;

  Imgfilterobj(
    this.bytes,
    double _vacom,
    double _vablur,
    this.filters,
    this.brc,
    this.fonts,
    this.symbols,
    this.type,
  ) {
    this._vacom = _vacom;
    this._vablur = _vablur;
  }
}

Uint8List Photo_Hash(Imgfilterobj imgfobj) {
  img.Image? photo;

  photo = img.decodeImage(imgfobj.bytes!);

  int height = photo!.height;

  int width = photo.width;

  photo = img.copyResize(photo, width: (width * imgfobj._vacom!.round()));

  height = photo.height;

  width = photo.width;

  List<int> photodata = photo.data;

  img.gaussianBlur(photo, imgfobj._vablur!.round());

  var fillcolor = img.getColor(255, 255, 255);

  if (imgfobj.brc!['black'] == true) {
    fillcolor = img.getColor(0, 0, 0);
  } else if (imgfobj.brc!['red'] == true) {
    fillcolor = img.getColor(255, 0, 0);
  } else if (imgfobj.brc!['green'] == true) {
    fillcolor = img.getColor(0, 255, 0);
  } else if (imgfobj.brc!['blue'] == true) {
    fillcolor = img.getColor(0, 0, 255);
  }

  img.BitmapFont drawfonts = img.arial_14;

  int fontindex = 12;

  if (imgfobj.fonts!['24 px'] == true) {
    drawfonts = img.arial_24;

    fontindex = 22;
  }

  String gscale = imgfobj.gscale1;

  int gscalelen = gscale.length - 1;

  if (imgfobj.symbols!['only symbols'] == true) {
    gscale = imgfobj.gscale2;

    gscalelen = gscale.length - 1;
  } else if (imgfobj.symbols!['only letters'] == true) {
    gscale = imgfobj.gscale3;

    gscalelen = gscale.length - 1;
  }

  img.Image imageg = img.Image(width * fontindex, height * fontindex);

  img.fill(imageg, fillcolor);

  //
  //
  //
  //

  if ((imgfobj.filters!['Normal colors'] == true) ||
      (imgfobj.filters!['sepia'] == true)) {
    if (imgfobj.filters!['sepia'] == true) {
      photo = img.sepia(photo, amount: 1);
      photodata = photo.data;
    }

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        //get pixle colors

        int red = photodata[i * width + j] & 0xff;
        int green = (photodata[i * width + j] >> 8) & 0xff;
        int blue = (photodata[i * width + j] >> 16) & 0xff;
        int alpha = (photodata[i * width + j] >> 24) & 0xff;

        //cal avg
        double avg = (blue + red + green + alpha) / 4;

        var k = gscale[((avg * gscalelen) / 255).round()];

        img.drawString(imageg, drawfonts, j * fontindex, i * fontindex, k,
            color: photodata[i * width + j]);
      }
    }
  }

  if ((imgfobj.filters!['photo hash 1'] == true) ||
      (imgfobj.filters!['photo hash 2'] == true) ||
      (imgfobj.filters!['photo hash 3'] == true)) {
    ///
    ////
    ///
    ///
    if (imgfobj.filters!['photo hash 1'] == true) {
      for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
          //get pixle colors

          int red = photodata[i * width + j] & 0xff;
          int green = (photodata[i * width + j] >> 8) & 0xff;
          int blue = (photodata[i * width + j] >> 16) & 0xff;
          int alpha = (photodata[i * width + j] >> 24) & 0xff;

          //cal avg
          double avg = (blue + red + green + alpha) / 4;

          var k = gscale[((avg * gscalelen) / 255).round()];

          img.drawString(imageg, drawfonts, j * fontindex, i * fontindex, k,
              color: imgfobj.rainbow[(i * width + j) % 7]);
        }
      }
    } else {
      var rainbow0 = imgfobj.rainbow;
      if (imgfobj.filters!['photo hash 3'] == true) {
        rainbow0 = imgfobj.rainbow.reversed.toList();
      }
      for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
          //get pixle colors

          int red = photodata[i * width + j] & 0xff;
          int green = (photodata[i * width + j] >> 8) & 0xff;
          int blue = (photodata[i * width + j] >> 16) & 0xff;
          int alpha = (photodata[i * width + j] >> 24) & 0xff;

          //cal avg
          double avg = (blue + red + green + alpha) / 4;

          var k = gscale[((avg * gscalelen) / 255).round()];

          img.drawString(imageg, drawfonts, j * fontindex, i * fontindex, k,
              color: rainbow0[((avg * 6) / 255).round()]);
        }
      }
    }
  }

  if ((imgfobj.filters!['Grey scale'] == true) ||
      (imgfobj.filters!['green text'] == true)) {
    var printcolor = 0Xff000000;
    if (imgfobj.filters!['green text'] == true) {
      printcolor = 0Xff26F64A;
    }

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        //get pixle colors

        int red = photodata[i * width + j] & 0xff;
        int green = (photodata[i * width + j] >> 8) & 0xff;
        int blue = (photodata[i * width + j] >> 16) & 0xff;
        int alpha = (photodata[i * width + j] >> 24) & 0xff;

        //cal avg
        double avg = (blue + red + green + alpha) / 4;

        var k = gscale[((avg * gscalelen) / 255).round()];

        img.drawString(imageg, drawfonts, j * fontindex, i * fontindex, k,
            color: printcolor);
      }
    }
  }

  return Uint8List.fromList(img.encodePng(imageg));
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

  Uint8List? imagebytes;
  final String gscale1 =
      "\$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/|()1{}[]?-_+~<>i!lI;:,\"^`'. ";

  final String gscale2 = '@%#*+=-:. ';

  final String gscale3 = "BWMoahkbdpqwmZOQLCJUYXzcvunxrjftilI ";

  String name = 'name ';

  final List<int> rainbow = [
    0Xffd30094,
    0Xff82004b,
    0Xffff0000,
    0Xff00ff00,
    0Xff00ffff,
    0Xff007fff,
    0Xff0000ff
  ];

  bool prograss = false;
  bool done = false;

  double _valuecom = 0.5;

  double _valueblur = 0.0;

  Map<String, bool> filtersmap = {
    'Grey scale': true,
    'Normal colors': false,
    'sepia': false,
    'green text': false,
    'photo hash 1': false,
    'photo hash 2': false,
    'photo hash 3': false,
  };

  Map<String, bool> typemap = {
    'image': true,
    'text': false,
  };

  Map<String, bool> brcmap = {
    'white': true,
    'black': false,
    'red': false,
    'green': false,
    'blue': false
  };

  Map<String, bool> fontmap = {'14 px': true, '24 px': false};

  Map<String, bool> symbolsmap = {
    'letters and symbols': true,
    'only symbols': false,
    'only letters': false
  };

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
    var imgfobj = Imgfilterobj(imagebytes!, _valuecom, _valueblur, filtersmap,
        brcmap, fontmap, symbolsmap, typemap);

    print(imgfobj.toString());
    imagebytes = await compute(Photo_Hash, imgfobj);
    setState(() => {});
  }

  @override
  Widget build(BuildContext context) {
    var typeList = typemap.keys
        .toList()
        .map<ChoiceChip>(
          (s) => ChoiceChip(
            label: Text(s),
            selected: typemap[s]!,
            padding: const EdgeInsets.all(3.0),
            selectedColor: Colors.green,
            backgroundColor: Colors.black.withOpacity(0.7),
            onSelected: (bool selected) {
              typemap.forEach((k, v) => typemap[k] = false);
              typemap[s] = true;
              setState(() => {});
            },
          ),
        )
        .toList();

    Map<Map, String> chipname = {
      filtersmap: 'Hash Filters',
      brcmap: 'Backround color',
      fontmap: 'Font size',
      symbolsmap: 'Symbols'
    };

    var fliters = [filtersmap, fontmap, brcmap, symbolsmap]
        .map<Column>((a) => Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  chipname[a]!,
                  style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                Wrap(
                    spacing: 3,
                    runSpacing: 3,
                    children: a.keys
                        .toList()
                        .map<ChoiceChip>(
                          (s) => ChoiceChip(
                            label: Text(
                              s,
                              style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            padding: const EdgeInsets.all(3.0),
                            selectedColor: Colors.blue,
                            backgroundColor: Colors.black.withOpacity(0.7),
                            selected: a[s]!,
                            onSelected: (bool selected) {
                              a.forEach((k, v) => a[k] = false);
                              setState(() => {a[s] = true});
                            },
                          ),
                        )
                        .toList()),
              ],
            ))
        .toList();

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: const Color(0xffdbe9f4),
      body: SingleChildScrollView(
        child: Center(
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
                margin: const EdgeInsets.all(10.0),
                child: ClipRect(
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(25)),
                            color: Colors.black.withOpacity(0.6)),
                        child: SizedBox(
                          width: double.infinity,
                          child: Expanded(
                            child: imagebytes == null
                                ? Center(
                                    child: MaterialButton(
                                        height: 30.0,
                                        color: Colors.blue,
                                        child: const Text(
                                            "Pick Image from Gallery",
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontWeight: FontWeight.bold)),
                                        onPressed: () {
                                          pickImage();
                                        }),
                                  )
                                : Stack(
                                    alignment:
                                        AlignmentDirectional.bottomCenter,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                      ),
                                      Container(
                                          child: prograss == false
                                              ? Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.memory(
                                                      imagebytes!,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      alignment:
                                                          Alignment.center,
                                                    ),
                                                    MaterialButton(
                                                        height: 30.0,
                                                        color: Colors.blue,
                                                        child: const Text(
                                                            "Chang Image ",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white70,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        onPressed: () {
                                                          pickImage();
                                                        }),
                                                    Column(
                                                      children: [
                                                        // ignore: prefer_const_constructors
                                                        Text(
                                                          "output type",
                                                          style: const TextStyle(
                                                              color: Colors
                                                                  .white60,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Wrap(
                                                          spacing: 3,
                                                          runSpacing: 3,
                                                          children: typeList,
                                                        ),
                                                      ],
                                                    ),
                                                    TextField(
                                                      decoration:
                                                          const InputDecoration(
                                                        border:
                                                            OutlineInputBorder(),
                                                        hintText:
                                                            'output filen ame ',
                                                      ),
                                                      onChanged: (text) {
                                                        name = text;
                                                        setState(() => {});
                                                      },
                                                    ),
                                                    Column(
                                                      children: [
                                                        const Text(
                                                          "comration scale",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white60,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(3.0),
                                                          child: SfSlider(
                                                            min: 0.1,
                                                            max: 1.0,
                                                            value: _valuecom,
                                                            showTicks: true,
                                                            showLabels: true,
                                                            enableTooltip: true,
                                                            minorTicksPerInterval:
                                                                1,
                                                            onChanged: (dynamic
                                                                value) {
                                                              setState(() {
                                                                _valuecom =
                                                                    value;
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        const Text(
                                                          "blur index",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white60,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(3.0),
                                                          child: SfSlider(
                                                            min: 0.0,
                                                            max: 10.0,
                                                            value: _valueblur,
                                                            interval: 1.0,
                                                            showTicks: true,
                                                            showLabels: true,
                                                            enableTooltip: true,
                                                            minorTicksPerInterval:
                                                                1,
                                                            onChanged: (dynamic
                                                                value) {
                                                              setState(() {
                                                                _valueblur =
                                                                    value;
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      children: fliters,
                                                    ),
                                                    MaterialButton(
                                                        height: 50.0,
                                                        color: Colors.blue,
                                                        child: const Text(
                                                            "Convert",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white70,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        onPressed: () {
                                                          converthash();
                                                        }),
                                                  ],
                                                )
                                              : Container(
                                                  child:
                                                      CircularProgressIndicator(),
                                                )),
                                    ],
                                  ),
                          ),
                        ),
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
