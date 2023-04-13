import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const LatLng sourceLocation = LatLng(23.777176,90.399452);
  static const LatLng destination = LatLng(23.450001, 91.199997);
  final Completer<GoogleMapController> _controller = Completer();
  List<LatLng> polylineCoordinates = [];

  @override
  void initState() {
    getCurrentaLocation();
    getPolyPoints();
    // TODO: implement initState
    super.initState();
  }

  LocationData? currentLocation;

  void getCurrentaLocation() async {
    Location location = Location();
    location.getLocation().then((location) {
      currentLocation = location;
    });
    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;
      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(zoom: 13.5,
              target: LatLng(newLoc.latitude!, newLoc.longitude!))));
      setState(() {});
    });
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyAZ3X6k-I5KnZ_sTkW2_bF0XNr46un6S_Y",
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(destination.latitude, destination.longitude));

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) =>
          polylineCoordinates.add(LatLng(point.latitude, point.longitude)));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Track Oder"),
      ),
      body: currentLocation == null
          ? Text("Loding")
          : GoogleMap(
        initialCameraPosition: CameraPosition(
            target: LatLng(
                currentLocation!.latitude!, currentLocation!.longitude!),
            zoom: 12.5),
        polylines: {
          Polyline(
              polylineId: PolylineId("route"),
              points: polylineCoordinates,
              color: Colors.orange,
              width: 5)
        },
        markers: {
          Marker(
              markerId: MarkerId("CurrentLocation"),
              position: LatLng(currentLocation!.latitude!,
                  currentLocation!.longitude!)),
          Marker(markerId: MarkerId("sorce"), position: sourceLocation),
          Marker(
              markerId: MarkerId("destination"), position: destination),
        },
        onMapCreated: (mapController) {
          _controller.complete(mapController);
        },
      ),
    );
  }
}
