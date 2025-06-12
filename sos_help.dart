import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:sos_help/google_map.dart';
import 'package:sos_help/popup_screen.dart';
import 'package:http/http.dart';
import 'package:sos_help/sos_screen.dart';

class SosHelp extends StatefulWidget {
  const SosHelp({super.key});

  @override
  State<SosHelp> createState() => _SosHelpState();
}

class _SosHelpState extends State<SosHelp> {
  double accelerateX = 0.0, accelerateY = 0.0, accelerateZ = 0.0;
  double gyroscopeX = 0.0, gyroscopeY = 0.0, gyroscopeZ = 0.0;
  double magnetometerX = 0.0, magnetometerY = 0.0, magnetometerZ = 0.0;

  Timer? timer;

  late NoiseMeter noiseMeter;
  bool isNoiseActive = false;
  late StreamSubscription<NoiseReading>? noiseSubscription;
  double latestDB = 0.0;
  late StreamSubscription<AccelerometerEvent> accelerometerSubscription;

  void startNoiseDetection() async {
    if (isNoiseActive) return;
    try {
      noiseSubscription = noiseMeter.noiseStream.listen((NoiseReading reading) {
        setState(() {
          latestDB = reading.meanDecibel;
          double accel = sqrt(accelerateX * accelerateX +
              accelerateY * accelerateY +
              accelerateZ * accelerateZ);
          if (latestDB >= 84) {
            showCustomDialog(context);
          }
        });
      });
      setState(() => isNoiseActive = true);
    } catch (err) {
      print('Noise meter error: $err');
    }
  }

  @override
  void initState() {
    super.initState();
    noiseMeter = NoiseMeter();
    startNoiseDetection();

    setState(() {
      accelerometerEvents.listen((AccelerometerEvent event) {
        accelerateX = event.x;
        accelerateY = event.y;
        accelerateZ = event.z;
      });

      timer = Timer.periodic(Duration(seconds: 3), (timer) {
        setState(() {});
      });

      // Gyroscope (e.g., for rotation or flipping detection)
      gyroscopeEvents.listen((GyroscopeEvent event) {
        gyroscopeX = event.x;
        gyroscopeY = event.y;
        gyroscopeZ = event.z;
      });

      // Magnetometer (for orientation, compass-style usage)
      magnetometerEvents.listen((MagnetometerEvent event) {
        magnetometerX = event.x;
        magnetometerY = event.y;
        magnetometerZ = event.z;
      });
    });
  }

  // void listenToAccelerometer() {
  //   accelerometerSubscription = accelerometerEvents.listen((event) {
  //     // double accel = sqrt(accelerateX * accelerateX + accelerateY * accelerateY + accelerateZ * accelerateZ);
  //     //
  //     // // Example condition: sudden jerk
  //     // if (accel > 25 && latestDB > 80) {
  //     //
  //     //   showAlarmDialog(context);
  //     // }
  //   });
  // }

  void showCustomDialog(BuildContext context) async {
    final player = AudioPlayer();

    await player.play(AssetSource('images/Alert_alarm.wav'));

    var onMapCreated;
    var initialCameraPosition;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Alert!',
          style: TextStyle(
              color: Colors.red, fontSize: 25, fontWeight: FontWeight.bold),
        ),
        content: Text('Accident detected! Waitng for 1 minute'),
        actions: [
          TextButton(
              child: Text('Dismiss'),
              onPressed: () {
                player.stop();
                Navigator.of(context).pop();
              }),
          TextButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SosScreen())),
              child: Text('Call Sos'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SOS "),
        backgroundColor: Colors.cyan,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "SOS Help",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "AcceleratorMeter data:",
                style: TextStyle(fontSize: 20),
              ),
              Text("X: ${accelerateX.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 15)),
              Text("Y: ${accelerateY.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 15)),
              Text("Z: ${accelerateZ.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 15)),
              SizedBox(
                height: 20,
              ),
              Text(
                "Gyroscope data:",
                style: TextStyle(fontSize: 20),
              ),
              Text("X: ${gyroscopeX.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 15)),
              Text("Y: ${gyroscopeY.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 15)),
              Text("Z: ${gyroscopeZ.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 15)),
              SizedBox(
                height: 20,
              ),
              Text(
                "Magnetometer data:",
                style: TextStyle(fontSize: 20),
              ),
              Text("X: ${magnetometerX.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 15)),
              Text("Y: ${magnetometerY.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 15)),
              Text("Z: ${magnetometerZ.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 15)),
              SizedBox(
                height: 20,
              ),
              Text("Noise: ${latestDB.toStringAsFixed(2)}db",
                  style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
