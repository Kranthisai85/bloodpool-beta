import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:bloodpool/main.dart';
import 'package:bloodpool/map_screen.dart';
import 'package:bloodpool/profile_screen.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent/android_intent.dart';

class SearchScreen extends StatefulWidget {
  final String? username;
  const SearchScreen({Key? key, this.username}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // final PermissionHandler permissionHandler = PermissionHandler();
  // Map<PermissionGroup, PermissionStatus> permissions;
  Random random = Random();
  List allDonors = [];
  List searchDonors = [];
  String? sometext = "No Results Found";
  String? selectedBlood;
  Position? myLatPosition;
  GoogleMapController? newGoogleMapController;

  @override
  initState() {
    super.initState();
    getData();
    // requestLocationPermission();
    requestLocationPermission();
    _gpsService();
    locateMyPosition();
  }

  searchData(String bloodgroup) async {
    sometext = "Loading...";
    Future.delayed(const Duration(seconds: 7), () {
      setState(() {
        sometext = "No Results Found";
      });
    });

    var paramsData = bloodgroup;
    final response = await http
        .get('https://bloodpool-backend.herokuapp.com/search/$paramsData');

    var responseData = json.decode(response.body);
    setState(() {
      searchDonors = responseData;
      allDonors = searchDonors;
    });
  }

  getData() async {
    sometext = "Loading...";
    Future.delayed(const Duration(seconds: 7), () {
      setState(() {
        sometext = "No Results Found";
      });
    });
    final response =
        await http.get('https://bloodpool-backend.herokuapp.com/find');

    var responseData = json.decode(response.body);
    setState(() {
      allDonors = responseData;
    });

    // allDonors = responseData[]
  }

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

  // Future<bool> _requestPermission(PermissionGroup permission) async {
  //   final PermissionHandler _permissionHandler = PermissionHandler();
  //   var result = await _permissionHandler.requestPermissions([permission]);
  //   if (result[permission] == PermissionStatus.granted) {
  //     return true;
  //   }
  //   return false;
  // }

  // Future<bool> requestLocationPermission({Function onPermissionDenied}) async {
  //   var granted = await _requestPermission(PermissionGroup.location);
  //   if (granted != true) {
  //     requestLocationPermission();
  //   }
  //   debugPrint('requestContactsPermission $granted');
  //   return granted;
  // }

  Future<void> requestLocationPermission() async {
    final serviceStatusLocation = await Permission.locationWhenInUse.isGranted;

    bool isLocation = serviceStatusLocation == ServiceStatus.enabled;

    final status = await Permission.locationWhenInUse.request();

    if (status == PermissionStatus.granted) {
      print('Permission Granted');
    } else if (status == PermissionStatus.denied) {
      print('Permission denied');
      Fluttertoast.showToast(
        msg: 'Please Allow us the Location permission and restart the app',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM_LEFT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.greenAccent,
        textColor: Colors.white,
      );
    } else if (status == PermissionStatus.permanentlyDenied) {
      print('Permission Permanently Denied');
      // await openAppSettings();
    }
  }

  Future _checkGps() async {
    if (!(await Geolocator.isLocationServiceEnabled())) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Can't get gurrent location"),
                content:
                    const Text('Please make sure you enable GPS and try again'),
                actions: <Widget>[
                  TextButton(
                      child: const Text('Ok'),
                      onPressed: () {
                        const AndroidIntent intent = AndroidIntent(
                            action:
                                'android.settings.LOCATION_SOURCE_SETTINGS');
                        intent.launch();
                        Navigator.of(context, rootNavigator: true).pop();
                        _gpsService();
                      })
                ],
              );
            });
      }
    }
  }

