import 'dart:convert';
import 'package:vrst/dbhelper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  final dbhelper = Databasehelper.instance;
  bool isSubmitted = false;
  bool isDeleted = false;
  String _entryId;

  @override
  void initState() {
    _getStateList();
    super.initState();
  }

  Future<void> insertData() async {
    Map<String,dynamic> row = {
      Databasehelper.columnCrop : _myState,
      Databasehelper.columnVariety : _myCity,
      Databasehelper.columnQty : _qty
    };

    await dbhelper.insertBill(row);
    List userData = await dbhelper.getallentries();
    List insertId = await dbhelper.maxId();

    setState(() {
      isSubmitted = true;
      _entryId = insertId[0]['count'].toString();
    });
  }


  void deleteData() async{
    dbhelper.deleteEntriesId(int.parse(_entryId));
    List userData = await dbhelper.getallentries();
    setState(() {
      isDeleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
                          hint: Text('Select State'),
                          onChanged: (String newValue) {
                            setState(() {
                              _myState = newValue;
                              _getCitiesList(_myState);
                            });
                          },
                          items: statesList?.map((item) {
                            return new DropdownMenuItem(
                              child: new Text(item['CropName']),
                              value: item['CropId'].toString(),
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
                          value: _myCity,
                          iconSize: 30,
                          icon: (null),
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                          hint: Text('Select City'),
                          onChanged: (String newValue) {
                            setState(() {
                              _myCity = newValue;
                            });
                          },
                          items: citiesList?.map((item) {
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
                      // validator: (String value) {
                      //   return value.contains('@') ? 'Do not use the @ char.' : null;
                      // },
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
              child: Text('Update'),
              onPressed: (){
                insertData();
              },
            ),
          ],
        ),
      ),
    );
  }

  //=============================================================================== Api Calling here
//CALLING STATE API HERE
// Get State information by API
  List statesList;
  String _myState;
  String _qty;
  String stateInfoUrl = 'http://www.vnrdev.in/vrst/api/get-cropList/';
  Future<String> _getStateList() async {
    await http.get(stateInfoUrl, headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    }).then((response) {
      var data = json.decode(response.body);
      setState(() {
        statesList = data['crops'];
      });
    });
  }

  // Get State information by API
  List citiesList;
  String _myCity;


  Future<String> _getCitiesList(String cropId) async {
    String cityInfoUrl =
        'http://www.vnrdev.in/vrst/api/get-cropvariety/'+ cropId;
    await http.get(cityInfoUrl, headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    }).then((response) {
      var data = json.decode(response.body);

      setState(() {
        citiesList = data['varieties'];
      });
    });
  }
}
