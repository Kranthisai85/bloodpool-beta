// ignore_for_file: import_of_legacy_library_into_null_safe
import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  final String? bloodgroup;
  final Position? userPosition;

  const MapScreen({
    Key? key,
    this.bloodgroup,
    this.userPosition,
  }) : super(key: key);

  // final String title;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String? lattitude;
  String? longitude;
  final Set<Marker> markers = {}; //markers for google map
  Random random = Random();
  String? name;
  String? age;
  String? gender;
  String? number;
  var doubleValue;
  var responseData;

  @override
  void initState() {
    super.initState();
    getLocationData();
    locateMyPosition();
    doubleValue = random.nextDouble();
    // markers = Set.from([]);
  }

  var geolocator = Geolocator();
  Position? myLatPosition;

  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition warangalPlace = CameraPosition(
    target: LatLng(18.000055, 79.588165),
    zoom: 14.4746,
  );

  void locateMyPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    setState(() {
      myLatPosition = position;
    });

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLatPosition, zoom: 15);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  getLocationData() async {
    final response = await http.get(
        'https://bloodpool-backend.herokuapp.com/locations/${widget.bloodgroup}');

    setState(() {
      responseData = json.decode(response.body);
    });
  }

  Set<Marker> getmarkers() {
    //markers to place on map
    setState(() {
      if(responseData != null) {
        for (int i = 0; i <= responseData.length - 1; i++) {
          if (responseData[i]['latitude'] != null) {
            markers.add(Marker(
              onTap: () {
                setState(() {
                  name = responseData[i]['name'];
                  age = responseData[i]['age'].toString();
                  gender = responseData[i]['gender'];
                  number = responseData[i]['mobilenumber'];
                });
              },
              //add first marker
              markerId: MarkerId('marker-$i'),
              position: LatLng(
                  responseData[i]['latitude'] ??
                      myLatPosition!.latitude +
                          num.parse(doubleValue.toStringAsFixed(1)) / 100 * i,
                  responseData[i]['longitude'] ??
                      myLatPosition!.longitude +
                          num.parse(doubleValue.toStringAsFixed(1)) /
                              150 *
                              i), //position of marker
              infoWindow: InfoWindow(
                //popup info
                title: responseData[i]['name'],
                snippet: '${responseData[i]['gender']}'
                    ', ${responseData[i]['age']} Years',
              ),
              icon: BitmapDescriptor.defaultMarker, //Icon for Marker
            ));
          }
        }
      }

      //add more markers here
    });

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body: Column(
        children: <Widget>[
          Expanded(
            // height: 600,
            child: GoogleMap(
              initialCameraPosition: warangalPlace,
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              markers: getmarkers(),
              onMapCreated: (GoogleMapController controller) => {
                _controllerGoogleMap.complete(controller),
                newGoogleMapController = controller,
                setState(() {
                  lattitude = myLatPosition!.latitude as String?;
                  longitude = myLatPosition!.longitude as String?;
                }),
                locateMyPosition(),
              },
              padding: const EdgeInsets.only(top: 100.0),
            ),
          ),
          Container(
            height: 200,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 15,
                  )
                ]),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.all(18.0),
                    child: Row(
                      children: [
                        const Text(
                          'Select Donor Location ',
                          style: TextStyle(color: Colors.grey, fontSize: 20),
                        ),
                        responseData != null ? Text('(' '${responseData.length} ''found)',style:TextStyle(fontSize: 18,color: Colors.grey[400],fontStyle: FontStyle.italic)) : const Text('')
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 15),
                  child: name == null &&
                          age == null &&
                          number == null &&
                          gender == null
                      ? Text(
                          myLatPosition != null
                              ? myLatPosition.toString()
                              : 'Finding Your Location...',
                          // '${widget.userPosition!.latitude}, ${widget.userPosition!.longitude}',
                          style: const TextStyle(
                              color: Colors.black, fontSize: 20),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text('Name:\t',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 19)),
                              Text('$name\t',
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 22)),
                              const Text(',\tAge:\t',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 19)),
                              Text(age!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 22)),
                              const Text(',\tGender:\t',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 19)),
                              Text(gender!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 22)),
                            ],
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (number == null) {
                        Fluttertoast.showToast(
                            msg: "Select the donor",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      } else {
                        launch("tel://$number");
                      }
                    },
                    child: const Text('CONTACT DONOR'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}






