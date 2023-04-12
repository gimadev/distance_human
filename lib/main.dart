import 'dart:ffi';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:geolocation/geolocation.dart';
import 'package:geolocation/geolocation_platform_interface.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late DatabaseReference ref;
  late TextEditingController _controller;
  var _nameReady = false;
  final _geolocationPlugin = Geolocation();
  late SharedPreferences prefs;

  String get uuid {
    if (prefs.containsKey('uuid')) {
      return prefs.getString('uuid')!;
    } else {
      var uuid = const Uuid();
      var uuidStr = uuid.v1();
      prefs.setString('uuid', uuidStr);
      return uuidStr;
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();

    _controller.addListener(() {
      final text = _controller.text.toLowerCase();

      if (text.length > 2) {
        setState(() {
          _nameReady = true;
        });
      } else {
        setState(() {
          _nameReady = false;
        });
      }
    });

    //initServices();
    //initTimer();
  }

  Future<void> initServices() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    ref = FirebaseDatabase.instance.ref("users");

    prefs = await SharedPreferences.getInstance();
  }

  void initTimer() {
    Timer.periodic(const Duration(seconds: 5), periodic);
  }

  Future<void> periodic(timer) async {
    var location = await getLocation();

    if (location != null) {
      var distance = double.parse(location['distance'] as String);

      // if (distance > 10) {
      //   print("little2");
      // }

      await ref.set({
        "name": "John",
        "age": 18,
        "address": {"line1": "100 Mountain View"}
      });
    }
  }

  Widget registerButton() {
    if (_nameReady) {
      return ElevatedButton(
        onPressed: registerHandler,
        child: const Text('Регистрация'),
      );
    } else {
      return const ElevatedButton(
        onPressed: null,
        child: Text('Регистрация'),
      );
    }
  }

  void registerHandler() {}

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<LocationType?> getLocation() async {
    LocationType? location;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      location = await _geolocationPlugin.getLocation();
    } on PlatformException catch (e) {
      //location = 'Failed to get location.';
    }

    return location;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Distance human'),
        ),
        body: getBody(context),
      ),
    );
  }

  Widget getBody(BuildContext context) {
    return spinner();
  }

  Widget registerForm() {
    return Center(
      child: Column(children: [
        Expanded(
          flex: 4,
          child: Row(),
        ),
        Expanded(
          flex: 1,
          child: Row(children: [
            Expanded(
              flex: 1,
              child: Column(),
            ),
            Expanded(
              flex: 8,
              child: TextField(
                  controller: _controller,
                  style: const TextStyle(fontSize: 17, fontFamily: "Verdana"),
                  decoration: const InputDecoration(
                      labelText: 'Имя', border: OutlineInputBorder())),
            ),
            Expanded(
              flex: 1,
              child: Column(),
            )
          ]),
        ),
        Expanded(
          flex: 1,
          child: Row(children: [
            Expanded(
              flex: 1,
              child: Column(),
            ),
            Expanded(
              flex: 8,
              child: registerButton(),
            ),
            Expanded(
              flex: 1,
              child: Column(),
            ),
          ]),
        ),
        Expanded(
          flex: 4,
          child: Row(),
        )
      ]),
    );
  }

  Widget spinner() {
    return FutureBuilder<String>(
      future: _calculation(), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        List<Widget> children;

        if (snapshot.hasData) {

          children = <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 60,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(
                child: Text('UUID: ${snapshot.data}'),
              ),
            ),
          ];

          // children = [
          //   ListTile(
          //     contentPadding: const EdgeInsets.all(15),
          //     leading: const Icon(
          //       Icons.location_on_sharp,
          //       color: Colors.blue,
          //       size: 60,
          //     ),
          //     title: Text('UUID: ${snapshot.data!}'),
          //     subtitle: const Text('дистанция 50 км'),
          //     tileColor: Colors.orange
          //   ),
          //   ListTile(
          //     contentPadding: const EdgeInsets.all(15),
          //     leading: const Icon(
          //       Icons.location_on_sharp,
          //       color: Colors.blue,
          //       size: 60,
          //     ),
          //     title: Text('UUID: ${snapshot.data!}'),
          //     subtitle: const Text('дистанция 50 км'),
          //     tileColor: Colors.orange
          //   ),
          // ];

        } else if (snapshot.hasError) {
          children = <Widget>[
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Ошибка: ${snapshot.error}'),
            ),
          ];
        } else {
          children = const <Widget>[
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Загрузка данных'),
            ),
          ];
        }

        return ListView(children: children);
      },
    );
  }

  Future<String> _calculation() async {
    await initServices();
    return uuid;
  }
}
