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
import 'package:vrst/test.dart';

class BillEntryForm extends StatefulWidget {
  @override
  _BillEntryFormState createState() => _BillEntryFormState();
}

class _FormData {
  String distributor = 'Select Distributor';
  String billno = '';
  String billDate = '';
  File _image;
}

class _BillEntryFormState extends State<BillEntryForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var cropDropDowm = <TextEditingController>[];
  var varietyDropDown = <TextEditingController>[];
  var qty = <TextEditingController>[];
  final dbhelper = Databasehelper.instance;
  String _ustate;
  bool loader = true;
  String filePath;

  List _distributor = List();
  //List _crop;
  //List _cropVariety;

  _FormData _data = new _FormData();
  TextEditingController _billDate;
  final picker = ImagePicker();
  var cards = <Container>[];
  Test test = new Test();

  Container createCard(){
    return Container(
      child: test,
    );
  }

  @override
  void initState() {
    fetchData().then((value){
      _getdistributors().then((value){
        loader = false;
        _getcrop().then((value){
          _getcropVariety().then((value){
            //cards.add(createCard());
            cards.add(createCard());
            _billDate = TextEditingController();
            dbhelper.deleteEntriesData();
          });
        });
      });
    });
    super.initState();
  }

  Future fetchData() async {
    List userData = await dbhelper.getall();
    setState(() {
      _ustate = userData[0]['state'];
    });
  }

  void _submit() async {
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();
      // setState(() {
      //   loader = true;
      // });
      List entries = await dbhelper.getallentries();
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
        'entries' : entries.toString(),
        'billimage' : filePath
      });
      int statusCode = response.statusCode;
      if(statusCode == 200){
        setState(() {
          loader = false;
        });
        _purchaseSuccess();
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

  Future _getcrop() async {
    String url = global.baseUrl + 'get-cropList/';
    http.Response resposne = await http.get(url);
    int statusCode = resposne.statusCode;
    if (statusCode == 200) {
      setState(() {
        //var data = jsonDecode(resposne.body);
        //_crop = data['crops'];
      });
    }
  }

  Future _getcropVariety() async {
    String url = global.baseUrl + 'get-cropvariety/';
    http.Response resposne = await http.get(url);
    int statusCode = resposne.statusCode;
    if (statusCode == 200) {
      setState(() {
        //var data = jsonDecode(resposne.body);
        //_cropVariety = data['varieties'];
      });
    }
  }

  // Future _getcropInnerVariety(String cropId) async {
  //   String url = global.baseUrl + 'get-cropvariety/'+cropId;
  //   http.Response resposne = await http.get(url);
  //   int statusCode = resposne.statusCode;
  //   if (statusCode == 200) {
  //     setState(() {
  //       _cropVariety = jsonDecode(resposne.body);
  //       print(_cropVariety);
  //     });
  //   }
  // }

  Future _getdistributors() async {
    String url = global.baseUrl + 'get-distributors/' + _ustate;
    print(url);
    http.Response resposne = await http.get(url);
    int statusCode = resposne.statusCode;
    if (statusCode == 200) {
      _distributor = jsonDecode(resposne.body);

      setState(() {
        _data.distributor = _distributor[0]['DealerId'];
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
                  Divider(
                    color: Colors.black,
                  ),
                  Text('Enter Bill Entries'),
                  Divider(
                    color: Colors.black,
                  ),

                  ListView.builder(
                    //itemExtent: 10.0,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: cards.length,
                    itemBuilder: (BuildContext context, int index) {
                      return cards[index];
                    },
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  RaisedButton(
                    child: Text('Submit'),
                    onPressed: _submit,
                    color: Colors.green,
                  ),
                ],
              ),
            )),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => setState(() => cards.add(createCard())),
      ),
    );
  }
}