//Extra code for reference
      // markers.add(Marker(
      //   onTap: () {
      //     setState(() {
      //       name = 'Suresh';
      //       age = '25';
      //       gender = 'Male';
      //       number = '9847685486';
      //     });
      //   },
      //   //add first marker
      //   markerId: MarkerId('marker-1'),
      //   position: LatLng(
      //       widget.userPosition != null
      //           ? widget.userPosition!.latitude +
      //               num.parse(doubleValue.toStringAsFixed(1)) / 150
      //           : myLatPosition!.latitude +
      //               num.parse(doubleValue.toStringAsFixed(1)) / 150,
      //       widget.userPosition != null
      //           ? widget.userPosition!.longitude +
      //               num.parse(doubleValue.toStringAsFixed(1)) / 150
      //           : myLatPosition!.longitude +
      //               num.parse(doubleValue.toStringAsFixed(1)) /
      //                   150), //position of marker
      //   infoWindow: const InfoWindow(
      //     //popup info
      //     title: 'Suresh',
      //     snippet: 'Male, 25 Years',
      //   ),
      //   icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      // ));

      // markers.add(Marker(
      //   onTap: () {
      //     setState(() {
      //       name = 'Mahesh';
      //       age = '45';
      //       gender = 'Male';
      //       number = '9896685486';
      //     });
      //   },
      //   //add second marker
      //   markerId: MarkerId('marker-2'),
      //   position: LatLng(
      //       widget.userPosition != null
      //           ? widget.userPosition!.latitude -
      //               num.parse(doubleValue.toStringAsFixed(1)) / 200
      //           : myLatPosition!.latitude -
      //               num.parse(doubleValue.toStringAsFixed(1)) / 200,
      //       widget.userPosition != null
      //           ? widget.userPosition!.longitude -
      //               num.parse(doubleValue.toStringAsFixed(1)) / 200
      //           : myLatPosition!.longitude -
      //               num.parse(doubleValue.toStringAsFixed(1)) /
      //                   200), //position of marker
      //   infoWindow: const InfoWindow(
      //     //popup info
      //     title: 'Mahesh',
      //     snippet: 'Male, 45 Years',
      //   ),
      //   icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      // ));

      // markers.add(Marker(
      //   onTap: () {
      //     setState(() {
      //       name = 'Saritha';
      //       age = '32';
      //       gender = 'Female';
      //       number = '9894235486';
      //     });
      //   },
      //   //add third marker
      //   markerId: MarkerId('marker-3'),
      //   position: LatLng(
      //       widget.userPosition != null
      //           ? widget.userPosition!.latitude +
      //               num.parse(doubleValue.toStringAsFixed(1)) / 200
      //           : myLatPosition!.latitude +
      //               num.parse(doubleValue.toStringAsFixed(1)) / 200,
      //       widget.userPosition != null
      //           ? widget.userPosition!.longitude -
      //               num.parse(doubleValue.toStringAsFixed(1)) / 200
      //           : myLatPosition!.longitude -
      //               num.parse(doubleValue.toStringAsFixed(1)) /
      //                   200), //position of marker
      //   infoWindow: const InfoWindow(
      //     //popup info
      //     title: 'Saritha',
      //     snippet: 'Female, 32 Years',
      //   ),
      //   icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      // ));

      // markers.add(Marker(
      //   onTap: () {
      //     setState(() {
      //       name = 'Chintu Whitehat';
      //       age = '19';
      //       gender = 'Male';
      //       number = '9689685486';
      //     });
      //   },
      //   //add third marker
      //   markerId: MarkerId('marker-4'),
      //   position: LatLng(
      //       widget.userPosition != null
      //           ? widget.userPosition!.latitude -
      //               num.parse(doubleValue.toStringAsFixed(1)) / 200
      //           : myLatPosition!.latitude -
      //               num.parse(doubleValue.toStringAsFixed(1)) / 200,
      //       widget.userPosition != null
      //           ? widget.userPosition!.longitude +
      //               num.parse(doubleValue.toStringAsFixed(1)) / 200
      //           : myLatPosition!.longitude +
      //               num.parse(doubleValue.toStringAsFixed(1)) /
      //                   200), //position of marker
      //   infoWindow: const InfoWindow(
      //     //popup info
      //     title: 'Chintu',
      //     snippet: 'Male, 19 Years',
      //   ),
      //   icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      // ));

      // markers.add(Marker(
      //   onTap: () {
      //     setState(() {
      //       name = 'Mary';
      //       age = '27';
      //       gender = 'Female';
      //       number = '9898476486';
      //     });
      //   },
      //   //add third marker
      //   markerId: MarkerId('marker-5'),
      //   position: LatLng(
      //       widget.userPosition != null
      //           ? widget.userPosition!.latitude -
      //               num.parse(doubleValue.toStringAsFixed(1)) / 100
      //           : myLatPosition!.latitude -
      //               num.parse(doubleValue.toStringAsFixed(1)) / 100,
      //       widget.userPosition != null
      //           ? widget.userPosition!.longitude +
      //               num.parse(doubleValue.toStringAsFixed(1)) / 50
      //           : myLatPosition!.longitude +
      //               num.parse(doubleValue.toStringAsFixed(1)) /
      //                   50), //position of marker
      //   infoWindow: const InfoWindow(
      //     //popup info
      //     title: 'Mary',
      //     snippet: '27 Years old Female',
      //   ),
      //   icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      // ));

      // markers.add(Marker(
      //   onTap: () {
      //     setState(() {
      //       name = 'Sridevi';
      //       age = '25';
      //       gender = 'Male';
      //       number = '9896645686';
      //     });
      //   },
      //   //add third marker
      //   markerId: MarkerId('marker-6'),
      //   position: LatLng(
      //       widget.userPosition != null
      //           ? widget.userPosition!.latitude -
      //               num.parse(doubleValue.toStringAsFixed(1)) / 220
      //           : myLatPosition!.latitude -
      //               num.parse(doubleValue.toStringAsFixed(1)) / 200,
      //       widget.userPosition != null
      //           ? widget.userPosition!.longitude -
      //               num.parse(doubleValue.toStringAsFixed(1)) / 80
      //           : myLatPosition!.longitude -
      //               num.parse(doubleValue.toStringAsFixed(1)) /
      //                   80), //position of marker
      //   infoWindow: const InfoWindow(
      //     //popup info
      //     title: 'Sridevi',
      //     snippet: 'Female, 25 Years',
      //   ),
      //   icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      // ));

      // markers.add(Marker(
      //   onTap: () {
      //     setState(() {
      //       name = 'Pooja';
      //       age = '27';
      //       gender = 'Female';
      //       number = '9896645686';
      //     });
      //   },
      //   //add third marker
      //   markerId: MarkerId('marker-7'),
      //   position: LatLng(
      //       widget.userPosition != null
      //           ? widget.userPosition!.latitude -
      //               num.parse(doubleValue.toStringAsFixed(1)) / 100
      //           : myLatPosition!.latitude -
      //               num.parse(doubleValue.toStringAsFixed(1)) / 100,
      //       widget.userPosition != null
      //           ? widget.userPosition!.longitude -
      //               num.parse(doubleValue.toStringAsFixed(1)) / 100
      //           : myLatPosition!.longitude -
      //               num.parse(doubleValue.toStringAsFixed(1)) /
      //                   100), //position of marker
      //   infoWindow: const InfoWindow(
      //     //popup info
      //     title: 'Pooja',
      //     snippet: 'Female, 27 Years',
      //   ),
      //   icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      // ));

      // markers.add(Marker(
      //   onTap: () {
      //     setState(() {
      //       name = 'SaiRam';
      //       age = '24';
      //       gender = 'Male';
      //       number = '9895645686';
      //     });
      //   },
      //   //add third marker
      //   markerId: MarkerId('marker-8'),
      //   position: LatLng(
      //       widget.userPosition != null
      //           ? widget.userPosition!.latitude +
      //               num.parse(doubleValue.toStringAsFixed(1)) / 110
      //           : myLatPosition!.latitude +
      //               num.parse(doubleValue.toStringAsFixed(1)) / 100,
      //       widget.userPosition != null
      //           ? widget.userPosition!.longitude +
      //               num.parse(doubleValue.toStringAsFixed(1)) / 90
      //           : myLatPosition!.longitude +
      //               num.parse(doubleValue.toStringAsFixed(1)) /
      //                   90), //position of marker
      //   infoWindow: const InfoWindow(
      //     //popup info
      //     title: 'SaiRam',
      //     snippet: 'Male, 24 Years',
      //   ),
      //   icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      // ));