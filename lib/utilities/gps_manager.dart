import 'dart:async';
import 'package:background_location/background_location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flight_follower/utilities/database_api.dart';
import 'package:permission_handler/permission_handler.dart';

class GPSManager {
  static final GPSManager _gpsManager = GPSManager._internal();
  final double _distance = 100;
  bool _isStarted = false;
  //StreamSubscription<Position>? _listener;
  String? _flightID;
  CollectionReference? _gpsCollectionReference;

  GPSManager._internal();

  factory GPSManager() {
    return _gpsManager;
  }

  bool get isStarted => _isStarted;

  Future<void> start(String flightID) async {
    if (_isStarted) return;
    var status = await Permission.notification.status;
    if (status.isDenied) {
      if (await Permission.notification.request().isDenied) {
        // denied again
      }
    }

    BackgroundLocation.setAndroidNotification(
        title: "Flight Follower",
        message: "Flight Follower is using your location",
        icon: "@mipmap/ic_launcher");

    BackgroundLocation.startLocationService(distanceFilter: _distance);

    BackgroundLocation.getLocationUpdates(
        (location) => _positionListenerCallback);
    _isStarted = true;
  }

  Future<void> stop() async {
    if (!_isStarted) return;
    //await _listener!.cancel();
    //_listener = null;
    BackgroundLocation.stopLocationService();
    _flightID = null;
    _gpsCollectionReference = null;
    _isStarted = false;
    return;
  }

  void _positionListenerCallback(Location location) {
    //String currentTime =
    //    formattedTimeFromDateTime(DateTime.now(), seconds: true);
    GPSData data = GPSData(DateTime.now(), location.latitude!,
        location.longitude!, location.bearing!);
    DocumentReference ref = _gpsCollectionReference!.doc();
    ref.set(data.toMap());
  }
}

class GPSData {
  final DateTime time;
  final double lat;
  final double long;
  final double heading;

  GPSData(this.time, this.lat, this.long, this.heading);

  Map<String, dynamic> toMap() {
    return {
      "time": time.toString(),
      "lat": lat,
      "long": long,
      "heading": heading
    };
  }

  factory GPSData.fromMap(Map<String, dynamic> data) {
    return GPSData(DateTime.parse(data["time"]), data["lat"], data["long"],
        data["heading"]);
  }
}
