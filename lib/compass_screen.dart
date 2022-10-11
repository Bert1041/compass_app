import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({Key? key}) : super(key: key);

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    _listenForPermissionStatus();
  }

  void _listenForPermissionStatus() async {
    final status = await Permission.locationWhenInUse.status;
    setState(() => _permissionStatus = status);
  }

  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();
    setState(() {
      print(status);
      _permissionStatus = status;
      print(_permissionStatus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return (_permissionStatus == PermissionStatus.denied)
        ? Center(
            child: ElevatedButton(
              onPressed: () {
                requestPermission(Permission.locationWhenInUse);
              },
              child: Text("Grant Location Permission"),
            ),
          )
        : StreamBuilder<CompassEvent>(
            stream: FlutterCompass.events,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error reading heading: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              double? direction = snapshot.data!.heading;

              // if direction is null, then device does not support this sensor
              // show error message
              if (direction == null)
                return Center(
                  child: Text("Device does not have sensors !"),
                );

              return Center(
                child: Container(
                  height: 350,
                  width: 350,
                  // padding: EdgeInsets.all(8),
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  child: Transform.rotate(
                    angle: (direction * (math.pi / 180) * -1),
                    child: Image.asset("assets/images/compass.png"),
                  ),
                  decoration: BoxDecoration(
                      color: Color(0xFFC3B0C6),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        const BoxShadow(
                          color: Color(0xFFA588AA),
                          offset: Offset(10, 10),
                          blurRadius: 30,
                          spreadRadius: 1,
                        ),
                        const BoxShadow(
                          color: Color(0xFFC3B0C6),
                          offset: Offset(-10, -10),
                          blurRadius: 30,
                          spreadRadius: 1,
                        ),
                      ]),
                ),
              );
            },
          );
  }
}
