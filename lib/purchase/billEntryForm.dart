import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
//import 'package:vrst/purchase/bilEntry.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vrst/common/global.dart' as global;
import 'dart:async';
import 'dart:core';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:vrst/dbhelper.dart';

class BillEntryForm extends StatefulWidget {
  @override
  _BillEntryFormState createState() => _BillEntryFormState();
}

class _FormData {
  String distributor;
  String billno = '';
  String billDate = '';
  File _image;
}

class _BillEntryFormState extends State<BillEntryForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _entryformKey = GlobalKey<FormState>();

  var cropDropDowm = <TextEditingController>[];
  var varietyDropDown = <TextEditingController>[];
  var qty = <TextEditingController>[];
  final dbhelper = Databasehelper.instance;
  String _ustate;
  bool loader = true;
  bool entrtForm = false;
  String filePath;

  List _distributor = List();
  
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


  _FormData _data = new _FormData();
  TextEditingController _billDate;
  final picker = ImagePicker();

  @override
  void initState() {
    fetchData().then((value){
      _getdistributors().then((value){
        _getCrops().then((value){
          loader = false;
        _billDate = TextEditingController();
        dbhelper.deleteEntriesData();
        });
      });
    });
    super.initState();
  }

  //////////////////////////////// getCrop //////////////////////////////////////////
  Future _getCrops() async {
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

  Future fetchData() async {
    List userData = await dbhelper.getall();
    setState(() {
      _ustate = userData[0]['state'];
    });
  }


  void _submitEntryForm() async{
    if (this._entryformKey.currentState.validate()) {
      _entryformKey.currentState.save();
      setState(() {
        //_entryformKey.currentState.reset();  

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

  void _submit() async {
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        loader = true;
      });
      //List entries = await dbhelper.getallentries();
      List<dynamic> userdetail = await dbhelper.get(1);
      String url = global.baseUrl + "Purchase_ctrl/purchaseOrder";
      Map<String, String> headers = {
        "Content-type": "application/x-www-form-urlencoded",
        "vrstKey": userdetail[0]['key']
      };
      //String json = '{"distributor":"' +_data.distributor +'","billno":"' +_data.billno +'","billdate":"' +_data.billDate +'","entries":"' +Entries.toString() +'","billimage":"' + filePath +'"}';
      http.Response response = await http.post(url, headers: headers, body: {
        'distributor' : _data.distributor,
        'billno' : _data.billno,
        'billdate' : _data.billDate,
        'entries' : billEntries.toString(),
        'billimage' : filePath
      });
      int statusCode = response.statusCode;
      print(billEntries.toString()); 
      print(jsonDecode(response.body));
      if(statusCode == 200){
        setState(() {
          loader = false;
        });
        _purchaseSuccess();
      } else {
        loader = false;
      }
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
                Text('You successfully submit your order.',textAlign: TextAlign.center,),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/orderList');
              },
            ),
          ],
        );
      },
    );
  }

  Future _getdistributors() async {
    String url = global.baseUrl + 'get-distributors/' + _ustate;
    print(url);
    http.Response resposne = await http.get(url);
    int statusCode = resposne.statusCode;
    if (statusCode == 200) {
      setState(() {
        _distributor = jsonDecode(resposne.body);
        _data.distributor = '0';
      });
    }
  }

  Widget _billDateWidget() {
    return TextFormField(
      controller: _billDate,
      readOnly: true,
      decoration: InputDecoration(
          labelText: 'Select Date',
          suffixIcon: GestureDetector(
            child: Icon(Icons.calendar_today),
          )),
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
              _data.billDate = formatted;
              _billDate.text = formatted;
            });
          }
        })
      },
      onSaved: (String value) {
        _data.billDate = value;
      },
      validator: (String value) {
        if (value.isEmpty) {
          return 'Select date';
        } else {
          return null;
        }
      },
    );
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
      filePath = base64Encode(image.readAsBytesSync());
    });
  }

  _imgFromCamera() async {
    // ignore: deprecated_member_use
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _data._image = image;
      filePath = base64Encode(image.readAsBytesSync());
    });
  }

  Widget _getFAB() {
    if (entrtForm) {
      return Container();
    } else {
      return FloatingActionButton(
          backgroundColor: Colors.green,
          child: Icon(Icons.save_alt),
          onPressed: _submit
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PURCHASE ORDER'),
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
      ) : SingleChildScrollView(
        child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  DropdownButtonFormField(
                    isExpanded: true,
                    hint: Text('Select Distributor'),
                    items: _distributor.map((item) {
                      return DropdownMenuItem<String>(
                        value: item['DealerId'].toString(),
                        child: Text(item['DealerName']),
                      );
                    }).toList(),
                    onChanged: (String newValue) {
                      setState(() {
                        print(newValue);
                        _data.distributor = newValue;
                      });
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Bill No.',
                    ),
                    onChanged: (value) {
                      _data.billno = value;
                    },
                    onSaved: (value) {
                      _data.billno = value;
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter Bill No.';
                      } else {
                        return null;
                      }
                    },
                  ),
                  _billDateWidget(),
                  SizedBox(
                    height: 10.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      _showPicker(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Upload Bill Image'),
                        CircleAvatar(
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
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  ///////////////////////////////////////////////////////
                  ///////////////////////////////////////////////////////
                  Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: billEntriesDisplay.length > 0 ? Table(
                                //border: TableBorder(horizontalInside: BorderSide(width: 1, color: Colors.blue, style: BorderStyle.solid)),
                                border: TableBorder.symmetric(inside: BorderSide(width: 1, color: Colors.green), outside: BorderSide(width: 2, color: Colors.green)),
                                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                children: [
                                  TableRow(
                                    children: [
                                      TableCell(
                                        child: Text('Crop',style: TextStyle(fontSize:18,color: Colors.orange),textAlign: TextAlign.center,),
                                      ),
                                      TableCell(
                                        child: Text('Variety',style: TextStyle(fontSize:18,color: Colors.orange),textAlign: TextAlign.center,),
                                      ),
                                      TableCell(
                                        child: Text('Qty(gm)',style: TextStyle(fontSize:18,color: Colors.orange),textAlign: TextAlign.center,),
                                      ), 
                                      TableCell(
                                        child: Text('',style: TextStyle(fontSize:18),),
                                      ), 
                                    ]
                                  ),
                                  for (var entry in billEntriesDisplay) TableRow(children: [
                                    TableCell(
                                      child: Text(entry['crop'].toString(),textAlign: TextAlign.center,),
                                    ),
                                    TableCell(
                                      child: Text(entry['variety'].toString(),textAlign: TextAlign.center,),
                                    ), 
                                    TableCell(
                                      child: Text(entry['qty'].toString(),textAlign: TextAlign.center,),
                                    ),
                                    TableCell(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
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
                      key: _entryformKey,
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
                              onPressed: _submitEntryForm,
                            ),
                          ],
                        ),
                      ],
                    ),
                    ),
                  ),
                ) : RaisedButton(
                  child: billEntriesDisplay.length > 0 ? Text('Add More') : Text('Add Enteries'),
                  onPressed: (){
                    setState(() {
                      entrtForm = true;
                    });
                  },
                ),

                  ///////////////////////////////////////////////////////
                  ///////////////////////////////////////////////////////

                ],
              ),
            )),
      ),
      floatingActionButton: _getFAB(),
    );
  }
}

