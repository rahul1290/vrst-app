import 'package:flutter/material.dart';
import 'package:vrst/common/global.dart' as global;
import 'package:vrst/dbhelper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReturnOrder extends StatefulWidget {
  @override
  _ReturnOrderState createState() => _ReturnOrderState();
}

class _ReturnOrderState extends State<ReturnOrder> {
  final _formKey = GlobalKey<FormState>();
  final dbhelper = Databasehelper.instance;
  
  List _distributorsList = [];
  String _myCrop;
  String _qty;
  List _cropList;
  String _myCropVariety;
  String _myCropDistributor;
  List _cropVarietyList = [];
  String maxReturnQty = '0';
  //List _cropDistributorList; 
  bool loader = false;

  void initState() {
    super.initState();
    _getCrops();
  }

//////////////////////////////// getCrop //////////////////////////////////////////
  void _getCrops() async {
    setState(() {
      loader = true;
    });
    List<dynamic> userdetail = await dbhelper.get(1);
    Map<String, String> headers = { "Content-type": "application/x-www-form-urlencoded","vrstKey": userdetail[0]['key'] };
    String url = global.baseUrl + 'my-orders-crop';
    http.Response resposne = await http.get(url,headers: headers);
    int statusCode = resposne.statusCode;
    if (statusCode == 200) {
      setState(() {
        _cropList = jsonDecode(resposne.body);
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
      _myCropDistributor = '0';
    });
    List<dynamic> userdetail = await dbhelper.get(1);
    Map<String, String> headers = { "Content-type": "application/x-www-form-urlencoded","vrstKey": userdetail[0]['key'] };
    String url = global.baseUrl + 'my-orders-cropvariety/'+ cropId;
    http.Response resposne = await http.get(url,headers: headers);
    int statusCode = resposne.statusCode;
    if (statusCode == 200) {
      setState(() {
        _cropVarietyList = jsonDecode(resposne.body);
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

////////////////////////////////////////////get Distributor////////////////////////////////////////
  void _getDistributors() async {
    setState(() {
      loader = true;
      _myCropDistributor = '0';
    });
    List<dynamic> userdetail = await dbhelper.get(1);
    Map<String, String> headers = { "Content-type": "application/x-www-form-urlencoded","vrstKey": userdetail[0]['key'] };
    String url = global.baseUrl + 'get-distributor/'+ _myCrop + '/' + _myCropVariety;
    print(url);
    http.Response resposne = await http.get(url,headers: headers);
    int statusCode = resposne.statusCode;
    if (statusCode == 200) {
      setState(() {
        _distributorsList = jsonDecode(resposne.body);
        print(_distributorsList);
        loader = false;
      });
    } else {
      print('else');
      setState(() {
        loader = false;
      });
    }
  }

  void _getReturnQty() async {
    setState(() {
      loader = true;
    });
    List<dynamic> userdetail = await dbhelper.get(1);
    Map<String, String> headers = { "Content-type": "application/x-www-form-urlencoded","vrstKey": userdetail[0]['key'] };
    String url = global.baseUrl + 'get-return-qty/'+ _myCrop + '/' + _myCropVariety + '/' + _myCropDistributor;
    print(url);
    http.Response resposne = await http.get(url,headers: headers);
    int statusCode = resposne.statusCode;
    if (statusCode == 200) {
      setState(() {
        var data = jsonDecode(resposne.body);
        maxReturnQty = data[0]['qty'].toString();
        print(int.parse(maxReturnQty));
        loader = false;
      });
    } else {
      print('else');
      setState(() {
        loader = false;
      });
    }
  }

void _submit() async {
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        loader = true;
      });
      print(_myCrop);
      List<dynamic> userdetail = await dbhelper.get(1);
      String url = global.baseUrl + "Purchase_ctrl/return_order";
      Map<String, String> headers = {
        "Content-type": "application/x-www-form-urlencoded",
        "vrstKey": userdetail[0]['key']
      };
      http.Response response = await http.post(url, headers: headers, body: {
        'distributor_id' : _myCropDistributor,
        'crop_id' : _myCrop,
        'crop_variety' : _myCropVariety,
        'qty' : _qty
      });
      int statusCode = response.statusCode;
      print(statusCode);
      if(statusCode == 200){
        setState(() {
          loader = false;
        });
        _returnSuccess();
      }
    }
  }


  Future<void> _returnSuccess() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Crop Return!',textAlign: TextAlign.center,),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You successfully submit your returs.',textAlign: TextAlign.center,),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/returnlist');
              },
            ),
          ],
        );
      },
    );
  }

//////////////////////////////////////////
//////////////////////////////////////////
//////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Return Order'),
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
      ) : 
      Padding(
        padding: const EdgeInsets.only(top: 25.0),
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
                                  value: item['crop'].toString(),
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
              height: 10,
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
                              _getDistributors();
                            });
                          },
                          items: _cropVarietyList.length > 0 ? _cropVarietyList?.map((item) {
                                return new DropdownMenuItem(
                                  child: new Text(item['ProductName']),
                                  value: item['crop_variety'].toString(),
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
              height: 10,
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
                          value: _myCropDistributor,
                          iconSize: 30,
                          icon: (null),
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                          hint: Text('Select Distributor'),
                          onChanged: (String newValue) {
                            setState(() {
                              _myCropDistributor = newValue;
                              _getReturnQty();
                              print(_myCropDistributor);
                            });
                          },
                          items: _distributorsList.length >0 ? _distributorsList?.map((item) {
                                return new DropdownMenuItem(
                                  child: new Text(item['DealerName']),
                                  value: item['distributor_id'].toString(),
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
            
        
            Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5),
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
                  if(value.isEmpty){
                    return "Please enter Qty";
                  }
                  if(int.parse(value) > int.parse(maxReturnQty)){
                    return "Qty not greater then ";
                  } else {
                    return null;
                  }
                },
              ),
            ),

            SizedBox(
              height: 15.0,
            ),

            RaisedButton(
              color: Colors.redAccent,
              child: Text('Return',style: TextStyle(color: Colors.white),),
              onPressed: _submit,
            ),
          ],
        ),
        ),
      ),
      
    );
  }
}