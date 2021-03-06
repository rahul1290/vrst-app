import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vrst/common/global.dart' as global;
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'dart:io';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterData{
  String state = '';
  String name = '';
  String contact = '';
  String password = '';
  String email = '';
  String pan = '';
  String address = '';
}

bool loader = false;
class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  _RegisterData _data = new _RegisterData();
  String dropdownValue;
  List _states= List();
  @override
  void initState() {
    _getstates();
    super.initState();
  }

  void _getstates() async{
    print('fucntion called');
    String url = global.baseUrl + 'get-states';
    http.Response resposne = await http.get(url);
    int statusCode = resposne.statusCode;
    if(statusCode == 200){
      setState(() {
        _states = jsonDecode(resposne.body);
        dropdownValue = _states[0]['state_code'];
      });
    }
  }

  void _submit() async{
    print('_submit called');
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();

      String url = global.baseUrl+'registration';
      //Map<String, String> headers = {"Content-type": "application/json"};
      http.Response response = await http.post(url,body:{'state_id':_data.state,'name':_data.name,'contact':_data.contact,'password':_data.password,'email':_data.email,'pan':_data.pan});
      int statusCode = response.statusCode;
      print(statusCode);
      print(response.body);
      if(statusCode == 200){
        Map body = jsonDecode(response.body);
        global.contactNo = body['contact_no'];
        Navigator.pushNamed(context, '/registerotp');
      } else {
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration'),
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
                        
                        // DropdownButton<String>(
                        //   key: Key('state'),
                        //   value: dropdownValue ?? null,
                        //   onChanged: (String newValue) {
                        //     setState(() {
                        //       dropdownValue = newValue;
                        //       this._data.state = newValue;
                        //     });
                        //   },
                        //   isExpanded: true,
                        //   hint: Text('Select State'),
                        //   items: _states.map((item) {
                        //       return DropdownMenuItem<String>(
                        //         value: item['state_code'].toString(),
                        //         child: Text(item['state_name']),
                        //       );
                        //     }).toList(),
                        // ),
                        TextFormField(
                          key: Key('retailername'),
                          decoration: InputDecoration(
                            icon: Icon(Icons.person,color:Colors.grey,),
                            labelText: 'Enter Retailer Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          validator: (value){
                            if(value.isEmpty){
                              return 'Please enter ratailer name.';
                            }
                            if(value.length < 3){
                              return 'Name should at least 4 characters';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (String value){
                            this._data.name = value;
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          key: Key('contactno'),
                          decoration: InputDecoration(
                            labelText: 'Enter Contact Number',
                            icon: Icon(Icons.mobile_friendly_sharp,color:Colors.grey,),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          validator: (value){
                            if(value.isEmpty){
                              return 'Please enter contact no.';
                            }
                            if(value.length != 10){
                              return 'Please enter valid contact no';
                            } 
                            else {
                              return null;
                            }
                          },
                          onSaved: (String value){
                            this._data.contact = value;
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Enter Password',
                            icon: Icon(Icons.vpn_key,color:Colors.grey,),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          validator: (value){
                            if(value.isEmpty){
                              return 'Please enter password';
                            }
                            if(value.length < 3){
                              return 'Password should at least 4 digits';
                            }
                            else {
                              return null;
                            }
                          },
                          onSaved: (String value){
                            this._data.password = value;
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        DropdownButtonFormField(
                            hint: Text('Select State'),
                            decoration: InputDecoration(
                              icon: Icon(Icons.person,color:Colors.grey,),
                            ),
                            items: _states.map((item) {
                              return DropdownMenuItem<String>(
                                value: item['state_code'].toString(),
                                child: Text(item['state_name']),
                              );
                            }).toList(),
                            onChanged: (String newValue) {
                              setState(() {
                                dropdownValue = newValue;
                                this._data.state = newValue;
                              });
                            },
                            onSaved: (String newValue){
                              setState((){
                                this._data.state = newValue;
                              });
                            },  
                            validator: (newValue){
                              print(newValue);
                              if(newValue == 0 || newValue == ''){
                                return 'Please select state.';
                              } 
                              else {
                                return null;
                              }
                            },
                        ),
                        SizedBox(height: 10.0,),
                        TextFormField(
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Address',
                            icon: Icon(Icons.place,color:Colors.grey,),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          validator: (value){
                            if(value.isEmpty){
                                return 'Please enter Address.';
                            }
                            else {
                              return null;
                            }
                          },
                          onSaved: (String value){
                            this._data.address = value;
                          },
                          keyboardType: TextInputType.multiline,
                        ),
                        SizedBox(height: 10.0,),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Enter EmailID (Optional)',
                            icon: Icon(Icons.mail,color:Colors.grey,),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          onSaved: (String value){
                            this._data.email = value;
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Enter PAN/Aadhar (Optional)',
                            icon: Icon(Icons.credit_card,color:Colors.grey,),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          onSaved: (String value){
                            this._data.pan = value;
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        RaisedButton(
                          color: Colors.lightGreen,
                          splashColor: Colors.red,
                          child: Text('NEXT',style: TextStyle(color: Colors.white, fontSize: 16),),
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