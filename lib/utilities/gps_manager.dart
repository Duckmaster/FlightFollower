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
  String? _gpsDocumentID;

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
    String currentTime =
        formattedTimeFromDateTime(DateTime.now(), seconds: true);
    Position currentPos = await Geolocator.getCurrentPosition();
    _GPSData data =
        _GPSData(currentPos.latitude, currentPos.longitude, currentPos.heading);
    _gpsDocumentID =
        await DatabaseWrapper().addDocument("gps", {currentTime: data.toMap()});
    DocumentReference ref =
        DatabaseWrapper().getReferenceForDocument("gps", _gpsDocumentID!);
    DatabaseWrapper().updateDocument("flights", _flightID!, {"gps_data": ref});

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
    _gpsDocumentID = null;
    _isStarted = false;
    return;
  }

  void _positionListenerCallback(Position? position) {
    if (position == null) return;
    String currentTime =
        formattedTimeFromDateTime(DateTime.now(), seconds: true);
    _GPSData data =
        _GPSData(position.latitude, position.longitude, position.heading);
    DatabaseWrapper()
        .updateDocument("gps", _gpsDocumentID!, {currentTime: data.toMap()});
  }
}

class _GPSData {
  final double lat;
  final double long;
  final double heading;

  _GPSData(this.lat, this.long, this.heading);

  Map<String, dynamic> toMap() {
    return {"lat": lat, "long": long, "heading": heading};
  }
}
