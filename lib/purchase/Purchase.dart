import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vrst/common/global.dart' as global;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:core';
import 'dart:convert';
import 'dart:io';
import 'package:vrst/purchase/billEntryForm.dart';

class Purchase extends StatefulWidget {
  @override
  _PurchaseState createState() => _PurchaseState();
}

class _PurchaseState extends State<Purchase> {
  final _formKey = GlobalKey<FormState>();
  String stateDropdownValue = 'Select State';
  String distributorDropdownValue = 'Select Distributor';
  String billDate;
  TextEditingController _billDate;
  List _states = List();
  List _distributor = List();

  TextEditingController _billController;
  static List<String> friendsList = [null];

  File _image;
  final picker = ImagePicker();

  void initState() {
    _getstates();
    _getdistributors();
    _billDate = TextEditingController();
    super.initState();
  }

  void _getstates() async{
    String url = global.baseUrl + 'get-states';
    http.Response resposne = await http.get(url);
    int statusCode = resposne.statusCode;
    if(statusCode == 200){
      setState(() {
        _states = jsonDecode(resposne.body);
        stateDropdownValue = _states[0]['state_code'];
      });
    }
  }

  void _getdistributors() async{
    String url = global.baseUrl + 'get-distributors';
    http.Response resposne = await http.get(url);
    int statusCode = resposne.statusCode;
    if(statusCode == 200){
      setState(() {
        _distributor = jsonDecode(resposne.body);
        distributorDropdownValue = _distributor[0]['DealerId'];
      });
    }
  }

  _imgFromCamera() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  _imgFromGallery() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = image;
    });
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

  @override
  void dispose() {
    _billController.dispose();
    super.dispose();
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void _submit() {
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();
      _purchaseSuccess();
    }
  }

  Future<void> _purchaseSuccess() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Purchase Success!',textAlign: TextAlign.center,),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You successfully Submit the purchase order.',textAlign: TextAlign.center,),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                //Navigator.of(context).pop();
                Navigator.pop(context);
                Navigator.pushNamed(context, '/dashboard');
                setState(() {
                  //loader = false;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _billDateWidget() {
    return TextFormField(
      controller: _billDate,
      readOnly: true,
      decoration: InputDecoration(
          labelText: 'Select Date',
          suffixIcon: GestureDetector(
            onTap: () => {
              showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2021, 2),
                lastDate: DateTime(2022, 12),
              ).then((selectedDate) {
                if (selectedDate != null) {
                  final DateTime now = selectedDate;
                  final DateFormat formatter = DateFormat('dd/MM/yyyy');
                  final String formatted = formatter.format(now);
                  setState(() {
                    _billDate.text = formatted;
                    print(formatted);
                  });
                }
              })
            },
            child: Icon(Icons.calendar_today),
          )),
      onSaved: (String value) {
        billDate = value;
      },
      validator: (String value) {
        if (value.isEmpty) {
          return 'Select date';
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PURCHASE ORDER'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                Card(
                  elevation: 10,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField(
                            hint: Text('Select Distributor'),
                            items: _distributor.map((item) {
                              return DropdownMenuItem<String>(
                                value: item['DealerId'].toString(),
                                child: Text(item['DealerName']),
                              );
                            }).toList(),
                            onChanged: (String newValue) {
                              setState(() {
                                distributorDropdownValue = newValue;
                              });
                            },
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Enter Bill Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          validator: (value){
                            if(value.isEmpty){
                              return 'Please enter Bill no.';
                            }
                          },
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: new Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: _billDateWidget(),
                              ),
                            ),
                            Expanded(
                              child: new Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: GestureDetector(
                                  onTap: () {
                                    _showPicker(context);
                                  },
                                  child: CircleAvatar(
                                    radius: 45,
                                    backgroundColor: Color(0xffFDCF09),
                                    child: _image != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: Image.file(
                                              _image,
                                              width: 100,
                                              height: 300,
                                              fit: BoxFit.fitHeight,
                                            ),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            width: 100,
                                            height: 300,
                                            child: Icon(
                                              Icons.camera_alt,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            Divider(
                                color: Colors.black,
                                height: 2.0,
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),

                        BillEntryForm(),

                        RaisedButton(
                            color: Colors.lightGreen,
                            splashColor: Colors.red,
                            child: Text(
                              'SUBMIT',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            onPressed: _submit),
                      ],
                    ),
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
