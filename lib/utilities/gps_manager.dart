import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flight_follower/utilities/database_api.dart';
import 'package:flight_follower/utilities/utils.dart';
import 'package:geolocator/geolocator.dart';

class GPSManager {
  static final GPSManager _gpsManager = GPSManager._internal();
  final int _distance = 100;
  bool _isStarted = false;
  StreamSubscription<Position>? _listener;
  String? _flightID;
  CollectionReference? _gpsCollectionReference;

  GPSManager._internal();

  factory GPSManager() {
    return _gpsManager;
  }

  bool get isStarted => _isStarted;

  Future<void> start(String flightID) async {
    if (_isStarted) return;
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // handle service disabled
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // handle denied
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // handle denied forever
    }
    _flightID = flightID;
    //String currentTime =
    //    formattedTimeFromDateTime(DateTime.now(), seconds: true);
    Position currentPos = await Geolocator.getCurrentPosition();
    GPSData data = GPSData(DateTime.now(), currentPos.latitude,
        currentPos.longitude, currentPos.heading);
    /* _gpsDocumentID =
        await DatabaseWrapper().addDocument("gps", {currentTime: data.toMap()});
    DocumentReference ref =
        DatabaseWrapper().getReferenceForDocument("gps", _gpsDocumentID!);
    DatabaseWrapper().updateDocument("flights", _flightID!, {"gps_data": ref}); */

    _gpsCollectionReference = DatabaseWrapper()
        .getReferenceForDocument("flights", _flightID!)
        .collection("gps_data");

    DocumentReference ref = _gpsCollectionReference!.doc();

    await ref.set(data.toMap());

    final LocationSettings settings = LocationSettings(
        accuracy: LocationAccuracy.high, distanceFilter: _distance);
    _listener = Geolocator.getPositionStream(locationSettings: settings)
        .listen(_positionListenerCallback);
    _isStarted = true;
  }

  Future<void> stop() async {
    if (!_isStarted) return;
    await _listener!.cancel();
    _listener = null;
    _flightID = null;
    _gpsCollectionReference = null;
    _isStarted = false;
    return;
  }

  void _positionListenerCallback(Position? position) {
    if (position == null) return;
    //String currentTime =
    //    formattedTimeFromDateTime(DateTime.now(), seconds: true);
    GPSData data = GPSData(DateTime.now(), position.latitude,
        position.longitude, position.heading);
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
