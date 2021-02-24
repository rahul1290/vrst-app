import 'dart:convert';
import 'package:vrst/dbhelper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final dbhelper = Databasehelper.instance;
  bool isSubmitted = false;
  int isDeleted = 0;
  String _entryId;

  @override
  void initState() {
    _getStateList();
    super.initState();
  }

  Future<void> insertData() async {
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();

      Map<String, dynamic> row = {
        Databasehelper.columnCrop: _myState,
        Databasehelper.columnVariety: _cropVarietyValue,
        Databasehelper.columnQty: _qty
      };

      await dbhelper.insertBill(row);
      List userData = await dbhelper.getallentries();
      List insertId = await dbhelper.maxId();

      setState(() {
        isSubmitted = true;
        _entryId = insertId[0]['count'].toString();
      });
    }
  }


  void deleteData() async{
    dbhelper.deleteEntriesId(int.parse(_entryId));
    List userData = await dbhelper.getallentries();
    setState(() {
      isDeleted = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              //======================================================== State
              Container(
                padding: EdgeInsets.only(left: 15, right: 15, top: 5),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: ButtonTheme(
                          alignedDropdown: true,
                          child: DropdownButton<String>(
                            value: _myState,
                            iconSize: 30,
                            icon: (null),
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                            hint: Text('Select Crop'),
                            onChanged: (String newValue) {
                              setState(() {
                                _myState = newValue;
                                _getCitiesList(_myState);
                              });
                            },
                            items: cropList?.map((item) {
                              return new DropdownMenuItem(
                                child: new Text(item['CropName']),
                                value: item['CropId'].toString(),
                              );
                            })?.toList() ?? [],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 6,
              ),
              //======================================================== City
              Container(
                padding: EdgeInsets.only(left: 15, right: 15, top: 5),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: ButtonTheme(
                          alignedDropdown: true,
                          child: DropdownButton<String>(
                            value: _cropVarietyValue,
                            iconSize: 30,
                            icon: (null),
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                            hint:Text('Select Crop Variety'),
                            onChanged:(String newValue) {
                              setState(() {
                                _cropVarietyValue = newValue;
                              });
                            },
                            items: cropVarietyList?.map((item) {
                              return new DropdownMenuItem(
                                child: new Text(item['ProductName']),
                                value: item['ProductId'].toString(),
                              );
                            })?.toList() ??
                                [],
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
              SizedBox(height: 6.0,),
              Container(
                padding: EdgeInsets.only(left: 15, right: 15, top: 5),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Crop qty in gm',
                          labelText: 'Qty(gm)',
                        ),
                        onChanged: (String value){
                          setState(() {
                            _qty = value;
                          });
                        },
                        onSaved: (String value) {
                          // This optional block of code can be used to run
                          // code when the user saves the form.
                        },
                        validator: (String value) {
                          if(value.isEmpty){
                            return 'please enter quantity in gm.';
                          }
                        },
                      ),
                    ),

                  ],
                ),
              ),
              isSubmitted ? RaisedButton(
                child: Text('Delete'),
                onPressed: (){
                  deleteData();
                },
              ) : RaisedButton(
                child: Text('Submit Entry',style: TextStyle(color: Colors.black87),),
                color: Colors.white70,
                onPressed: (){
                  insertData();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  //=============================================================================== Api Calling here
//CALLING STATE API HERE
// Get State information by API
  List cropList;
  String _myState;
  String _qty;
  String stateInfoUrl = 'http://www.vnrdev.in/vrst/api/get-cropList/';
  Future<String> _getStateList() async {
    await http.get(stateInfoUrl, headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    }).then((response) {
      var data = json.decode(response.body);
      setState(() {
        cropList = data['crops'];
      });
    });
  }

  // Get State information by API
  List cropVarietyList;
  String _cropVarietyValue;


  Future<String> _getCitiesList(String cropId) async {
    String cityInfoUrl =
        'http://www.vnrdev.in/vrst/api/get-cropvariety/'+ cropId;
    await http.get(cityInfoUrl, headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    }).then((response) {
      var data = json.decode(response.body);

      setState(() {
        cropVarietyList = data['varieties'];
      });
    });
  }
}
