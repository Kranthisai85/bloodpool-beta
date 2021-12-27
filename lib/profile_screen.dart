import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';




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

  getIdData(String? id) async {
    // sometext = "Loading...";
    // Future.delayed(const Duration(seconds: 5), () {
    //   setState(() {
    //     sometext = "No Results Found";
    //   });
    // });
    final response =
        await http.get('https://bloodpool-backend.herokuapp.com/find/$id');

    var responseData = json.decode(response.body);

    setState(() {
      donorMoreDetails = responseData;
      phone = donorMoreDetails!['mobilenumber'];
      // print(donorDetails!['name']);
    });
  }

  @override
  void initState() {
    super.initState();
    getIdData(widget.donorDetails!['_id']);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BloodPool Donor Profile',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red[700],
          title: Text(widget.donorDetails!['username'] != null ? '${widget.donorDetails!['username']}\'s Profile' : 'BloodDonor\'s Profile'),
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
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade700,
                        minRadius: 35.0,
                        child: GestureDetector(
                            onTap: () => {launch("tel://$phone")},
                            child: const Icon(Icons.call,
                                size: 32.0, color: Colors.white)),
                      ),
                      CircleAvatar(
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
                      CircleAvatar(
                        backgroundColor: Colors.red,
                        minRadius: 35.0,
                        child: GestureDetector(
                            onTap: () => {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text(
                                        "Chat feature is yet to be implemented by developers. Stay Tuned!!"),
                                  ))
                                },
                            child: const Icon(Icons.message,
                                size: 30.0, color: Colors.white)),
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
                            .replaceAllMapped(RegExp(r".{4}"),
                                (match) => "${match.group(0)} ")
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
                  title: const Text(
                    'Location',
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
                            "Location feature is yet to be implemented by developers. Stay Tuned!!"),
                      ))
                    },
                    child: const Text(
                      'Tap here',
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
