import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class ProfileScreen extends StatefulWidget {
  // final String? id;
  final Map? donorDetails;
  const ProfileScreen({Key? key, this.donorDetails}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map? donorMoreDetails;
  // String? sometext = "No Results Found";
  String? name;
  String? age;
  String? aadhar;
  String? mobileNumber;
  String? email;
  String? userName;
  String? phone;
  double? latitude;
  double? longitude;
  String? address;
  String? locationInfo;

  getIdData(String? id) async {
    final response =
        await http.get('https://bloodpool-backend.herokuapp.com/find/$id');

    var responseData = json.decode(response.body);

    setState(() {
      donorMoreDetails = responseData;
      phone = donorMoreDetails!['mobilenumber'];
      latitude = donorMoreDetails!['latitude'];
      longitude = donorMoreDetails!['longitude'];
      // print(donorDetails!['name']);
    });

    getAddressFromLatLong(latitude, longitude);
  }

  @override
  void initState() {
    super.initState();
    getIdData(widget.donorDetails!['_id']);
    locationInfo = 'Finding..';
    Future.delayed(const Duration(milliseconds: 2000), () {
      setState(() {
        locationInfo = 'Not Found';
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getAddressFromLatLong(latitude, longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      print(placemarks[3]);
      Placemark place = placemarks[3];
      setState(() {
        address =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}';
      });
    } catch (e) {
      print(e);
      try {
        List<Placemark> placemarks =
            await placemarkFromCoordinates(latitude, longitude);
        print(placemarks[0]);
        Placemark place = placemarks[0];
        setState(() {
          address =
              '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}';
        });
      } catch (e) {
        print(e);
         setState(() {
          address = '$latitude,$longitude';
        });
      }
    }
    // Address =
    //     '${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}';
  }

  static void navigateTo(double lat, double lng) async {
    var uri = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      Fluttertoast.showToast(msg: 'Couldn\'t Open GMaps');
      throw 'Could not launch ${uri.toString()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[700],
        title: Text(widget.donorDetails!['username'] != null
            ? '${widget.donorDetails!['username']}\'s Profile'
            : 'BloodDonor\'s Profile'),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade700, Colors.lightBlue.shade700],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: const [0.4, 0.9],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Card(
                      elevation: 8,
                      color: Colors.transparent,
                      shadowColor: Colors.transparent,
                      child: CircleAvatar(
                        backgroundColor: Colors.blue.shade700,
                        minRadius: 35.0,
                        child: GestureDetector(
                            onTap: () => {launch("tel://$phone")},
                            child: const Icon(Icons.call,
                                size: 32.0, color: Colors.white)),
                      ),
                    ),
                    Card(
                      elevation: 8,
                      color: Colors.transparent,
                      shadowColor: Colors.transparent,
                      child: CircleAvatar(
                        backgroundColor: Colors.white70,
                        minRadius: 60.0,
                        child: CircleAvatar(
                            radius: 55.0,
                            backgroundImage: widget.donorDetails != null
                                ? widget.donorDetails!['photo'] != null
                                    ? NetworkImage(
                                        widget.donorDetails!['photo'])
                                    : const NetworkImage(
                                        'https://media.istockphoto.com/vectors/red-blood-drop-icon-vector-illustration-vector-id1151546368?k=20&m=1151546368&s=170667a&w=0&h=NGC9zuM6UnR5OBLamC_vG3xqyC8Zjh9lOfW5_rsFjpU=')
                                // const NetworkImage(
                                //     'https://cdn.browshot.com/static/images/not-found.png')
                                : const NetworkImage(
                                    'https://media.istockphoto.com/vectors/red-blood-drop-icon-vector-illustration-vector-id1151546368?k=20&m=1151546368&s=170667a&w=0&h=NGC9zuM6UnR5OBLamC_vG3xqyC8Zjh9lOfW5_rsFjpU=')),
                      ),
                    ),
                    InkWell(
                      onTap: () => {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text(
                              "Chat feature is yet to be implemented by developers. Stay Tuned!!"),
                        ))
                      },
                      child: const CircleAvatar(
                        backgroundColor: Colors.red,
                        minRadius: 35.0,
                        child: Icon(Icons.message,
                            size: 30.0, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  widget.donorDetails!['name'] ?? 'Patient Name',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.donorDetails!['gender'] ?? 'gender',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Colors.blue.shade700,
                  child: ListTile(
                    title: Text(
                      widget.donorDetails!['age'] != null
                          ? widget.donorDetails!['age'].toString()
                          : 'N/A',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: const Text(
                      'Age',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.red,
                  child: ListTile(
                    title: Text(
                      widget.donorDetails!['bloodgroup'] ?? 'N/A',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: const Text(
                      'Bloodgroup',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: <Widget>[
              ListTile(
                title: const Text(
                  'Email',
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  widget.donorDetails!['email'] ?? 'N/A',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text(
                  'Aadhar',
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  widget.donorDetails!['aadharno'] != null
                      ? widget.donorDetails!['aadharno']
                          .toString()
                          .replaceAllMapped(
                              RegExp(r".{4}"), (match) => "${match.group(0)} ")
                      : 'N/A',
                  // widget.donorDetails!['aadharno'] != null
                  //     ? widget.donorDetails!['aadharno'].toString()
                  //     : 'N/A',
                  style: const TextStyle(fontSize: 17),
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text(
                  'Last Blood Donated',
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: GestureDetector(
                  onTap: () => {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          "feature is yet to be implemented by developers. Stay Tuned!!"),
                    ))
                  },
                  child: const Text(
                    'Before 3 months',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Donor Location',
                      style: TextStyle(
                        color: Colors.deepOrange,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: () => {navigateTo(latitude!, longitude!)},
                      child: const Icon(Icons.directions_rounded,
                          color: Colors.deepOrange, size: 30),
                    )
                  ],
                ),
                subtitle: latitude == null ||
                        longitude == null ||
                        address == 'null' ||
                        address == null
                    ? GestureDetector(
                        onTap: () => {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                                "Location feature is yet to be implemented by developers. Stay Tuned!!"),
                          ))
                        },
                        child: Text(
                          '$locationInfo',
                          style: const TextStyle(fontSize: 17),
                        ),
                      )
                    : InkWell(
                        onTap: () => {navigateTo(latitude!, longitude!)},
                        child: Text(
                          '$address',
                          style: const TextStyle(fontSize: 17),
                        ),
                      ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
