import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vrst/common/drawer.dart';
import 'package:vrst/purchase/bilEntry.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vrst/common/global.dart' as global;
import 'dart:async';
import 'dart:core';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:vrst/dbhelper.dart';

class Profilepage extends StatefulWidget {
  @override
  _ProfilepageState createState() => _ProfilepageState();
}

class profileDetail {
  String name;
  String contactNo;
  String AlternetNo;
  String filePath;
  File _image;
}

class _ProfilepageState extends State<Profilepage> {
  final _formKey = GlobalKey<FormState>();
  profileDetail _data = new profileDetail();
  final dbhelper = Databasehelper.instance;

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
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _data._image = image;
      _data.filePath = base64Encode(image.readAsBytesSync());
      print(_data.filePath);
    });
  }

  _imgFromCamera() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _data._image = image;
    });
  }


  void _submit() async {
    if (this._formKey.currentState.validate()) {
      List<dynamic> userdetail = await dbhelper.get(1);
      String url = global.baseUrl + "Auth/activate_user";
      Map<String, String> headers = {
        "Content-type": "application/json",
        "vrstKey": userdetail[0]['key']
      };
      String json = '{"name":"' +
          _data.name +
          '","contactNo":"' +
          _data.contactNo +
          '","alternetNo":"' +
          _data.AlternetNo +
          '","image":"' +
          _data.filePath +
          '"}';
      http.Response response = await http.post(url, headers: headers, body: json);
      int statusCode = response.statusCode;
      Map body = jsonDecode(response.body);
      print(body);
      if(statusCode == 200){
        //_purchaseSuccess();
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),
      drawer: DrawerPage(),
      body: Container(
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
                              backgroundColor: Color(0xffFDCF09),
                              child: _data._image != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(100),
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
                                    borderRadius: BorderRadius.circular(100)),
                                width: 300,
                                height: 300,
                                child: Icon(
                                  Icons.add_a_photo,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                      ),
                      SizedBox(height: 10.0,),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Enter Your Number',
                          icon: Icon(Icons.person,color:Colors.grey,),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        initialValue: 'rahul',
                        validator: (value){
                          if(value.isEmpty){
                            return 'Please enter username no.';
                          }
                        },
                        onSaved: (String value){
                          this._data.name = value;
                        },
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        key: Key('contactno'),
                        decoration: InputDecoration(
                          labelText: 'Enter Contact Number',
                          icon: Icon(Icons.mobile_friendly_sharp,color:Colors.grey,),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        initialValue: '123',
                        validator: (value){
                          if(value.isEmpty){
                            return 'Please enter contact no.';
                          }
                          if(value.length != 10){
                            return 'Please enter valid contact no';
                          }
                        },
                        onSaved: (String value){
                          this._data.contactNo = value;
                        },
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Alternet Contact Number',
                          icon: Icon(Icons.mobile_friendly_sharp,color:Colors.grey,),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        //initialValue: '',
                        validator: (value){
                          if(value.length != 10){
                            return 'Please enter valid contact no';
                          }
                        },
                        onSaved: (String value){
                          this._data.AlternetNo = value;
                        },
                      ),

                      SizedBox(
                        height: 10.0,
                      ),
                      RaisedButton(
                          onPressed: _submit,
                          child: Text('Update Profile'),
                      ),
                    ],
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
