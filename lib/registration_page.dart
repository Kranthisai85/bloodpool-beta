import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bloodpool/search_screen.dart';
import 'package:http/http.dart' as http;
import 'package:bloodpool/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imgur/imgur.dart' as imgur;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class CustomInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(
            ' '); // Replace this with anything you want to put after each 4 numbers
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}

class _RegisterScreenState extends State<RegisterScreen> {
  late String email = "";
  late String passWord = "";
  late String name = "";
  late String username = "";
  late DateTime dob;

  late String aadhar = "";
  late String bloodgroup = "";
  late String confirmPassWord = "";
  late String phone = "";
  String? imageLink;
  File? imageFile;
  bool isSubmit = false;
  String? selectedBlood;
  String? gender;
  // String? selectedBlood;
  List bloods = ['A+', 'B+', 'O+', 'AB+', 'O-'];
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  DateTime todaysDate = DateTime.now();
  DateTime? selectedDate = DateTime.now();
  ScrollController? _scrollController;

  var geolocator = Geolocator();
  Position? myLatPosition;

  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  void locateMyPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    myLatPosition = position;

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);

    position.latitude != null
        ? Fluttertoast.showToast(
            msg: "${position.latitude},${position.longitude}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0)
        : null;

    // position.latitude != null ? updateLocation() : null;

    // CameraPosition cameraPosition =
    //     CameraPosition(target: latLatPosition, zoom: 15);

    // newGoogleMapController!
    //     .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  // void updateLocation() async {
  //   final response = await http.post(
  //     Uri.parse(
  //         'https://3062-2401-4900-5082-8ab1-d9b6-da9f-633d-24cf.ngrok.io/update/location/'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(<String, String>{
  //       "latitude": myLatPosition!.latitude.toString(),
  //       "longitude": myLatPosition!.longitude.toString()
  //     }),
  //   );

  //   if (response.statusCode == 200) {
  //     Fluttertoast.showToast(msg: ' We have got you!');
  //   }
  // }

  @override
  void initState() {
    super.initState();
    selectedDate = todaysDate;
    locateMyPosition();
  }

  Widget _buildNameTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Name',
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
              fontFamily: 'OpenSans',
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.person,
                color: Colors.white,
                size: 24,
              ),
              hintText: 'Enter your Full Name',
              hintStyle: TextStyle(
                color: Colors.white54,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserNameTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'UserName',
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
                username = value;
              });
            },
            keyboardType: TextInputType.name,
            controller: usernameController,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon:
                  Icon(Icons.person_add_alt_1, color: Colors.white, size: 24),
              hintText: 'Create your UserName',
              hintStyle: TextStyle(
                color: Colors.white54,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
        ),
        if ((usernameController.text.isNotEmpty &&
            usernameController.text.length > 4 &&
            !RegExp(r"^[a-z0-9_\-]+$").hasMatch(usernameController.text)))
          const Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: Text(
              '  Enter Small Cases Without Numbers',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans',
              ),
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: Text(''),
          )
      ],
    );
  }

  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Email',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
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
                email = value;
              });
            },
            controller: emailController,
            // validator: emailValidator,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 14.0),
              prefixIcon: const Icon(Icons.email_rounded,
                  size: 24, color: Colors.white),
              hintText: 'Enter your Email',
              hintStyle: GoogleFonts.openSans(
                fontSize: 15,
                color: Colors.white60,
                // fontWeight: FontWeight.w600
              ),
            ),
          ),
        ),
        if ((emailController.text.isNotEmpty &&
                emailController.text.length > 4 &&
                !RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                    .hasMatch(emailController.text)) &&
            (emailController.text.isNotEmpty &&
                emailController.text.length > 4 &&
                !RegExp(r"^[6-9]\d{9}$").hasMatch(emailController.text)))
          const Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: Text(
              '  Enter Valid Email',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans',
              ),
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: Text(''),
          )
      ],
    );
  }

  Widget _buildPhoneTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Phone',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
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
                phone = value;
              });
            },
            controller: phoneController,
            // validator: emailValidator,
            keyboardType: TextInputType.phone,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 14.0),
              prefixIcon:
                  // phoneController.text.isNotEmpty &&
                  !RegExp(r"^[6-9]\d{9}$").hasMatch(phoneController.text) ||
                          phone == ""
                      ? Icon(
                          phone != ""
                              ? !RegExp(r'^\d+(?:\.\d+)?$').hasMatch(phone)
                                  ? Icons.local_phone_rounded
                                  : Icons.local_phone_rounded
                              : Icons.local_phone_rounded,
                          color: Colors.white,
                          size: 24,
                        )
                      : const Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Text(
                            '+91',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
              // prefixIcon: Icon(
              //   Icons.email,
              //   color: Colors.white,
              // ),
              hintText: 'Enter your Phone',
              hintStyle: GoogleFonts.openSans(
                fontSize: 15,
                color: Colors.white60,
                // fontWeight: FontWeight.w600
              ),
            ),
          ),
        ),
        if ((phoneController.text.isNotEmpty &&
                phoneController.text.length > 4 &&
                !RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                    .hasMatch(phoneController.text)) &&
            (phoneController.text.isNotEmpty &&
                phoneController.text.length > 4 &&
                !RegExp(r"^[6-9]\d{9}$").hasMatch(phoneController.text)))
          const Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: Text(
              '  Enter Valid Phone',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans',
              ),
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: Text(''),
          )
      ],
    );
  }

  _selectDate(BuildContext context) async {
    // print((selectedDate.year - 18));
    // print((selectedDate.month));
    // print((selectedDate.day));
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime((todaysDate.year - 18), (todaysDate.month), 01),
      firstDate: DateTime(todaysDate.year - 50),
      lastDate: DateTime(todaysDate.year - 18, todaysDate.month),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Widget _buildDateOfBirth() {
    return Container(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Date Of Birth',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
            ),
          ),
          const SizedBox(height: 10.0),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
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
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 12.0, top: 8, bottom: 8),
                    child: Icon(Icons.date_range_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 2.0),
                    child: Text(
                      "${selectedDate!.toLocal()}".split(' ')[0],
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAadharTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Aadhar card',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
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
            // maxLength: 16,
            onChanged: (value) {
              setState(() {
                aadhar = value;
              });
            },
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CustomInputFormatter(),
            ],
            // controller: phoneController,
            // validator: emailValidator,
            keyboardType: TextInputType.phone,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 14.0),
              prefixIcon: const Padding(
                padding:
                    EdgeInsets.only(left: 13.0, right: 8, bottom: 8, top: 14),
                child: FaIcon(FontAwesomeIcons.idCard,
                    color: Colors.white, size: 20),
              ),
              hintText: 'Enter your Aadhar Card Number',
              hintStyle: GoogleFonts.openSans(
                fontSize: 15,
                color: Colors.white60,
                // fontWeight: FontWeight.w600
              ),
            ),
          ),
        ),
        if ((aadhar.isNotEmpty &&
            aadhar.length > 4 &&
            !RegExp(r"^[0-9]{4}[ -]?[0-9]{4}[ -]?[0-9]{4}$").hasMatch(aadhar)))
          const Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: Text(
              '  Enter Valid Aadhar',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans',
              ),
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: Text(''),
          )
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
            fontFamily: 'OpenSans',
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
                  size: 24,
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
        passWord != ""
            ? 3 < passWord.length && passWord.length < 8 || passWord.length > 16
                ? const Text(
                    "  Password must be between 8 to 15",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'OpenSans',
                    ),
                  )
                : !RegExp('(.*[A-Z].*)').hasMatch(passWord) &&
                        4 < passWord.length
                    ? const Text(
                        "  Password must have atleast 1 capital letter",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'OpenSans',
                        ),
                      )
                    : !RegExp('(.*[a-z].*)').hasMatch(passWord) &&
                            4 < passWord.length
                        ? const Text(
                            "  Password must have atleast 1 lower case letter",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'OpenSans',
                            ),
                          )
                        : !RegExp('.*[0-9].*').hasMatch(passWord) &&
                                4 < passWord.length
                            ? const Text(
                                "  Password must have atleast 1 number",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'OpenSans',
                                ),
                              )
                            : const Text('')
            : const Text('')
      ],
    );
  }

  Widget _buildConfirmPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Confirm Password',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
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
                confirmPassWord = value;
              });
              if (passWord == confirmPassWord) {
                Fluttertoast.showToast(
                  msg: 'Click Register to Search',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM_LEFT,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.greenAccent,
                  textColor: Colors.white,
                );
              }
            },
            controller: confirmpasswordController,
            // validator: confirmPasswordValidator,
            // autovalidateMode: AutovalidateMode.onUserInteraction,
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
                size: 24,
              ),
              hintText: 'Enter Password Again',
              hintStyle: TextStyle(
                color: Colors.white54,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
        ),
        passwordController.text != confirmpasswordController.text &&
                confirmPassWord.isNotEmpty
            ? const Text(
                "  Password does not match",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'OpenSans',
                ),
              )
            : const Text("")
      ],
    );
  }

  uploadPhoto(String imageFilePath) async {
    final client = imgur.Imgur(imgur.Authentication.fromToken(
        '833904ad3cf8ff0e456f21cbf3370277684d3843'));
    await client.image
        .uploadImage(
            imagePath: imageFilePath, title: name, description: 'profile photo')
        .then((image) => {
              print('Uploaded image to: ${image.link}'),
              setState(() {
                imageLink = image.link;
              })
            });
  }

  void _getFromGallery() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    try {
      setState(() {
        imageFile = File(pickedFile.path);
        print(imageFile);
        // uploadPhoto(imageFile!.path);
      });
    } catch (err) {
      print("error while selecting");
      print(err);
    }
  }

  Widget _buildImageTF() {
    return Container(
        // margin: const EdgeInsets.all(10.0),
        decoration: const BoxDecoration(
            // color: Colors.grey,
            // shape: BoxShape.circle,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: imageFile == null
            ? Stack(children: [
                Container(
                  height: 130.0,
                  width: 130.0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white54,
                  ),
                  alignment: Alignment.center,
                  child: const FaIcon(FontAwesomeIcons.userCircle,
                      color: Colors.white70, size: 80),
                ),
                GestureDetector(
                    onTap: () => _getFromGallery(),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 95.0, left: 95),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 25,
                          width: 25,
                          color: Colors.blue,
                          child: Column(
                            children: const [
                              Padding(
                                padding: EdgeInsets.only(top: 3.0),
                                child: Icon(
                                  Icons.edit_rounded,
                                  color: Colors.white,
                                  size: 19,
                                ),
                              ),
                              // Text('Camera',
                              //     style: TextStyle(color: Colors.white))
                            ],
                          ),
                        ),
                      ),
                    )),
              ])
            : Stack(children: [
                Container(
                    height: 130.0,
                    width: 130.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(
                          imageFile!,
                        ),
                        fit: BoxFit.cover,
                      ),
                      shape: BoxShape.circle,
                    )),
                GestureDetector(
                    onTap: () => _getFromGallery(),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 95.0, left: 95),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 25,
                          width: 25,
                          color: Colors.blue,
                          child: Column(
                            children: const [
                              Padding(
                                padding: EdgeInsets.only(top: 3.0),
                                child: Icon(
                                  Icons.edit_rounded,
                                  color: Colors.white,
                                  size: 19,
                                ),
                              ),
                              // Text('Camera',
                              //     style: TextStyle(color: Colors.white))
                            ],
                          ),
                        ),
                      ),
                    )),
              ]));
  }

  Widget _buildBloodTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.elliptical(20, 20)),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red.shade800,
              // border: Border.all(color: Colors.white70, width: 1),
            ),
            child: DropdownButton(
                elevation: 10,
                underline: const SizedBox(),
                borderRadius: const BorderRadius.all(Radius.circular(17)),
                alignment: Alignment.center,
                icon: const Icon(Icons.arrow_drop_down_circle),
                iconEnabledColor: Colors.white70,
                dropdownColor: Colors.red.shade800,
                value: selectedBlood,
                // elevation: 5,
                items: const [
                  DropdownMenuItem(
                    child: Text("A+", style: TextStyle(color: Colors.white)),
                    value: 'A+',
                  ),
                  DropdownMenuItem(
                    child: Text("B+", style: TextStyle(color: Colors.white)),
                    value: 'B+',
                  ),
                  DropdownMenuItem(
                    child: Text("O+", style: TextStyle(color: Colors.white)),
                    value: 'O+',
                  ),
                  DropdownMenuItem(
                    child: Text("AB+", style: TextStyle(color: Colors.white)),
                    value: 'AB+',
                  ),
                  DropdownMenuItem(
                    child: Text("O-", style: TextStyle(color: Colors.white)),
                    value: 'O-',
                  )
                ],
                onChanged: (String? value) {
                  setState(() {
                    selectedBlood = value;
                  });
                },
                hint: const Text(
                  "   Blood Group   ",
                  style: TextStyle(color: Colors.white),
                )),
          ),
        ),
      ],
    );
  }

  DropdownMenuItem buildMenuItem(String item) {
    return DropdownMenuItem(
      value: item,
      child: Text(
        item,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }

  void _scrollToTop() {
    _scrollController?.animateTo(0,
        duration: const Duration(seconds: 3), curve: Curves.linear);
  }

  Widget _buildRegisterBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.white,
          elevation: 5.0,
          padding: const EdgeInsets.all(15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        onPressed: () async {
          if (File(imageFile?.path ?? '').existsSync()) {
            await uploadPhoto(imageFile!.path);
            if (selectedBlood != null) {
              if (name.isNotEmpty &&
                  username.isNotEmpty &&
                  aadhar.isNotEmpty &&
                  confirmPassWord.isNotEmpty &&
                  selectedDate != todaysDate &&
                  passWord.isNotEmpty &&
                  gender != null &&
                  email.isNotEmpty &&
                  phone.isNotEmpty) {
                Fluttertoast.showToast(
                  msg: 'Clicked on register button. Please wait for Response',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM_LEFT,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.greenAccent,
                  textColor: Colors.white,
                );
                validate();
              } else {
                Fluttertoast.showToast(
                  msg: 'Fill all given fields!',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM_LEFT,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.greenAccent,
                  textColor: Colors.white,
                );
              }
            } else {
              _scrollToTop();
              Fluttertoast.showToast(
                msg: 'Select Your Bloodgroup!',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM_LEFT,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.greenAccent,
                textColor: Colors.white,
              );
            }
          } else {
            _scrollToTop();
            Fluttertoast.showToast(
              msg: 'Upload Image',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM_LEFT,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.redAccent,
              textColor: Colors.white,
            );
          }
          // print(imageFile!.path),
          // print(selectedBlood),
          // print(name),
          // print(username),
          // print(email),
          // print(phone),
          // print(selectedDate),
          // print(aadhar),
          // print(passWord),
          // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          //   content: Text("Development in Progress\nCome back later..."),
          // ))
        },
        child: const Text(
          'REGISTER',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  validate() async {
    // print();
    var age = (todaysDate.year - selectedDate!.year);
    addEmailtoSF() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('email', email);
    }

    addUsernametoSF() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('username', name);
    }

    addPasswordtoSF() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('password', passWord);
    }

    addMobiletoSF() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('mobile', phone);
    }

    final response = await http.post(
      Uri.parse('https://bloodpool-backend.herokuapp.com/store'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "username": username,
        "password": passWord,
        "name": name,
        "email": email,
        "bloodgroup": selectedBlood!,
        "age": "$age",
        "gender": "$gender",
        "photo": '$imageLink',
        "aadharno": aadhar.replaceAll(' ', ''),
        "mobilenumber": phone,
        "latitude": myLatPosition!.latitude.toString(),
        "longitude": myLatPosition!.longitude.toString()
      }),
    );

    if (response.statusCode == 200) {
      addEmailtoSF();
      addPasswordtoSF();
      addUsernametoSF();
      addMobiletoSF();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Registered Succesfully"),
      ));
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SearchScreen(
                  username: username,
                )),
      );
    } else {
      print(response.body);
      Fluttertoast.showToast(
        msg: 'Error Registering.. Try again',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM_LEFT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.greenAccent,
        textColor: Colors.white,
      );
    }
  }

  Widget _buildSignupBtn() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LogInPage()),
      ),
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //   content: Text("Development in Progress\nCome back later..."),
      // )),
      // onTap: () => {gotoLogin(context)},
      child: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'Already Registered? ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Log in',
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

  Widget _buildGender() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 24.0, left: 8),
        child: Container(
          height: 55,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 30),
            child: SizedBox(
              child: DropdownButton(
                // itemHeight:20,
                elevation: 10,
                menuMaxHeight: 100,
                isExpanded: true,
                underline: const SizedBox(),
                alignment: Alignment.center,
                // icon: const Icon(Icons.arrow_drop_down_circle),
                iconEnabledColor: Colors.white,
                dropdownColor: Colors.black45,
                value: gender,
                items: const [
                  DropdownMenuItem(
                    child: Text("Male",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w800)),
                    value: 'Male',
                  ),
                  DropdownMenuItem(
                    child: Text("Female",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w800)),
                    value: 'Female',
                  ),
                  DropdownMenuItem(
                    child: Text("Others",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w800)),
                    value: 'Transgender',
                  ),
                ],
                onChanged: (String? value) {
                  setState(() {
                    gender = value!;
                  });
                },
                hint: const Text('Gender',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.normal)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // extendBodyBehindAppBar:true,
        // backgroundColor: Color(0xff1a1a1a),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Form(
              key: formkey,
              child: Stack(
                children: <Widget>[
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.red,
                          Colors.red.withOpacity(0.5),
                          Colors.blue.withOpacity(0.5),
                          Colors.blue,
                        ],
                        stops: const [0.1, 0.6, 0.7, 0.9],
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.black26,
                  ),
                  SizedBox(
                    height: double.infinity,
                    child: SingleChildScrollView(
                      // reverse: true,
                      // physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 15.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
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
                                      padding: const EdgeInsets.only(
                                          top: 5.0, left: 40),
                                      child: SizedBox(
                                        height: 35,
                                        width: 40,
                                        child: Container(
                                          color: Colors.white70,
                                          child: Image.asset(
                                              'assets/home_logo.png'),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 50.0),
                                  child: Text(
                                    'BloodPool Register',
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
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                )
                              ],
                            ),
                          ),
                          // SizedBox(
                          //   height: 30,
                          // ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 21,
                          ),
                          Text(
                            'Register With Us...',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          _buildImageTF(),
                          const SizedBox(height: 10.0),
                          _buildBloodTF(),
                          const SizedBox(height: 10.0),
                          _buildNameTF(),
                          const SizedBox(height: 20.0),
                          _buildUserNameTF(),
                          const SizedBox(height: 8.0),
                          _buildEmailTF(),
                          const SizedBox(height: 8.0),
                          _buildPhoneTF(),
                          const SizedBox(height: 8.0),
                          Row(
                            children: [
                              _buildDateOfBirth(),
                              _buildGender(),
                            ],
                          ),
                          const SizedBox(height: 15.0),
                          _buildAadharTF(),
                          const SizedBox(height: 10.0),
                          _buildPasswordTF(),
                          const SizedBox(height: 15.0),
                          _buildConfirmPasswordTF(),
                          const SizedBox(
                            height: 15,
                          ),
                          // const SizedBox(height: 5.0),
                          _buildRegisterBtn(),
                          const SizedBox(height: 5.0),
                          // _buildSignInWithText(),
                          // _buildSocialBtnRow(),
                          _buildSignupBtn(),
                          const SizedBox(
                            height: 50,
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


 // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   children: <Widget>[

                  //     // ElevatedButton(
                  //     //   style: ElevatedButton.styleFrom(
                  //     //     primary: Colors.greenAccent,
                  //     //   ),
                  //     //   onPressed: () {
                  //     //     _getFromGallery();
                  //     //   },
                  //     //   child: const Text("PICK FROM GALLERY"),
                  //     // ),
                  //     // Container(
                  //     //   height: 40.0,
                  //     // ),
                  //     // ElevatedButton(
                  //     //   style: ElevatedButton.styleFrom(
                  //     //     primary: Colors.lightGreenAccent,
                  //     //   ),
                  //     //   onPressed: () {
                  //     //     _getFromCamera();
                  //     //   },
                  //     //   child: const Text("PICK FROM CAMERA"),
                  //     // )
                  //     // GestureDetector(
                  //     //     onTap: () => _getFromCamera(),
                  //     //     child: Column(
                  //     //       children: const [
                  //     //         Icon(
                  //     //           Icons.camera_alt_rounded,
                  //     //           color: Colors.blue,
                  //     //         ),
                  //     //         Text('Camera',
                  //     //             style: TextStyle(color: Colors.white))
                  //     //       ],
                  //     //     )),
                  //   ],
                  // ),

                    // Color(0xff1a1a1a),
                        // Color(0xff1a1a1a),
                        // Color(0xff1a1a1a),
                        // Color(0xff1a1a1a),
                        // Color(0xFF73AEF5),
                        // Color(0xFF61A4F1),
                        // Color(0xFF478DE0),
                        // Color(0xFF398AE5),

                        // color:Colors.red.shade800,
            // decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //         begin: Alignment.topCenter,
            //         end: Alignment.bottomCenter,
            //         colors: [
            //       Colors.red,
            //       Colors.red.withOpacity(0.5),
            //       Colors.blue.withOpacity(0.5),
            //       Colors.blue,
            //     ])),

            /// Get from Camera
  // _getFromCamera() async {
  //   PickedFile? pickedFile = await ImagePicker().getImage(
  //     source: ImageSource.camera,
  //     maxWidth: 1800,
  //     maxHeight: 1800,
  //   );
  //   if (pickedFile != null) {
  //     setState(() {
  //       imageFile = File(pickedFile.path);
  //     });
  //   }
  // }

  // ElevatedButton(
        //     onPressed: () => _selectDate(context), // Refer step 3
        //     child: const Text(
        //       'Pick Date',
        //       style:
        //           TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        //     ),
        //     style: ElevatedButton.styleFrom(primary: Colors.black,)
        //   ),

        //   child: TextFormField(
            //     onChanged: (value) {
            //       setState(() {
            //         dob = value;
            //       });
            //     },
            //     // keyboardType: TextInputType.datetime,
            //     controller: dobController,
            //     style: const TextStyle(
            //       color: Colors.white,
            //       fontFamily: 'OpenSans',
            //     ),
            //     decoration: const InputDecoration(
            //       border: InputBorder.none,
            //       contentPadding: EdgeInsets.only(top: 14.0),
            //       prefixIcon: Icon(
            //         Icons.person,
            //         color: Colors.white,
            //       ),
            //       hintText: 'Enter your Full Name',
            //       hintStyle: TextStyle(
            //         color: Colors.white54,
            //         fontFamily: 'OpenSans',
            //       ),
            //     ),
            //   ),
            // ),

            // if ((email.isNotEmpty &&
        //     email.length > 3 &&
        //     !RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(email)))
        //   new Text(
        //     '  Enter Valid Email/Phone',
        //     style: kInvalidStyle,
        //   )
        // else
        //   Text('')

        // if ((email.isNotEmpty &&
        //     email.length > 3 &&
        //     !RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(email)))
        //   new Text(
        //     '  Enter Valid Email/Phone',
        //     style: kInvalidStyle,
        //   )
        // else
        //   Text('')

        // emailController.text.isNotEmpty&
              //         !RegExp(r"^[6-9]\d{9}$").hasMatch(emailController.text)
              //     ? Icon(
              //         email!= ""
              //             ? !RegExp(r'^\d+(?:\.\d+)?$').hasMatch(email)
              //                 ? Icons.email
              //                 : !RegExp(r"^[6-9]\d{9}$").hasMatch(emailController.text) ? Icons.local_phone_rounded : Icons.email_rounded
              //             : Icons.email,
              //         color: Colors.white,
              //       )
              //     : const Padding(
              //         padding: EdgeInsets.only(top: 16.0, left: 10),
              //         child: Text(
              //           '+91',
              //           style: TextStyle(
              //               color: Colors.white,
              //               fontSize: 14,
              //               fontWeight: FontWeight.bold),
              //         ),
              //       ),
              // prefixIcon: Icon(
              //   Icons.email,
              //   color: Colors.white,
              // ),