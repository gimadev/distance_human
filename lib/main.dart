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
  runApp(const MyApp());
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

    initFirebase();
    //initTimer();
  }

  Future<void> initFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    ref = FirebaseDatabase.instance.ref("users");
  }

  void initTimer() {
    Timer.periodic(Duration(seconds: 5), periodic);
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

  void registerHandler() {

  }

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
        body: getBody(),
      ),
    );
  }

  Widget getBody() {
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
}
