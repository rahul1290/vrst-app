import 'package:flutter/material.dart';
import 'package:vrst/purchase/bilEntry.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vrst/common/global.dart' as global;
import 'dart:async';
import 'dart:core';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
  final GlobalKey<FormState> _formNewKey = GlobalKey<FormState>();

  var cropDropDowm = <TextEditingController>[];
  var varietyDropDown = <TextEditingController>[];
  var qty = <TextEditingController>[];
  var cards = <Card>[];

  List _distributor = List();
  _FormData _data = new _FormData();
  TextEditingController _billDate;
  final picker = ImagePicker();

  Card createCard() {
    var cropController = TextEditingController();
    var varietyController = TextEditingController();
    var qtyController = TextEditingController();
    cropDropDowm.add(cropController);
    varietyDropDown.add(varietyController);
    qty.add(qtyController);

    return Card(
      child: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DropdownButtonFormField<String>(
              value: 'One',
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.deepPurple),
              onChanged: (String newValue) {
                setState(() {
                  _data.distributor = newValue;
                });
              },
              items: <String>['One', 'Two', 'Free', 'Four']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextFormField(
              controller: cropController,
              decoration: InputDecoration(labelText: 'Full Name'),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter something.';
                }
              },
            ),
            TextFormField(
                controller: varietyController,
                decoration: InputDecoration(labelText: 'Age')),
            TextFormField(
                controller: qtyController,
                decoration: InputDecoration(labelText: 'Study/ job')),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getdistributors();
    _billDate = TextEditingController();
    cards.add(createCard());
  }

  void _submit() async {
    if (this._formKey.currentState.validate()) {
      List<BillEntry> entries = [];
      for (int i = 0; i < cards.length; i++) {
        var crop = cropDropDowm[i].text;
        var variety = varietyDropDown[i].text;
        var quantity = qty[i].text;
        entries.add(BillEntry(crop, variety, quantity));
      }
      if (entries != null) print(entries);
      print('distributor :' + _data.distributor);
      print('bill:' + _data.billno);
      print('billdate :' + _data.billDate);
    }
  }

  void _getdistributors() async {
    String url = global.baseUrl + 'get-distributors';
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
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _data._image = image;
    });
  }

  _imgFromCamera() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _data._image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PURCHASE ORDER'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
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
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _data._image,
                            width: 300,
                            height: 400,
                            fit: BoxFit.fill,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(50)),
                          width: 100,
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
              Expanded(
                child: ListView.builder(
                    itemCount: cards.length,
                    itemBuilder: (BuildContext context, int index) {
                      return cards[index];
                    },
                  ),
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
        )
      ),
      
      
      floatingActionButton:
          FloatingActionButton(
            child: Icon(Icons.add), 
            onPressed: () => setState( () => cards.add(createCard())), 
          ),
    );
  }
}
