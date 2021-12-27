import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:bloodpool/registration_page.dart';
import 'package:bloodpool/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:shared_preferences/shared_preferences.dart';

class LogInPage extends StatefulWidget {
  static String isLoggedIn = "false";

  const LogInPage({Key? key}) : super(key: key);
  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  late String name;
  String passWord = "";
  late File imageFile;
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;

    Widget _buildNameTF() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Username',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10.0),
          Container(
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            height: 55.0,
            child: TextFormField(
              onChanged: (value) {
                setState(() {
                  name = value;
                });
              },
              keyboardType: TextInputType.name,
              controller: nameController,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
                hintText: 'Enter your UserName',
                hintStyle: TextStyle(
                  color: Colors.white54,
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget _buildPasswordTF() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Password',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10.0),
          Container(
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            height: 55.0,
            child: TextFormField(
              onChanged: (value) {
                setState(() {
                  passWord = value;
                });
              },
              controller: passwordController,
              // validator: passwordValidator,
              // autovalidateMode: AutovalidateMode.always,
              obscureText: true,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14.0),
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 20,
                  ),
                  hintText: 'Enter your Password',
                  hintStyle: TextStyle(
                    color: Colors.white54,
                    fontFamily: 'OpenSans',
                  ),
                  errorStyle: TextStyle(
                    // color: Colors.red,
                    fontFamily: 'OpenSans',
                    fontSize: 11,
                  )),
            ),
          ),
          const SizedBox(height: 5.0),
          passWord != ""
              ? 3 < passWord.length && passWord.length < 8 ||
                      passWord.length > 16
                  ? const Text(
                      "  Password must be between 8 to 15",
                      style: TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'OpenSans',
                      ),
                    )
                  : !RegExp('(.*[A-Z].*)').hasMatch(passWord) &&
                          4 < passWord.length
                      ? const Text(
                          "  Password must have atleast 1 capital letter",
                          style: TextStyle(
                            color: Colors.yellow,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'OpenSans',
                          ),
                        )
                      : !RegExp('(.*[a-z].*)').hasMatch(passWord) &&
                              4 < passWord.length
                          ? const Text(
                              "  Password must have atleast 1 lower case letter",
                              style: TextStyle(
                                color: Colors.yellow,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'OpenSans',
                              ),
                            )
                          : !RegExp('.*[0-9].*').hasMatch(passWord) &&
                                  4 < passWord.length
                              ? const Text(
                                  "  Password must have atleast 1 number",
                                  style: TextStyle(
                                    color: Colors.yellow,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'OpenSans',
                                  ),
                                )
                              : const Text('')
              : const Text('')
        ],
      );
    }

    Widget _buildRegisterBtn() {
      return GestureDetector(
        onTap: () => {
          // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          //   content: Text("Development in Progress\nCome back later..."),
          // ))
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegisterScreen()),
          )
        },
        // onTap: () => {gotoLogin(context)},
        child: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Not Yet Registered? ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(
                text: 'Register',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // void gotoLogin(BuildContext context) {
    //   Navigator.of(context)
    //       .push(MaterialPageRoute(builder: (context) => SignInPage()));
    // }

    validate() async {

      addUsernametoSF() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('username', name);
      }

      // addEmailtoSF() async {
      //   SharedPreferences prefs = await SharedPreferences.getInstance();
      //   prefs.setString('email', name);
      // }

      addPasswordtoSF() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('password', passWord);
      }

      final response = await http.post(
        Uri.parse(
            'https://bloodpool-backend.herokuapp.com/loginpost'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            <String, String>{"username": name, "password": passWord}),
      );

      if (response.body == "in correct credentials") {
        Fluttertoast.showToast(
            msg: '  Wrong Email or Password!\n     Please try again :(');
      }
      else if(response.statusCode == 502){
        Fluttertoast.showToast(
            msg: '  Server Down!!!!\n  Please try later :(');
      }
      else {
        addUsernametoSF();
        addPasswordtoSF();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchScreen(username: name,)),
        );
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Successfully LoggedIn.."),
              ));
      }
    }

    Widget _buildLoginBtn() {
      return Container(
          padding: const EdgeInsets.symmetric(vertical: 25.0),
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              validate();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Login Button Clicked..Wait for Response"),
              ));
              // validate();
              // setState(() {
              //   SignInPage.isLoggedIn = "otp";
              // });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(15.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              primary: const Color(0xfffff8ee),
            ),
            child: const Text(
              'LOG IN',
              style: TextStyle(
                color: Color(0xFF527DAA),
                letterSpacing: 1.5,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans',
              ),
            ),
          ));
    }


    return Scaffold(
        // backgroundColor: const Color(0xff1a1a1a),
        // resizeToAvoidBottomInset:false,
        body: Stack(children: [
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red,
              Colors.red.withOpacity(0.5),
              Colors.blue.withOpacity(0.5),
              Colors.blue.withOpacity(0.9),
            ],
            stops: const [0.2, 0.7, 0.8, 0.9],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
      ),
      Container(
        color: Colors.black26,
      ),
      SingleChildScrollView(
        // physics: NeverScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    child: Column(
                      children: [
                        SafeArea(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Icon(Icons.arrow_back,
                                      color: Colors.white),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 5.0, left: 40),
                                  child: SizedBox(
                                    height: 35,
                                    width: 40,
                                    child: Container(
                                      color: Colors.white70,
                                      child:
                                          Image.asset('assets/home_logo.png'),
                                    ),
                                  ),
                                )
                                // Padding(
                                //   padding: const EdgeInsets.only(top: 5.0),
                                //   child: SizedBox(
                                //     height: 30,
                                //     width: 100,
                                //     child: Image.asset('assets/logo_dark.png'),
                                //   ),
                                // )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 50.0),
                              child: Text(
                                'BloodPool Login',
                                style: GoogleFonts.poppins(
                                    fontSize: 17,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Text(
                                'Help',
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            )
                          ],
                        )),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 20.5,
                        ),
                        Text(
                          'Login To Find Blood',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: h / 20.5,
                        ),
                        _buildNameTF(),
                        const SizedBox(
                          height: 25.0,
                        ),
                        _buildPasswordTF(),
                        const SizedBox(
                          height: 15,
                        ),
                        _buildLoginBtn(),
                        const SizedBox(
                          height: 15,
                        ),
                        _buildRegisterBtn(),
                        // _buildForgotPasswordBtn(),
                        // // _buildRememberMeCheckbox(),
                        // _buildLoginBtn(),
                        // _buildSignInWithText(),
                        // _buildSocialBtnRow(),
                        // _buildSignupBtn(),
                        // _headerWidget(),
                        // SizedBox(
                        //   height: 10,
                        // ),
                        // _formWidget(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // child:
        ),
      ),
    ]));
  }
}
