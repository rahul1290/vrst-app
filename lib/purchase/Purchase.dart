//import 'dart:html';

import 'package:flutter/material.dart';
//import 'package:flutter_html/style.dart';
import 'package:vrst/common/drawer.dart';
import 'package:vrst/common/global.dart' as global;
import 'package:vrst/dbhelper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Purchase extends StatefulWidget {
  @override
  _PurchaseState createState() => _PurchaseState();
}

class _PurchaseState extends State<Purchase> {
 final _formKey = GlobalKey<FormState>();
  final dbhelper = Databasehelper.instance;
  
  String _myCrop;
  String _qty;
  List _cropList;
  String _myCropVariety;
  List _cropVarietyList = [];
  List billEntries = [];
  List billEntriesDisplay=[];

  // String _cropstring;
  // String _cropvarietystring;
  // String _cropqutstring;

  bool loader = false;
  bool entrtForm = false;

  void initState() {
    super.initState();
    _getCrops();
  }

//////////////////////////////// getCrop //////////////////////////////////////////
  void _getCrops() async {
    setState(() {
      loader = true;
      _cropVarietyList = [];
    });
    List<dynamic> userdetail = await dbhelper.get(1);
    Map<String, String> headers = { "Content-type": "application/x-www-form-urlencoded","vrstKey": userdetail[0]['key'] };
    String url = global.baseUrl + 'get-cropList';
    http.Response resposne = await http.get(url,headers: headers);
    int statusCode = resposne.statusCode;
    if (statusCode == 200) {
      setState(() { 
        var data = jsonDecode(resposne.body);
        _cropList = data['crops'];
        print(_cropList);
        loader = false;
      });
    } else {
      setState(() {
        loader = false;
      });
    }
  }

  //////////////////////////////// getCropVariety //////////////////////////////////////////
  void _getCropVariety(String cropId) async {
    setState(() {
      loader = true;
      _myCropVariety = '0';
    });
    List<dynamic> userdetail = await dbhelper.get(1);
    Map<String, String> headers = { "Content-type": "application/x-www-form-urlencoded","vrstKey": userdetail[0]['key'] };
    String url = global.baseUrl + 'get-cropvariety/'+ cropId;
    print(url);
    http.Response resposne = await http.get(url,headers: headers);
    int statusCode = resposne.statusCode;
    if (statusCode == 200) {
      setState(() {
         
        var data = jsonDecode(resposne.body);
        _cropVarietyList = data['varieties'];
        print(_cropVarietyList);
        loader = false;
      });
    } else {
      print('else');
      setState(() {
        loader = false;
      });
    }
  }


  void _submit() async{
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        _formKey.currentState.reset();  

        billEntries.add({'crop':_myCrop,'variety':_myCropVariety,'qty':_qty});
        
        String tempCrop;  
        String tempVariety;
        //String tempQty;

        for(int i=0;i<_cropList.length; i++){
          if(_cropList[i]['CropId'] == _myCrop){
            tempCrop = _cropList[i]['CropName'];
          }
        }
        for(int j=0;j<_cropVarietyList.length; j++){
          if(_cropVarietyList[j]['ProductId'] == _myCropVariety){
            tempVariety = _cropVarietyList[j]['ProductName'];
          }
        }

        billEntriesDisplay.add({'crop':tempCrop,'variety':tempVariety,'qty':_qty});

        _myCrop = '0';
        _myCropVariety = '0';
        _qty = null;

        setState(() {
          entrtForm = false;
        });
      });
    } else {
      print('form validation error');
    }
  } 

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bill Entry'),
        centerTitle: true,
      ),
      drawer: DrawerPage(),
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
      ) : 
        Container(
          child: Column(
            children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: billEntriesDisplay.length > 0 ? Table(
                                border: TableBorder(horizontalInside: BorderSide(width: 1, color: Colors.blue, style: BorderStyle.solid)),
                                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                children: [
                                  TableRow(
                                    children: [
                                      TableCell(
                                        child: Text('Crop',style: TextStyle(fontSize:18,color: Colors.orange),),
                                      ),
                                      TableCell(
                                        child: Text('Variety',style: TextStyle(fontSize:18,color: Colors.orange),),
                                      ),
                                      TableCell(
                                        child: Text('Qty(gm)',style: TextStyle(fontSize:18,color: Colors.orange),),
                                      ), 
                                      TableCell(
                                        child: Text('',style: TextStyle(fontSize:18),),
                                      ), 
                                    ]
                                  ),
                                  for (var entry in billEntriesDisplay) TableRow(children: [
                                    TableCell(
                                      child: Text(entry['crop'].toString()),
                                    ),
                                    TableCell(
                                      child: Text(entry['variety'].toString()),
                                    ), 
                                    TableCell(
                                      child: Text(entry['qty'].toString()),
                                    ),
                                    TableCell(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          GestureDetector(
                                            child: Icon(Icons.delete),
                                            onTap: (){
                                              setState(() {
                                                int i = billEntriesDisplay.indexOf(entry);
                                                billEntriesDisplay.removeAt(i);
                                                billEntries.removeAt(i);
                                                print(billEntriesDisplay);
                                                print(billEntries);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ), 
                                  ])
                                ]
                              ) : Text(''),
                  ),
                ),

                entrtForm ? Container(
                  color: Colors.black12,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
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
                                      value: _myCrop,
                                      icon: (null),
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 16,
                                      ),
                                      hint: Text('Select Crop'),
                                      onChanged: (String newValue) {
                                        setState(() {
                                          _myCrop = newValue;
                                          _getCropVariety(_myCrop);
                                          print(_myCrop);
                                        });
                                      },
                                      items: _cropList?.map((item) {
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
                          height: 5,
                        ),
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
                                      value: _myCropVariety,
                                      iconSize: 30,
                                      icon: (null),
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 16,
                                      ),
                                      hint: Text('Select crop variety'),
                                      onChanged: (String newValue) {
                                        setState(() {
                                          _myCropVariety = newValue;
                                          print(_myCropVariety);
                                        });
                                      },
                                      items: _cropVarietyList.length > 0 ? _cropVarietyList?.map((item) {
                                            return new DropdownMenuItem(
                                              child: new Text(item['ProductName']),
                                              value: item['ProductId'].toString(),
                                            );
                                          })?.toList() ??
                                          [] : [],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        
                        Container(
                          padding: EdgeInsets.only(left: 15, right: 15, top: 5,bottom: 5),
                          color: Colors.white,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Qty(gm)',
                              //icon: Icon(Icons.place,color:Colors.grey,),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            onChanged: (String val){
                              setState(() {
                                _qty = val;
                              });
                            },
                            validator: (value){
                              return null;
                            },
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            RaisedButton(
                              child: Text('Cancel'),
                              color: Colors.orangeAccent,
                              onPressed: (){
                                setState(() {
                                  entrtForm = false;
                                });
                              },
                            ),
                            RaisedButton(
                              child: Text('Add'),
                              color: Colors.greenAccent,
                              onPressed: _submit,
                            ),
                          ],
                        ),
                      ],
                    ),
                    ),
                  ),
                ) : RaisedButton(
                  child: Text('Add More'),
                  onPressed: (){
                    setState(() {
                      entrtForm = true;
                    });
                  },
                ),
            ],
          ),
        ),
      
      
    );
  }
}