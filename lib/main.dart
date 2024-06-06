import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:posz92printer/posz92printer.dart';
import 'package:device_info_plus/device_info_plus.dart';

dynamic _platformVersion = 'Unknown';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Printer test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Printer test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController _text = TextEditingController();

  final deviceInfo = DeviceInfoPlugin();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;
    setState(() {
      _platformVersion = platformVersion;
    });
  }

  showAndroidInfo() {
    return FutureBuilder(
      future: deviceInfo.androidInfo,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        } else if (snapshot.hasData) {
          AndroidDeviceInfo info = snapshot.data!;
          return Column(
            children: [
              item('Android Model', info.model),
              item('Android Brand', info.brand),
              item('Android Device', info.device),
              item('Android Hardware', info.hardware),
              item('Android Host', info.host),
              item('Android ID', info.id),
              item('Android Is Physical', info.isPhysicalDevice.toString()),
              item('Android SDK Int', info.version.sdkInt.toString()),
            ],
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  final printObj = PrinterPosSystem();
  _incrementCounter(textToPrint) async {
    printObj.printText(text: '$textToPrint', alignment: AlignmentPrint.center);
    printObj.printQRCode(text: '$textToPrint', height: 200, width: 200);
    printObj.printLine();
    formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
              child: Column(
            children: [
              Form(
                  key: formKey,
                  child: TextFormField(
                      controller: _text,
                      validator: (val) {
                        return '$val'.isEmpty
                            ? "Saisir le text à imprimer"
                            : null;
                      },
                      decoration: InputDecoration(
                          labelText: 'Enter text to print',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))))),
              showAndroidInfo(),
            ],
          )),
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            _incrementCounter(_text.text);
          }
        },
        tooltip: 'Print',
        child: const Icon(
          Icons.local_print_shop_outlined,
          size: 40,
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

item(String name, String value) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