/*Check if gps service is enabled or not*/
  Future _gpsService() async {
    if (!(await Geolocator.isLocationServiceEnabled())) {
      _checkGps();
      return null;
    } else {
      return true;
    }
  }

  Future<bool> _onBackPressed() async {
    return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Are you sure?'),
              content: const Text('Do you want to exit an App'),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                ElevatedButton(
                  child: const Text('Yes'),
                  onPressed: () {
                    // Navigator.of(context).pop(true);
                    if (Platform.isAndroid) {
                      SystemNavigator.pop();
                    } else if (Platform.isIOS) {
                      exit(0);
                    }
                  },
                )
              ],
            );
          },
        ) ??
        false;
  }

  removeValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("email");
    prefs.remove("username");
    prefs.remove("password");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.red[800],
            title: Text(
                widget.username != null
                    ? "${widget.username}'s BloodPool"
                    : 'Emergency BloodPool',
                style: const TextStyle(
                  color: Colors.white,
                )),
            centerTitle: widget.username != null ? false : true,
            actions: [
              Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      removeValues();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyHomePage(
                                title: 'Welcome to BloodPool')),
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.logout_rounded,
                          size: 26.0,
                        ),
                        widget.username != null
                            ? const Text('Logout',
                                style: TextStyle(fontWeight: FontWeight.bold))
                            : const Text(''),
                      ],
                    ),
                  )),
            ]),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 15.0, bottom: 15, right: 15, left: 15),
                      child: SizedBox(
                        width: 200,
                        child: DropdownButton(
                            isExpanded: true,
                            underline: const SizedBox(),
                            alignment: Alignment.center,
                            icon: const Icon(Icons.arrow_drop_down_circle),
                            iconEnabledColor: Colors.red.shade800,
                            dropdownColor: Colors.white,
                            value: selectedBlood,
                            // elevation: 5,
                            items: [
                              DropdownMenuItem(
                                child: Center(
                                  child: Text("A+",
                                      style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontWeight: FontWeight.w800)),
                                ),
                                value: 'A+',
                              ),
                              DropdownMenuItem(
                                child: Center(
                                  child: Text("B+",
                                      style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontWeight: FontWeight.w800)),
                                ),
                                value: 'B+',
                              ),
                              DropdownMenuItem(
                                child: Center(
                                  child: Text("O+",
                                      style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontWeight: FontWeight.w800)),
                                ),
                                value: 'O+',
                              ),
                              DropdownMenuItem(
                                child: Center(
                                  child: Text("AB+",
                                      style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontWeight: FontWeight.w800)),
                                ),
                                value: 'AB+',
                              ),
                              DropdownMenuItem(
                                child: Center(
                                  child: Text("O-",
                                      style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontWeight: FontWeight.w800)),
                                ),
                                value: 'O-',
                              )
                            ],
                            onChanged: (String? value) {
                              setState(() {
                                selectedBlood = value;
                              });
                              searchData(selectedBlood!);
                            },
                            hint: Text(" Search Blood Group",
                                style: TextStyle(
                                    color: Colors.red.shade800,
                                    fontWeight: FontWeight.bold))),
                      ),
                    ),
                    const Text('Search in Map : ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            selectedBlood != null ? Colors.blue : Colors.grey),
                        // padding: MaterialStateProperty.all(EdgeInsets.all(10)),
                        // textStyle:
                        // MaterialStateProperty.all(TextStyle(fontSize: 10))
                      ),
                      onPressed: () {
                        if (selectedBlood == null) {
                          Fluttertoast.showToast(
                            msg: 'Please select bloodgroup',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM_LEFT,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.greenAccent,
                            textColor: Colors.white,
                          );
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MapScreen(
                                      bloodgroup: selectedBlood,
                                      userPosition: myLatPosition)));
                        }
                      },
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: allDonors.isNotEmpty
                      ? ListView.builder(
                          itemCount: allDonors.length,
                          itemBuilder: (context, index) => Card(
                            // key: ValueKey(allDonors.isNotEmpty ? allDonors[index]["bloodgroup"] : 'index'),
                            color: Colors.amberAccent,
                            elevation: 5,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfileScreen(
                                          donorDetails: allDonors[index])),
                                );
                              },
                              child: ListTile(
                                leading: Text(
                                  // _foundUsers[index]["id"].toString(),
                                  allDonors.isNotEmpty
                                      ? allDonors[index]["bloodgroup"]
                                      : '$index',
                                  style: const TextStyle(fontSize: 24),
                                ),
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(allDonors[index]['name'],
                                        style: const TextStyle(fontSize: 17)),
                                    Text(
                                        allDonors[index]['mobilenumber']
                                                    .toString() ==
                                                'null'
                                            ? 'No Number'
                                            : 'Tap for details',
                                        // : allDonors[index]['mobilenumber']
                                        //     .toString(),
                                        style: const TextStyle(fontSize: 15))
                                  ],
                                ),
                                subtitle: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        '${allDonors[index]["age"].toString()} years old'),
                                    Text(
                                        '${((random.nextDouble()) * random.nextInt(index + 10)).toStringAsFixed(2)} km away'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : Text(
                          sometext!,
                          style: const TextStyle(fontSize: 24),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
