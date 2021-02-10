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

class ReturnOrder extends StatefulWidget {
  @override
  _ReturnOrderState createState() => _ReturnOrderState();
}


class _ReturnOrderState extends State<ReturnOrder> {
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
    super.initState();
  }

  void _getstates() async{
    print('getstates function called.');
    String url = global.baseUrl + 'get-bill';
    http.Response resposne = await http.get(url);
    int statusCode = resposne.statusCode;
    print(statusCode);
    if(statusCode == 200){
      setState(() {
        _states = jsonDecode(resposne.body);
        stateDropdownValue = _states[0]['bill_id'];
        print(_states);
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

  // @override
  // void dispose() {
  //   _billController.dispose();
  //   super.dispose();
  // }

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
    }
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
        title: Text('RETURN ORDER'),
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
                            hint: Text('Select Your Order'),
                            items: _states.map((item) {
                              return DropdownMenuItem<String>(
                                value: item['bill_id'].toString(),
                                child: Text(item['bill_no']),
                              );
                            }).toList(),
                            onChanged: (String newValue) {
                              setState(() {
                                stateDropdownValue = newValue;
                              });
                            },
                            validator: (value){
                              if(value != 0){
                                return 'Please select State';
                              }
                            }
                        ),
                        SizedBox(
                          height: 10.0,
                        ),

                        RaisedButton(
                            color: Colors.lightGreen,
                            splashColor: Colors.red,
                            child: Text(
                              'SEARCH',
                              style:
                              TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            onPressed: _submit
                        ),

                        ..._getFriends(),
                        SizedBox(
                          height: 10,
                        ),
                        RaisedButton(
                            color: Color(0xFFf09a3e),
                            splashColor: Colors.red,
                            child: Text(
                              'UPDATE',
                              style:
                              TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            onPressed: _submit
                        ),
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
            Expanded(child: CropTextFields(i)),
            Expanded(child: CropTypeTextFields(i)),
            Expanded(child: CropQuantityTextFields(i)),
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
        width: 23,
        height: 23,
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


class CropTextFields extends StatefulWidget {
  final int index;
  CropTextFields(this.index);

  @override
  _CropTextFieldsState createState() => _CropTextFieldsState();
}

class _CropTextFieldsState extends State<CropTextFields> {
  TextEditingController _cropController;
  String cropDropdownValue = 'Crop';
  List _crop = List();

  @override
  void initState() {
    super.initState();
    _getcrop();
    _cropController = TextEditingController();
  }

  @override
  void dispose() {
    _cropController.dispose();
    super.dispose();
  }

  void _getcrop() async{
    String url = global.baseUrl + 'get-cropList';
    http.Response resposne = await http.get(url);
    int statusCode = resposne.statusCode;
    if(statusCode == 200){
      setState(() {
        _crop = jsonDecode(resposne.body);
        cropDropdownValue = _crop[0]['crop_id'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _cropController.text = _ReturnOrderState.friendsList[widget.index] ?? '';
    });

    return DropdownButton<String>(
      value: cropDropdownValue,
      onChanged: (String newValue) {
        setState(() {
          cropDropdownValue = newValue;
        });
      },
      items: _crop.map((item) {
        return DropdownMenuItem<String>(
          value: item['crop_code'].toString(),
          child: Text(item['crop_name']),
        );
      }).toList(),
    );
  }
}


class CropTypeTextFields extends StatefulWidget {
  final int index;
  CropTypeTextFields(this.index);
  @override
  _CropTypeTextFieldsState createState() => _CropTypeTextFieldsState();
}

class _CropTypeTextFieldsState extends State<CropTypeTextFields> {
  TextEditingController _cropTypeController;
  String cropDropdownValue = 'Variety';
  List _cropVariety = List();

  @override
  void initState() {
    super.initState();
    _getcropVariety();
    _cropTypeController = TextEditingController();
  }

  @override
  void dispose() {
    _cropTypeController.dispose();
    super.dispose();
  }

  void _getcropVariety() async{
    String url = global.baseUrl + 'get-cropvariety';
    http.Response resposne = await http.get(url);
    int statusCode = resposne.statusCode;
    if(statusCode == 200){
      setState(() {
        _cropVariety = jsonDecode(resposne.body);
        cropDropdownValue = _cropVariety[0]['crop_variety_id'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _cropTypeController.text = _ReturnOrderState.friendsList[widget.index] ?? '';
    });
    String dropdownValue = 'Variety';

    return DropdownButton<String>(
      value: dropdownValue,
      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
        });
      },
      items: <String>['Variety','One', 'Two', 'Free', 'Four']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
    // return TextFormField(
    //   controller: _cropTypeController,
    //   onChanged: (v) => _PurchaseState.friendsList[widget.index] = v,
    //   //decoration: InputDecoration(hintText: 'Crop Type'),
    //   decoration: InputDecoration(
    //     labelText: 'Variety',
    //     border: OutlineInputBorder(
    //       borderRadius: BorderRadius.circular(10.0),
    //       borderSide: BorderSide(
    //         color: Colors.blue,
    //       ),
    //     ),
    //   ),
    //   validator: (v) {
    //     if (v.trim().isEmpty) return 'Varity';
    //     return null;
    //   },
    // );
  }
}


class CropQuantityTextFields extends StatefulWidget {
  final int index;
  CropQuantityTextFields(this.index);
  @override
  _CropQuantityTextFieldsState createState() => _CropQuantityTextFieldsState();
}

class _CropQuantityTextFieldsState extends State<CropQuantityTextFields> {
  TextEditingController _cropQuantityController;

  @override
  void initState() {
    super.initState();
    _cropQuantityController = TextEditingController();
  }

  @override
  void dispose() {
    _cropQuantityController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _cropQuantityController.text = _ReturnOrderState.friendsList[widget.index] ?? '';
    });

    return TextFormField(
      controller: _cropQuantityController,
      onChanged: (v) => _ReturnOrderState.friendsList[widget.index] = v,
      decoration: InputDecoration(
          hintText: 'Qty(gm)'
      ),
      // decoration: InputDecoration(
      //   labelText: 'Qty (gm)',
      //   border: OutlineInputBorder(
      //     borderRadius: BorderRadius.circular(10.0),
      //     borderSide: BorderSide(
      //       color: Colors.blue,
      //     ),
      //   ),
      // ),
      validator: (v) {
        if (v.trim().isEmpty) return 'Qunatity';
        return null;
      },
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
      _nameController.text = _ReturnOrderState.friendsList[widget.index] ?? '';
    });

    return TextFormField(
      controller: _nameController,
      onChanged: (v) => _ReturnOrderState.friendsList[widget.index] = v,
      decoration: InputDecoration(hintText: 'Enter your friend\'s name'),
      validator: (v) {
        if (v.trim().isEmpty) return 'Please enter something';
        return null;
      },
    );
  }
}
