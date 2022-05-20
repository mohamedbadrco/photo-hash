import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:syncfusion_flutter_sliders/sliders.dart';
// ignore: unnecessary_import
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import 'package:image/image.dart' as img;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class Imgfilterobj {
  final String gscale1 =
      "\$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/|()1{}[]?-_+~<>i!lI;:,\"^`'. ";

  final String gscale2 = '@%#*+=-:. ';

  final String gscale3 = "BWMoahkbdpqwmZOQLCJUYXzcvunxrjftilI ";

  final List<int> rainbow = [
    0X00d30094,
    0X0082004b,
    0X00ff0000,
    0X0000ff00,
    0X0000ffff,
    0X00007fff,
    0X000000ff
  ];

  final Map<String, int> singlecolormap = {
    'Violet symbols': 0X00d30094,
    'Indigo symbols': 0X0082004b,
    'Blue symbols': 0X00ff0000,
    'Green symbols': 0X0000ff00,
    'Yellow symbols': 0X0000ffff,
    'Orange symbols': 0X00007fff,
    'Red symbols': 0X000000ff,
    'Grey scale': 0X00000000,
    'terminal green text': 0X0026F64A
  };

  Uint8List? bytes;
  double? _vacom;
  double? _vablur;
  Map<String, bool>? filters;
  Map<String, bool>? brc;
  Map<String, bool>? fonts;
  Map<String, bool>? symbols;

  Imgfilterobj(
    this.bytes,
    double _vacom,
    double _vablur,
    this.filters,
    this.brc,
    this.fonts,
    this.symbols,
  ) {
    this._vacom = _vacom;
    this._vablur = _vablur;
  }
}

class Imgfilterobjtxt {
  final String gscale1 =
      "\$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/|()1{}[]?-_+~<>i!lI;:,\"^`'. ";

  final String gscale2 = '@%#*+=-:. ';

  final String gscale3 = "BWMoahkbdpqwmZOQLCJUYXzcvunxrjftilI ";
  Uint8List? bytes;
  Map<String, bool>? symbols;
  int clos = 100;

  Imgfilterobjtxt(this.bytes, this.clos, this.symbols) {
    // Ignored
  }
}

List<String> photohashtxt(Imgfilterobjtxt imgfobjtxt) {
  List<String> res = [''];

  img.Image? photo;

  photo = img.decodeImage(imgfobjtxt.bytes!);

  photo = img.copyResize(photo!, width: imgfobjtxt.clos);

  int height = photo.height;

  int width = photo.width;

  List<int> photodata = photo.data;

  String gscale = imgfobjtxt.gscale1;

  int gscalelen = gscale.length - 1;

  if (imgfobjtxt.symbols!['only symbols'] == true) {
    gscale = imgfobjtxt.gscale2;

    gscalelen = gscale.length - 1;
  } else if (imgfobjtxt.symbols!['only letters'] == true) {
    gscale = imgfobjtxt.gscale3;

    gscalelen = gscale.length - 1;
  }

  for (int i = 0; i < height; i++) {
    String row = '';
    for (int j = 0; j < width; j++) {
      //get pixle colors

      int red = photodata[i * width + j] & 0xff;
      int green = (photodata[i * width + j] >> 8) & 0xff;
      int blue = (photodata[i * width + j] >> 16) & 0xff;
      int alpha = (photodata[i * width + j] >> 24) & 0xff;

      //cal avg
      double avg = (blue + red + green + alpha) / 4;

      String k = gscale[((avg * gscalelen) / 255).round()];
      row = row + k;
    }
    res.add(row);
  }

  // List<String> res1 = res;

  return res;
}

