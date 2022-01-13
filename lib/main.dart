import 'dart:io';
import 'package:flutter/services.dart';
import 'package:bloodpool/login_page.dart';
import 'package:bloodpool/registration_page.dart';
import 'package:bloodpool/search_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:motion_toast/motion_toast.dart';
// import 'package:motion_toast/resources/arrays.dart';
// import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // transparent status bar
  ));
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? email;
  String? password;
  String? username;
  String? mobile;
  getEmailSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? emailSF = prefs.getString('email');
    setState(() {
      email = emailSF;
    });
    return email;
  }

  getUsernameSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usernameSF = prefs.getString('username');
    setState(() {
      username = usernameSF;
    });
    return username;
  }

  getPasswordSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? passwordSF = prefs.getString('password');
    setState(() {
      password = passwordSF;
    });
    return password;
  }

  // getMobileSF() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? mobileSF = prefs.getString('mobile');
  //   setState(() {
  //     mobile = mobileSF;
  //   });
  //   return mobile;
  // }

  @override
  void initState() {
    super.initState();
    getEmailSF();
    getPasswordSF();
    getUsernameSF();
    // getMobileSF();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BloodPool',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: (email == null || username == null) && password == null
          ? const MyHomePage(title: 'Welcome to BloodPool')
          : SearchScreen(username: username),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // int _counter = 0;
  bool isClose = true;
  String? username;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      // _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    checkInternet();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getUsernameSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usernameSF = prefs.getString('username');
    setState(() {
      username = usernameSF;
    });
    return username;
  }

  checkInternet() async {
    await getUsernameSF();
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        print('widget.username');
        username == null ? showAlertDialog(context) : null;
      }
    } on SocketException catch (_) {
      showInternetAlertDialog(context);
      print('not connected');
    }
  }

  showInternetAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("Close"),
      onPressed: () {
        if (Platform.isAndroid) {
          SystemNavigator.pop();
        } else if (Platform.isIOS) {
          exit(0);
        }
        setState(() {
          isClose = !isClose;
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("You are not connected to internet"),
      content: const Text(
          "This App requires an active internet connection.\nPlease check your internet connection and restart"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    isClose
        ? showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert;
            },
            barrierDismissible: false,
          )
        : null;
    // MotionToast(
    //           color: Colors.red,
    //           description: "Thank You",
    //           icon: CupertinoIcons.heart_circle_fill,
    //           animationType: ANIMATION.FROM_LEFT,
    //         ).show(context);
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("Yes, I Will"),
      onPressed: () {
        Navigator.of(context).pop();
        setState(() {
          isClose = !isClose;
          print(isClose);
        });
      },
    );

    // set up the AlertDialog;
    AlertDialog alert = AlertDialog(
      title: const Text("Notice"),
      content: const Text(
          "This App is in it's beta version.\nAny bugs found kindly report to the BloodPool team"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    isClose
        ? showDialog(
            context: context,
            builder: (context) => StatefulBuilder(builder: (context, setState) {
              return alert;
            }),
            barrierDismissible: false,
          )
        : null;
    // MotionToast(
    //           color: Colors.red,
    //           description: "Thank You",
    //           icon: CupertinoIcons.heart_circle_fill,
    //           animationType: ANIMATION.FROM_LEFT,
    //         ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    // Future.delayed(Duration.zero, () => showAlertDialog(context));
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            DrawerHeader(
              child: Stack(children: [
                Container(
                    height: 500, child: Image.asset('assets/logo_light.png')),
                const Padding(
                  padding: EdgeInsets.only(left: 100.0),
                  child: Center(
                    child: Text(
                      'The Team',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                ),
              ]),
              decoration: const BoxDecoration(
                color: Colors.black87,
              ),
            ),
            ListTile(
              leading: const Padding(
                padding: EdgeInsets.all(8.0),
                child:
                    FaIcon(FontAwesomeIcons.code, color: Colors.grey, size: 20),
              ),
              title: const Text('KRANTHI DEV SAI'),
              subtitle: const Text('App Developer'),
              onTap: () =>
                  {Fluttertoast.showToast(msg: '  Contact : 9603154199')},
            ),
            ListTile(
              leading: const Padding(
                padding: EdgeInsets.all(8.0),
                child: FaIcon(FontAwesomeIcons.vials,
                    color: Colors.grey, size: 20),
              ),
              title: const Text('MADHAV RAO KEMSHETTY'),
              subtitle: const Text('Associate App Tester'),
              onTap: () =>
                  {Fluttertoast.showToast(msg: '  Contact : 9393666725')},
            ),
            ListTile(
              leading: const Padding(
                padding: EdgeInsets.all(8.0),
                child: FaIcon(FontAwesomeIcons.palette,
                    color: Colors.grey, size: 20),
              ),
              title: const Text('SHIVARAM RUDROJU'),
              subtitle: const Text('Graphic Designer'),
              onTap: () =>
                  {Fluttertoast.showToast(msg: '  Contact : 9959888511')},
            ),
            ListTile(
              leading: const Padding(
                padding: EdgeInsets.all(8.0),
                child: FaIcon(FontAwesomeIcons.database,
                    color: Colors.grey, size: 20),
              ),
              title: const Text('VENKATASAI VISHWANATH'),
              subtitle: const Text('Backend Developer'),
              onTap: () =>
                  {Fluttertoast.showToast(msg: '  Contact : 8801111077')},
            ),
            ListTile(
              leading: const Padding(
                padding: EdgeInsets.all(8.0),
                child: FaIcon(FontAwesomeIcons.vials,
                    color: Colors.grey, size: 20),
              ),
              title: const Text('VINEETH GOGIKAR'),
              subtitle: const Text('Associate App Tester'),
              onTap: () =>
                  {Fluttertoast.showToast(msg: '  Contact : 9703202747')},
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.red[800],
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title,
            style: const TextStyle(
              color: Colors.white,
            )),
        centerTitle: true,
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset('assets/home_logo.png'),
            Column(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Redirecting to Login Page..."),
                      ));
                      Future.delayed(
                          const Duration(milliseconds: 500),
                          () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LogInPage()),
                              ));

                      // Fluttertoast.showToast(
                      //     msg: "Redirecting to Login Page",
                      // toastLength: Toast.LENGTH_SHORT,
                      // gravity: ToastGravity.BOTTOM_LEFT,
                      //     timeInSecForIosWeb: 1,
                      //     backgroundColor: Colors.red,
                      //     textColor: Colors.white,
                      //     fontSize: 16.0);
                    },
                    child: const Text('    Login Here    '),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        textStyle: const TextStyle(
                          fontSize: 20,
                        ))),
                const SizedBox(height: 15),
                ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Redirecting to Register Page..."),
                      ));
                      Future.delayed(
                          const Duration(milliseconds: 500),
                          () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen()),
                              ));
                    },
                    child: const Text('Register With Us'),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        textStyle: const TextStyle(
                          fontSize: 20,
                        ))),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(bottom: 150.0),
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SearchScreen()),
                        );
                      },
                      child: const Text('Emergency Case'),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          textStyle: const TextStyle(
                            fontSize: 20,
                          ))),
                )
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Fluttertoast.showToast(
              msg: 'Help Button!',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM_LEFT,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          },
          tooltip: 'Increment',
          child: const Icon(Icons.help_outline_rounded,
              color: Colors.white,
              size:
                  30)), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
