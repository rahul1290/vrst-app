import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vrst/common/drawer.dart';
// import 'package:vrst/purchase/bilEntry.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vrst/common/global.dart' as global;
import 'dart:async';
import 'dart:core';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
import 'package:vrst/dbhelper.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';

class Profilepage extends StatefulWidget {
  @override
  _ProfilepageState createState() => _ProfilepageState();
}

class ProfileDetail {
  String filePath;
  String name;
  String address;
  String alternetNo;
  String email;
  String pan;
  File _image;

  //ProfileDetail(this.name,this.address,this.alternetNo,this.email,this.pan,this._image);
}

class _ProfilepageState extends State<Profilepage> {
  final _formKey = GlobalKey<FormState>();
  ProfileDetail _data = new ProfileDetail();
  final dbhelper = Databasehelper.instance;
  bool loader = true;
  String profilePic;
  List _userDetail;
  @override
  void initState() {
    _getuserDetail();
    super.initState();
  }

  Future _getuserDetail() async {
    List<dynamic> userdetail = await dbhelper.get(1);
    String url = global.baseUrl + "Auth/profile_detail";
    Map<String, String> headers = {
      "Content-type": "application/x-www-form-urlencoded",
      "vrstKey": userdetail[0]['key']
    };
    http.Response response = await http.get(url, headers: headers);
    int statusCode = response.statusCode;
    if (statusCode == 200) {
      setState(() {
        loader = false;
        _userDetail = jsonDecode(response.body);
        urlToFile(global.baseUrl+'../assets/images/userprofile/'+ userdetail[0]['image'].toString() +'.jpg');
      });
    }
  }

  
  Future<File> urlToFile(String imageUrl) async {
    var rng = new Random();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = new File('$tempPath'+ (rng.nextInt(100)).toString() +'.png');
    http.Response response = await http.get(imageUrl);
    await file.writeAsBytes(response.bodyBytes);
    if(response.statusCode == 200){
      setState(() {
        _data._image = file;
      });
    }
    return file;
    }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  _imgFromGallery() async {
    // ignore: deprecated_member_use
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _data._image = image;
      _data.filePath = base64Encode(image.readAsBytesSync());
    });
  }

  _imgFromCamera() async {
    // ignore: deprecated_member_use
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _data._image = image;
      _data.filePath = base64Encode(image.readAsBytesSync());
    });
  }

  void _submit() async {
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();
      List<dynamic> userdetail = await dbhelper.get(1);
      String url = global.baseUrl + "Auth/profile_update";
      Map<String, String> headers = {
        "Content-type": "application/x-www-form-urlencoded",
        "vrstKey": userdetail[0]['key']
      };
      http.Response response = await http.post(url, headers: headers, body: {
        'name': _data.name,
        'contactNo': _data.address,
        'alternetNo': _data.alternetNo,
        'image': _data.filePath
      });
      int statusCode = response.statusCode;
      if (statusCode == 200) {
        _profileUpdateSuccess();
      }
    }
  }

  Future<void> _profileUpdateSuccess() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Profile updated!',textAlign: TextAlign.center,),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You successfully update your profile.',textAlign: TextAlign.center,),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.pushNamed(context, '/dashboard');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),
      drawer: DrawerPage(),
      body: loader
          ? Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 15.0,
                    ),
                    Text(
                      '  Loading...',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              //child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _showPicker(context);
                                },
                                child: CircleAvatar(
                                  radius: 75,
                                  backgroundColor: Colors.grey,
                                  
                                  child: _data._image != null
                                      ? ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(100),
                                          child: Image.file(
                                            _data._image,
                                            width: 300,
                                            height: 300,
                                            fit: BoxFit.fill,
                                          ),
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(100)),
                                          width: 300,
                                          height: 300,
                                          child: Icon(
                                            Icons.add_a_photo,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Enter Your Number',
                                  icon: Icon(
                                    Icons.person,
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                keyboardType: TextInputType.text,
                                initialValue: _userDetail[0]['user_name'],
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter username no.';
                                  } else {
                                    return null;
                                  }
                                },
                                onSaved: (String value) {
                                  _data.name = value;
                                },
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              TextFormField(
                                maxLines: 3,
                                decoration: InputDecoration(
                                  labelText: 'Address',
                                  icon: Icon(
                                    Icons.place,
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                initialValue: _userDetail[0]['address'],
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter Address.';
                                  } else {
                                    return null;
                                  }
                                },
                                onSaved: (String value) {
                                  _data.address = value;
                                },
                                keyboardType: TextInputType.multiline,
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Alternet Contact Number',
                                  icon: Icon(
                                    Icons.mobile_friendly_sharp,
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                initialValue: _userDetail[0]['contact_no'],
                                validator: (value) {
                                  if (value.length != 10) {
                                    return 'Please enter valid contact no';
                                  } else {
                                    return null;
                                  }
                                },
                                onSaved: (String value) {
                                  _data.alternetNo = value;
                                },
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Enter EmailID',
                                  icon: Icon(
                                    Icons.mail,
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                initialValue: _userDetail[0]['email'],
                                onSaved: (String value) {
                                  _data.email = value;
                                },
                                keyboardType: TextInputType.emailAddress,
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Enter PAN no.',
                                  icon: Icon(
                                    Icons.mail,
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                initialValue: _userDetail[0]['pan_no'],
                                onSaved: (String value) {
                                  _data.pan = value;
                                },
                                keyboardType: TextInputType.emailAddress,
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              RaisedButton(
                                onPressed: _submit,
                                child: Text('Update Profile'),
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
