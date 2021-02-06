import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vrst/common/global.dart' as global;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:core';
import 'dart:io';

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

  TextEditingController _billController;
  static List<String> friendsList = [null];

  File _image;
  final picker = ImagePicker();

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

  Widget _buildLeaveFrom() {
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
                  _billDate.text = formatted;
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
                        DropdownButton<String>(
                          value: stateDropdownValue ?? null,
                          onChanged: (String newValue) {
                            setState(() {
                              stateDropdownValue = newValue;
                            });
                          },
                          isExpanded: true,
                          hint: Text('Select State'),
                          items: <String>[
                            'Select State',
                            'One',
                            'Two',
                            'Free',
                            'Four'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        DropdownButton<String>(
                          value: distributorDropdownValue ?? null,
                          onChanged: (String newValue) {
                            setState(() {
                              distributorDropdownValue = newValue;
                            });
                          },
                          isExpanded: true,
                          hint: Text('Select Distributor'),
                          items: <String>[
                            'Select Distributor',
                            'One',
                            'Two',
                            'Free',
                            'Four'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
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
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Expanded(
                              child: new Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: _buildLeaveFrom(),
                              ),
                            ),
                            Expanded(
                              child: new Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: GestureDetector(
                                  onTap: () {
                                    _showPicker(context);
                                  },
                                  child: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Color(0xffFDCF09),
                                    child: _image != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: Image.file(
                                              _image,
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.fitHeight,
                                            ),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            width: 100,
                                            height: 100,
                                            child: Icon(
                                              Icons.camera_alt,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        ..._getFriends(),
                        SizedBox(
                          height: 10,
                        ),
                        RaisedButton(
                            color: Colors.lightGreen,
                            splashColor: Colors.red,
                            child: Text(
                              'SUBMIT',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            onPressed: () {}),
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

  /// get firends text-fields
  List<Widget> _getFriends() {
    List<Widget> friendsTextFields = [];
    for (int i = 0; i < friendsList.length; i++) {
      friendsTextFields.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            Expanded(child: FriendTextFields(i)),
            Expanded(child: FriendTextFields(i)),
            Expanded(child: FriendTextFields(i)),
            //SizedBox(width: 16,),
            // we need add button at last friends row
            _addRemoveButton(i == friendsList.length - 1, i),
          ],
        ),
      ));
    }
    return friendsTextFields;
  }

  Widget _addRemoveButton(bool add, int index) {
    return InkWell(
      onTap: () {
        if (add) {
          // add new text-fields at the top of all friends textfields
          friendsList.insert(0, null);
        } else
          friendsList.removeAt(index);
        setState(() {});
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: (add) ? Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          (add) ? Icons.add : Icons.remove,
          color: Colors.white,
        ),
      ),
    );
  }
}

class FriendTextFields extends StatefulWidget {
  final int index;
  FriendTextFields(this.index);
  @override
  _FriendTextFieldsState createState() => _FriendTextFieldsState();
}

class _FriendTextFieldsState extends State<FriendTextFields> {
  TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _nameController.text = _PurchaseState.friendsList[widget.index] ?? '';
    });

    return TextFormField(
      controller: _nameController,
      onChanged: (v) => _PurchaseState.friendsList[widget.index] = v,
      decoration: InputDecoration(hintText: 'Enter your friend\'s name'),
      validator: (v) {
        if (v.trim().isEmpty) return 'Please enter something';
        return null;
      },
    );
  }
}
