import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vrst/common/global.dart' as global;
import 'package:http/http.dart' as http;
import 'package:vrst/dbhelper.dart';
// import 'package:intl/intl.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:async';
import 'dart:core';
import 'dart:convert';
// import 'dart:io';

class ReturnOrder extends StatefulWidget {
  @override
  _ReturnOrderState createState() => _ReturnOrderState();
}


class _ReturnOrderState extends State<ReturnOrder> {
  final _formKey = GlobalKey<FormState>();
  String stateDropdownValue;
  String distributorDropdownValue = 'Select Distributor';
  String billDate;
  // TextEditingController _billDate;
  List _crops = List();
  List cropVarietyList = List();
  List _distributor = List();
  String _cropVarietyValue;
  String _distributorValue;

  
  final dbhelper = Databasehelper.instance;
  // TextEditingController _billController;
  // static List<String> friendsList = [null];
  bool loader = false;
  void initState() {
    setState(() {
      loader = true;
    });
    _getcrops();
    super.initState();
  }

  void _getcrops() async{
    List<dynamic> userdetail = await dbhelper.get(1);
    Map<String, String> headers = {
      "Content-type": "application/x-www-form-urlencoded",
      "vrstKey": userdetail[0]['key']
    };
    String url = global.baseUrl+'my-orders-crop';
    print(url);
    http.Response resposne = await http.get(url,headers: headers);
    int statusCode = resposne.statusCode;
    print(statusCode);
    if(statusCode == 200){
      setState(() {
        _crops = jsonDecode(resposne.body);
        loader = false;
      });
    }
  }

  void _submit() {
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();
    }
  }

  void _getcropvariety() async{
    List<dynamic> userdetail = await dbhelper.get(1);
    Map<String, String> headers = {
      "Content-type": "application/x-www-form-urlencoded",
      "vrstKey": userdetail[0]['key']
    };
    String url = global.baseUrl+'my-orders-cropvariety'+ '/'+ stateDropdownValue;
    http.Response resposne = await http.get(url,headers: headers);
    int statusCode = resposne.statusCode;
    print(statusCode);
    if(statusCode == 200){
      setState(() {
        loader = false;
        cropVarietyList = jsonDecode(resposne.body);
      });
    }
  }

  void _getdistributors() async{
    List<dynamic> userdetail = await dbhelper.get(1);
    Map<String, String> headers = {
      "Content-type": "application/x-www-form-urlencoded",
      "vrstKey": userdetail[0]['key']
    };
    String url = global.baseUrl+'get-distributor'+ '/'+ stateDropdownValue + '/' + _cropVarietyValue;
    print(url);
    http.Response resposne = await http.get(url,headers: headers);
    int statusCode = resposne.statusCode;
    print(statusCode);
    if(statusCode == 200){
      setState(() {
        loader = false;
        _distributor = jsonDecode(resposne.body);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RETURN ORDER'),
        centerTitle: true,
      ),
      body: loader ? Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 15.0,),
              Text('  Loading...',style: TextStyle(color: Colors.redAccent,fontWeight: FontWeight.bold,),),
            ],
          ),
        ),
        //child: CircularProgressIndicator(),
      ) :SingleChildScrollView(
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
                            hint: Text('Select Crop'),
                            items: _crops.map((item) {
                              return DropdownMenuItem<String>(
                                value: item['crop'].toString(),
                                child: Text(item['CropName']),
                              );
                            }).toList(),
                            onChanged: (String newValue) {
                              setState(() {
                                stateDropdownValue = newValue;
                                _getcropvariety();
                              });
                            },
                            validator: (value){
                              if(value != 0){
                                return 'Please select crop';
                              } else {
                                return null;
                              }
                            }
                        ),

                        SizedBox(height: 10.0,),
                        DropdownButtonHideUnderline(
                          child: ButtonTheme(
                            alignedDropdown: true,
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _cropVarietyValue,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                              hint:Text('Select Crop Variety'),
                              onChanged:(String newValue) {
                                  print(newValue);
                                setState(() {
                                  _cropVarietyValue = newValue;
                                  _getdistributors();
                                });
                              },
                              items: cropVarietyList?.map((item) {
                                return new DropdownMenuItem(
                                  child: new Text(item['ProductName']),
                                  value: item['ProductId'].toString(),
                                );
                              })?.toList() ?? [],
                            ),
                          ),
                        ),

                        DropdownButtonHideUnderline(
                          child: ButtonTheme(
                            alignedDropdown: true,
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _distributorValue,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                              hint:Text('Select Distributor'),
                              onChanged:(String newValue) {
                                setState(() {
                                  _distributorValue = newValue;
                                });
                              },
                              items: _distributor?.map((item) {
                                return new DropdownMenuItem(
                                  child: new Text(item['distributor_id']),
                                  value: item['DealerName'].toString(),
                                );
                              })?.toList() ??
                                  [],
                            ),
                          ),
                        ),

                        TextFormField(
                          
                        ),


                        RaisedButton(
                            color: Color(0xFFf09a3e),
                            splashColor: Colors.red,
                            child: Text(
                              'Return',
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
}



