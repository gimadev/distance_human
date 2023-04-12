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

typedef Users = Map<Object?, Object?>;

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
  final _geolocationPlugin = Geolocation();
  late SharedPreferences prefs;
  Users? users;

  String get uuid {
    if (prefs.containsKey('uuid')) {
      return prefs.getString('uuid')!;
    } else {
      var userRef = ref.push();
      prefs.setString('uuid', userRef.key!);
      return userRef.key!;
    }
  }

  Future<void> initServices() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    ref = FirebaseDatabase.instance.ref("users");

    prefs = await SharedPreferences.getInstance();

    initSender();

    listen();
  }

  void initSender() {
    Timer.periodic(const Duration(seconds: 20), updateLocation);
  }

  void listen() {
    ref.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.exists) {
        setState(() {
          users = event.snapshot.value as Users;
        });
      }
    });
  }

  Future<void> updateLocation(timer) async {
    var location = await getLocation();

    if (location != null) {
      await sendLocation(location);
    }
  }

  Future<void> sendLocation(LocationType location) async {
    var distance = double.parse(location['distance'] as String);

    if (distance > 10) {
      var lat = double.parse(location['lat'] as String);
      var lng = double.parse(location['lng'] as String);

      await ref.child(uuid).update({"lat": lat, "lng": lng});
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<LocationType?> getLocation() async {
    LocationType? location;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      location = await _geolocationPlugin.getLocation();
    } on PlatformException catch (_) {
      //location = 'Failed to get location.';
    }

    return location;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Distance human'),
        ),
        body: getBody(context),
      ),
    );
  }

  Widget getBody(BuildContext context) {
    if (users != null) {
      return body(context);
    } else {
      return initBody(context);
    }
  }

  Widget initBody(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUuid(), // a previously-obtained Future<String> or null
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
            )
          ];
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

  Widget body(BuildContext context) {
    var children = <Widget>[];

    users?.forEach((key, value) {
      late Widget w;

      if (key == uuid) {
        w = ListTile(
            contentPadding: const EdgeInsets.all(15),
            leading: const Icon(
              Icons.location_on_sharp,
              color: Colors.blue,
              size: 60,
            ),
            title: Text('UUID: $key'),
            tileColor: Colors.orange);
      } else {
        w = ListTile(
            contentPadding: const EdgeInsets.all(15),
            leading: const Icon(
              Icons.location_on_sharp,
              color: Colors.blue,
              size: 60,
            ),
            title: Text('UUID: $key'),
            subtitle: const Text('дистанция 50 км'),
            tileColor: Colors.orange);
      }

      children.add(w);
    });

    return ListView(children: children);
  }

  Future<String> _getUuid() async {
    await initServices();
    return uuid;
  }
}