Uint8List photohash(Imgfilterobj imgfobj) {
  img.Image? photo;

  photo = img.decodeImage(imgfobj.bytes!);

  int height = photo!.height;

  int width = photo.width;

  photo = img.copyResize(photo, width: ((width * imgfobj._vacom!).round()));

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

          //cal avg
          double avg = (blue + red + green) / 3;

          var k = gscale[((avg * gscalelen) / 255).round()];

          int alpha = (((photodata[i * width + j] >> 24) & 0xff) << 24);

          img.drawString(imageg, drawfonts, j * fontindex, i * fontindex, k,
              color: (imgfobj.rainbow[(i * width + j) % 7] ^ alpha));
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

          //cal avg
          double avg = (blue + red + green) / 3;

          var k = gscale[((avg * gscalelen) / 255).round()];
          int alpha = (((photodata[i * width + j] >> 24) & 0xff) << 24);

          img.drawString(imageg, drawfonts, j * fontindex, i * fontindex, k,
              color: (rainbow0[((avg * 6) / 255).round()]) ^ alpha);
        }
      }
    }
  }
  List<String> singlecolor = imgfobj.singlecolormap.keys.toList();

  for (int k = 0; k < singlecolor.length; k++) {
    if (imgfobj.filters![singlecolor[k]] == true) {
      var printcolor = imgfobj.singlecolormap[singlecolor[k]];

      if ((singlecolor[k] == 'Grey scale') && imgfobj.brc!['black'] == true) {
        printcolor = 0X00ffffff;
      }

      for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
          //get pixle colors

          int red = photodata[i * width + j] & 0xff;
          int green = (photodata[i * width + j] >> 8) & 0xff;
          int blue = (photodata[i * width + j] >> 16) & 0xff;

          //cal avg
          double avg = (blue + red + green) / 3;

          var k = gscale[((avg * gscalelen) / 255).round()];

          int alpha = (((photodata[i * width + j] >> 24) & 0xff) << 24);

          img.drawString(imageg, drawfonts, j * fontindex, i * fontindex, k,
              color: (printcolor! ^ alpha));
        }
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
      title: '#PHOTO HASH',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const MyHomePage(title: '#PHOTO HASH'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

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

  String name = '';

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

  int? columns = 100;

  double _valuecom = 0.5;

  double _valueblur = 0.0;

  Map<String, bool> filtersmap = {
    'Grey scale': true,
    'Normal colors': false,
    'sepia': false,
    'terminal green text': false,
    'photo hash 1': false,
    'photo hash 2': false,
    'photo hash 3': false,
    'Violet symbols': false,
    'Indigo symbols': false,
    'Blue symbols': false,
    'Green symbols': false,
    'Yellow symbols': false,
    'Orange symbols': false,
    'Red symbols': false,
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

  // ignore: unused_field

  int lent = 0;
  int lenc = 0;

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      setState(() => this.image = image);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Failed to pick image: $e');
      }
    }
    imagebytes = await image!.readAsBytes();
    setState(() => {});
  }

  Future converthash() async {
    name = _controller.value.text;
    if (typemap['image'] == true) {
      // ignore: unused_local_variable
      var imgfobj = Imgfilterobj(imagebytes!, _valuecom, _valueblur, filtersmap,
          brcmap, fontmap, symbolsmap);

      prograss = true;
      setState(() => {});

      imagebytes = await compute(photohash, imgfobj);

      if (!kIsWeb) {
        Directory appDocDir = await getApplicationDocumentsDirectory();
        // ignore: unused_local_variable
        String appDocPath = appDocDir.path;
        File f = File('$appDocDir/$name.png');
        await f.writeAsBytes(imagebytes!);
      }

      done = true;
      prograss = false;
      setState(() => {});
    } else if (typemap['text'] == true) {
      var imgfobjtxt = Imgfilterobjtxt(imagebytes!, columns!, symbolsmap);

      prograss = true;

      setState(() => {});

      List<String> text = await compute(photohashtxt, imgfobjtxt);

      int lentxt = text.length;

      if (!kIsWeb) {
        Directory appDocDir = await getApplicationDocumentsDirectory();
        // ignore: unused_local_variable
        String appDocPath = appDocDir.path;

        File f = File('$appDocDir/$name.txt');

        for (int i = 0; i < lentxt; i++) {
          await f.writeAsString(text[i], mode: FileMode.append);
        }
      }

      done = true;

      prograss = false;

      imagebytes = null;
      setState(() => {lent = lentxt, lenc = text[1].length});
    }
  }

  final Uri _url = Uri.parse('https://flutter.dev');

  void _launchUrl() async {
    if (!await launchUrl(_url)) throw 'Could not launch $_url';
  }

  final _controller = TextEditingController();

  String? get _errorText {
    // at any time, we can get the text from _controller.value.text
    final text = _controller.value.text;

    // Note: you can do your own custom validation here
    // Move this logic this outside the widget for more testable code
    if (text.isEmpty) {
      return 'Can\'t be empty';
    }
    if (text.length < 4) {
      return 'Too short';
    }
    // return null if the text is valid
    return null;
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

    var symbolsList = symbolsmap.keys
        .toList()
        .map<ChoiceChip>(
          (s) => ChoiceChip(
            label: Text(s),
            selected: symbolsmap[s]!,
            padding: const EdgeInsets.all(3.0),
            selectedColor: Colors.green,
            backgroundColor: Colors.black.withOpacity(0.7),
            onSelected: (bool selected) {
              symbolsmap.forEach((k, v) => symbolsmap[k] = false);
              symbolsmap[s] = true;
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

    TextStyle defaultStyle =
        const TextStyle(color: Colors.grey, fontSize: 16.0);
    TextStyle linkStyle = const TextStyle(color: Colors.blue);

    var links1 = Container(
        margin: const EdgeInsets.all(5.0),
        padding: const EdgeInsets.all(40.0),
        child: RichText(
          text: TextSpan(
            style: defaultStyle,
            children: <TextSpan>[
              const TextSpan(text: 'Support the app by donating '),
              TextSpan(
                  text: 'here',
                  style: linkStyle,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _launchUrl();
                    }),
              const TextSpan(text: ' our by checking out our Asciiart based  '),
              TextSpan(
                  text: 'NFT Collection',
                  style: linkStyle,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _launchUrl();
                    }),
            ],
          ),
        ));

    var links2 = Container(
        margin: const EdgeInsets.all(10.0),
        padding: const EdgeInsets.all(40.0),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.grey, fontSize: 12.0),
            children: <TextSpan>[
              const TextSpan(text: 'Made by '),
              TextSpan(
                  text: 'MB',
                  style: linkStyle,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _launchUrl();
                    }),
            ],
          ),
        ));

    var imageob = Column(
      children: [
        Column(
          children: [
            const Text(
              "comration scale",
              style: TextStyle(
                  color: Colors.white60,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.all(3.0),
              child: SfSlider(
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
            ),
          ],
        ),
        Column(
          children: [
            const Text(
              "blur index",
              style: TextStyle(
                  color: Colors.white60,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.all(3.0),
              child: SfSlider(
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
            ),
          ],
        ),
        Column(
          children: fliters,
        ),
      ],
    );

    var txtob = Column(
      children: [
        const Text(
          '''
Enter the number of columns or the number of charctars per
 line the you want in the output text file''',
          style: TextStyle(
              color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        TextField(
          decoration: const InputDecoration(labelText: "Enter number columns"),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],

          onChanged: (String num) {
            columns = int.parse(num);
            setState(() => {});
          }, // Only numbers can be entered
        ),
        Column(
          children: [
            // ignore: prefer_const_constructors
            Text(
              "Symbols",
              style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 3,
              runSpacing: 3,
              children: symbolsList,
            ),
          ],
        ),
      ],
    );
    var goback = ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: Colors.black.withOpacity(0.6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
          padding: const EdgeInsets.all(0.0)),
      onPressed: () {
        done = false;
        imagebytes = null;
        setState(() => {});
      },
      child: Ink(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 150.0, minHeight: 50.0),
          alignment: Alignment.center,
          child: const Text(
            "Go Back",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
    var mesgtxt = Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          Container(
            height: 50,
            margin: const EdgeInsets.all(5.0),
            padding: const EdgeInsets.all(1.0),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(25)),
                color: Colors.black.withOpacity(0.6)),
            child: Center(
                child: Text('your text was  saved as $name.txt',
                    style: const TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.bold))),
          ),
          links1,
          goback
        ]));
    var mesgimg = Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          Container(
            height: 50,
            margin: const EdgeInsets.all(5.0),
            padding: const EdgeInsets.all(1.0),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(25)),
                color: Colors.black.withOpacity(0.6)),
            child: Center(
                child: Text('your imag was  saved as $name.png',
                    style: const TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.bold))),
          ),
          links1,
          goback
        ]));

    var home = Column(children: [
      Container(
        margin: const EdgeInsets.all(5.0),
        padding: const EdgeInsets.all(40.0),
        child: const Text(
            ''' Photo Hash is an app for making ascii art form images 

Pick an image  choose output type image/text apply filters an then review the results ''',
            style: TextStyle(color: Colors.grey, fontSize: 18.0)),
      ),
      const Spacer(),
      Column(
        children: [
          Container(
            margin: const EdgeInsets.all(15.0),
            child: const Text('pick an image',
                style: TextStyle(color: Colors.grey, fontSize: 18.0)),
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.black54,
                shape: const CircleBorder(), //<-- SEE HERE
                padding: const EdgeInsets.all(20),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white70,
                size: 50.0,
              ),
              onPressed: () {
                pickImage();
              }),
        ],
      ),
      const Spacer(),
      links1,
      links2
    ]);

    var change = ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: Colors.black.withOpacity(0.6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
          padding: const EdgeInsets.all(0.0)),
      onPressed: () {
        pickImage();
      },
      child: Ink(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 150.0, minHeight: 50.0),
          alignment: Alignment.center,
          child: const Text(
            "Change Image ",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
    var convert = ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: Colors.black.withOpacity(0.6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
          padding: const EdgeInsets.all(0.0)),
      onPressed: () {
        converthash();
      },
      child: Ink(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 200.0, minHeight: 50.0),
          alignment: Alignment.center,
          child: const Text(
            "Convert",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );

    var namefiled = ValueListenableBuilder(
      // Note: pass _controller to the animation argument
      valueListenable: _controller,
      builder: (context, TextEditingValue value, __) {
        // this entire widget tree will rebuild every time
        // the controller value changes
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Enter your name',
                  errorText: _errorText,
                ),
                onChanged: (text) {
                  setState(() => {});
                }),
          ],
        );
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xffdbe9f4),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.all(2.0),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: Color(0xffc4c4c4)),
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
                                ? SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height - 90,
                                    child: done == false ? home : mesgtxt)
                                : Column(
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
                                                    Container(
                                                      child: done == false
                                                          ? Column(
                                                              children: [
                                                                change,
                                                                Column(
                                                                  children: [
                                                                    // ignore: prefer_const_constructors
                                                                    Text(
                                                                      "output type",
                                                                      style: const TextStyle(
                                                                          color: Colors
                                                                              .white60,
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                    Wrap(
                                                                      spacing:
                                                                          3,
                                                                      runSpacing:
                                                                          3,
                                                                      children:
                                                                          typeList,
                                                                    ),
                                                                  ],
                                                                ),
                                                                namefiled,
                                                                Container(
                                                                    child: typemap['image'] ==
                                                                            true
                                                                        ? imageob
                                                                        : txtob),
                                                                Container(
                                                                    child: _controller
                                                                            .value
                                                                            .text
                                                                            .isNotEmpty
                                                                        ? convert
                                                                        : Text(
                                                                            'please enter a name',
                                                                            style:
                                                                                defaultStyle,
                                                                          ))
                                                              ],
                                                            )
                                                          : //
                                                          mesgimg,
                                                    ),
                                                  ],
                                                )
                                              : //
                                              SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height -
                                                      90,
                                                  child: Center(
                                                      child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .all(50.0),
                                                          child: const Center(
                                                            child: Center(
                                                              child: Text(
                                                                  'this process might take up to several minutes',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize:
                                                                          18.0)),
                                                            ),
                                                          )),
                                                      SizedBox(
                                                          height: 50,
                                                          child: Column(
                                                            children: const [
                                                              CircularProgressIndicator(),
                                                            ],
                                                          )),
                                                    ],
                                                  )),
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
