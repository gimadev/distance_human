import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:geolocation/geolocation.dart';
import 'package:geolocation/geolocation_platform_interface.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initFirebase();
  }

  Future<void> initFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  String _lat = "Unknown";
  String _lng = "Unknown";
  String _distance = "Unknown";
  String _time = "Unknown";

  final _geolocationPlugin = Geolocation();

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> getLocation() async {
    LocationType? location;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      location = await _geolocationPlugin.getLocation();
    } on PlatformException catch (e) {
      //location = 'Failed to get location.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _lat = "lat: ${location?['lat']}";
      _lng = "lng: ${location?['lng']}";
      _distance = "distance: ${location?['distance']}";
      _time = "time: ${location?['time']}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: getLocation,
                child: const Text('Get Location'),
              ),
              Text(_lat),
              Text(_lng),
              Text(_distance),
              Text(_time),
            ],
          ),
        ),
      ),
    );
  }
}
