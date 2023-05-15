import 'package:flight_follower/utilities/gps_manager.dart';
import 'package:flight_follower/widgets/flight_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class FlightMap extends StatelessWidget {
  List<GPSData> _gpsData = [];
  FlightMap(this._gpsData, {super.key});

  LatLng getCentroidLatLng() {
    if (_gpsData.isEmpty) {
      return LatLng(53.825564, -2.421976);
    }
    double lat = 0;
    double long = 0;
    for (GPSData data in _gpsData) {
      lat += data.lat;
      long += data.long;
    }
    return LatLng(lat / _gpsData.length, long / _gpsData.length);
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: getCentroidLatLng(),
        zoom: 6,
        maxZoom: 15,
      ),
      nonRotatedChildren: [
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () =>
                  launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
            ),
          ],
        ),
      ],
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        MarkerLayer(
          markers: [
            for (GPSData data in _gpsData)
              Marker(
                  point: LatLng(data.lat, data.long),
                  width: 80,
                  height: 80,
                  builder: (context) => Transform.rotate(
                      angle: data.heading, child: const Icon(Icons.flight)))
          ],
        )
      ],
    );
  }
}
